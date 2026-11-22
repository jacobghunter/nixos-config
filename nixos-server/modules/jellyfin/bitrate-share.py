# Shares the upload between remote Jellyfin streams. Jellyfin only has
# per-stream limits, so this polls the active sessions and sets each user's
# RemoteClientBitrateLimit to whatever the *other* users' remote streams leave
# of the total. Jellyfin reads the limit when a stream starts (and on seek),
# so the first remote viewer gets the max and the next gets what's left.
#
# A user's own limit overrides the server-wide one when it's > 0, so when
# there's room for the max this sets it back to 0 and the server's
# RemoteClientBitrateLimit (pinned in jellyfin.nix) applies.
#
# Only ever changes users' RemoteClientBitrateLimit, and never touches a
# running stream. If anything fails it logs and retries next poll, leaving the
# last limits in place.
import ipaddress
import json
import os
import sys
import time
import urllib.request

URL = os.environ["JELLYFIN_URL"]
API_KEY = os.environ["JELLYFIN_API_KEY"]
TOTAL = int(os.environ["TOTAL_BITRATE"])
MAX = int(os.environ["MAX_BITRATE"])
FLOOR = int(os.environ["FLOOR_BITRATE"])
INTERVAL = float(os.environ["POLL_SECONDS"])

# Direct-played video bitrate doesn't include audio; pad for it.
AUDIO_ALLOWANCE = 1_000_000


def api(method, path, body=None):
    req = urllib.request.Request(
        URL + path,
        method=method,
        data=json.dumps(body).encode() if body is not None else None,
        headers={
            "Authorization": f'MediaBrowser Token="{API_KEY}"',
            "Content-Type": "application/json",
        },
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        data = resp.read()
    return json.loads(data) if data else None


def is_remote(endpoint):
    # Same split Jellyfin makes with no LocalNetworkSubnets set: private
    # ranges are LAN, everything else (including Tailscale's 100.64/10) isn't.
    try:
        ip = ipaddress.ip_address(endpoint)
    except ValueError:
        return True
    return not (ip.is_private or ip.is_loopback)


def stream_bitrate(session):
    transcode = session.get("TranscodingInfo") or {}
    if transcode.get("Bitrate"):
        return transcode["Bitrate"]
    for stream in session["NowPlayingItem"].get("MediaStreams", []):
        if stream.get("Type") == "Video" and stream.get("BitRate"):
            return min(stream["BitRate"] + AUDIO_ALLOWANCE, MAX)
    # Unknown - assume it's using a full share.
    return MAX


def poll():
    used = {}  # user id -> bitrate of their remote streams
    for session in api("GET", "/Sessions"):
        if session.get("NowPlayingItem") and is_remote(session.get("RemoteEndPoint", "")):
            user = session["UserId"]
            used[user] = used.get(user, 0) + stream_bitrate(session)
    total_used = sum(used.values())

    for user in api("GET", "/Users"):
        others = total_used - used.get(user["Id"], 0)
        limit = max(FLOOR, min(MAX, TOTAL - others))
        # Room for the max: defer to the server-wide limit.
        wanted = 0 if limit >= MAX else limit

        policy = user["Policy"]
        if (policy.get("RemoteClientBitrateLimit") or 0) != wanted:
            policy["RemoteClientBitrateLimit"] = wanted
            api("POST", f"/Users/{user['Id']}/Policy", policy)
            shown = f"{wanted / 1e6:g} Mbps" if wanted else "server default"
            print(
                f"{user['Name']}: remote limit -> {shown} "
                f"(other remote streams using {others / 1e6:.1f} Mbps)",
                flush=True,
            )


while True:
    try:
        poll()
    except Exception as e:  # Jellyfin restarting, network blip, etc.
        print(f"poll failed: {e!r}", file=sys.stderr, flush=True)
    time.sleep(INTERVAL)
