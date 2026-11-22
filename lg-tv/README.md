# LG B4 TV (rooted webOS)

Not managed by Nix — notes so the setup can be redone or undone.

- webOS 9.2.4 (firmware `9.2.4-44`), rooted, Homebrew Channel installed
- IP `192.168.1.223`, Wi-Fi MAC `44:27:45:7a:c7:a0`, hostname `LGwebOSTV-1dFQ-1`
- Uses DHCP (connman) from the router at 192.168.1.1, not the Pi-hole. Reserve
  the MAC on the router (TP-Link: Advanced → Network → DHCP Server → Address
  Reservation); it never showed in the router's lease list on its own.
- SSH: `ssh tv` (alias in `shared/home-base.nix`)

## Gotchas

- `luna-send` prints nothing (and may do nothing) without a TTY: use `ssh -t tv`.
- The TV has 1.7 GB RAM and runs into swap easily. Close apps you aren't using.

## Home screen

- **OpenHome** (`io.github.devic021.openhome`) is the home screen, installed from
  its GitHub release (not in the Homebrew repo yet, see webosbrew/apps-repo#287).
- Home button → OpenHome via OpenHome's "webOS 6-24" method, which adds
  `/var/lib/webosbrew/init.d/replace.sh` (sed-patches LG's `systemUi.js` and
  bind-mounts the copy; nothing on disk changes, a reboot without it undoes it).
  - OpenHome's own `replace.sh` empties `systemUi.js` if applied twice without a
    reboot (it reads the file it's mounted over), and the Home button then goes
    to LG Home. The TV runs the fixed, re-runnable copy in
    `openhome/replace.sh`; the original is at `/home/root/replace.sh.openhome-orig`.
    Re-applying from OpenHome's settings overwrites the fix — copy it back.
  - OpenHome auto-detects the method from `systemUi.js`, so once it's patched
    (or emptied) it wrongly switches to "webOS 25-26 (Default App)". Keep it on
    "webOS 6-24".
- OpenHome settings backup (its built-in backup, `/media/developer/openlauncher-settings.json`)
  and its TV-settings file (`/var/lib/webosbrew/openlauncher-tvsettings.json`)
  are in `openhome/`. The backup's `homeReplaceMethod` was corrected from
  `defaultapp` to `sixto24`.
- Remote button `3` → OpenHome via LG Input Hook
  (`/home/root/.config/lginputhook/keybinds.json`, backup at `keybinds.json.bak`).
- OpenHome lag fix: `openhome/perf.css` (`.appitem { will-change: transform; }`)
  stops the tile focus-zoom from repainting the screen every frame — home-row
  navigation went from 15-27 fps to a steady 60. Video backgrounds aren't the
  cost. Re-run `openhome/apply-perf.sh` after every OpenHome update (original
  `index.html` backed up at `/home/root/openhome-index.html.orig`).
- **Home Chooser** (webosbrew) does *not* work on this firmware
  (`unknown launchHomeApp shape`) — uninstalled.
- **Home+** was tried and uninstalled; its leftovers (`init.d/50-homeplus`,
  `/var/lib/homeplus`) were removed by hand.

## Trimmed LG services

`/var/lib/webosbrew/init.d/90-lg-trim` stops these 90 s after boot (runtime
only, no firmware changes): ThinQ (`iot-client`, `lg.thinqai.adapter`), Alexa
(`amazon-alexa-adapter`, `amazon-alexa-vsk`) and the voice assistant
(`performer`). The remote's voice button, Alexa and ThinQ phone control no
longer work. AirPlay and Chromecast are left alone.

Undo: `ssh tv rm /var/lib/webosbrew/init.d/90-lg-trim` and reboot. If the TV
misbehaves and SSH is unreachable, the Homebrew Channel's failsafe mode skips
all `init.d` scripts.

## Other homebrew boot scripts (`/var/lib/webosbrew/init.d`)

- `inputhook`, `appupdateblocker` — Input Hook and the app update blocker
- `50-custom-amazoff`, `50-lifesgoodwithoutspying` — ad/telemetry blocking
- `50-custom-screensaver-aerial`, `48-aerial-backlight-restore` — aerial screensaver

## Tailscale

Static arm64 build in `/home/root/.local/bin` (`~/.profile` adds it to PATH),
run in userspace mode so it never touches the TV's routes or firewall. Not
started at boot. Node `lg-tv`, `100.93.147.92`; disable key expiry for it in the
admin console or it will need a fresh `tailscale up` login every few months.

- **Tailscale** app on the TV (`local.jacob.tailscale`, source in
  `tailscale-toggle/`) shows status and turns it on/off via the Homebrew
  Channel's root `exec`. Rebuild with `./tailscale-toggle/build.py <out-dir>`
  and install as in the script's docstring.
- By hand: start with
  `setsid tailscaled --tun=userspace-networking --statedir=/home/root/.local/share/tailscale --socket=/tmp/tailscaled.sock </dev/null >/tmp/tailscaled.log 2>&1 &`,
  stop with `killall tailscaled`. Every `tailscale` command needs
  `--socket=/tmp/tailscaled.sock`.
- Upgrade: replace the two binaries with a newer `tailscale_*_arm64.tgz` from
  pkgs.tailscale.com/stable (stop it first).
