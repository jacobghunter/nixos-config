// Starts/stops tailscaled through the Homebrew Channel's root exec service.
// Same commands as the manual SSH steps in ../../README.md.
var BIN = "/home/root/.local/bin";
var SOCK = "/tmp/tailscaled.sock";
var CMD_STATUS =
	"pidof tailscaled >/dev/null || { echo OFF; exit 0; }; " +
	BIN + "/tailscale --socket=" + SOCK + " status --json --peers=false 2>/dev/null || echo STARTING";
var CMD_START =
	"pidof tailscaled >/dev/null || setsid " + BIN + "/tailscaled --tun=userspace-networking" +
	" --statedir=/home/root/.local/share/tailscale --socket=" + SOCK +
	" </dev/null >/tmp/tailscaled.log 2>&1 &";
var CMD_STOP = "killall tailscaled; true";

var stateEl = document.getElementById("state");
var detailEl = document.getElementById("detail");
var button = document.getElementById("toggle");
var running = false;
var busy = false;
var bridges = []; // keep bridges referenced until they answer

function luna(uri, params) {
	return new Promise(function (resolve) {
		var bridge = new PalmServiceBridge();
		bridges.push(bridge);
		bridge.onservicecallback = function (msg) {
			bridges.splice(bridges.indexOf(bridge), 1);
			try { resolve(JSON.parse(msg)); } catch (e) { resolve({ returnValue: false, errorText: String(e) }); }
		};
		bridge.call(uri, JSON.stringify(params));
	});
}

function rootExec(command) {
	return luna("luna://org.webosbrew.hbchannel.service/exec", { command: command });
}

function show(cls, text, detail) {
	stateEl.className = cls;
	stateEl.textContent = text;
	detailEl.textContent = detail || "";
}

function refresh() {
	if (busy) return Promise.resolve();
	return rootExec(CMD_STATUS).then(function (res) {
		if (busy) return;
		if (!res.returnValue) {
			running = false;
			show("off", "No root access", res.errorText || "Is the Homebrew Channel elevated?");
			button.disabled = true;
			return;
		}
		var out = (res.stdoutString || "").trim();
		button.disabled = false;
		if (out === "OFF") {
			running = false;
			show("off", "Off");
			button.textContent = "Turn on";
			return;
		}
		running = true;
		button.textContent = "Turn off";
		var status = null;
		try { status = JSON.parse(out); } catch (e) { /* still starting */ }
		if (!status) { show("busy", "Starting…"); return; }
		if (status.BackendState === "Running") {
			show("on", "On", (status.TailscaleIPs || [])[0] + "  ·  " + ((status.Self || {}).HostName || ""));
		} else if (status.BackendState === "NeedsLogin") {
			show("busy", "Needs login", "Run `tailscale --socket=" + SOCK + " up` over SSH");
		} else {
			show("busy", status.BackendState || "Starting…");
		}
	});
}

button.addEventListener("click", function () {
	if (busy) return;
	busy = true;
	button.disabled = true;
	show("busy", running ? "Stopping…" : "Starting…");
	rootExec(running ? CMD_STOP : CMD_START).then(function () {
		setTimeout(function () { busy = false; refresh(); }, 1500);
	});
});

button.focus();
document.addEventListener("keydown", function () { button.focus(); });
document.addEventListener("webOSRelaunch", refresh);
refresh();
setInterval(function () { if (!document.hidden) refresh(); }, 3000);
