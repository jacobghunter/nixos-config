#!/usr/bin/env bash
# Copies perf.css into the installed OpenHome and links it after its own
# stylesheets. Safe to re-run; run again after every OpenHome update.
# Undo: ssh tv, delete css/perf.css and the perf.css <link> line in index.html.
set -euo pipefail
cd "$(dirname "$0")"

TV=${TV:-tv}
APP=/media/developer/apps/usr/palm/applications/io.github.devic021.openhome

scp -q perf.css "$TV:$APP/css/perf.css"
ssh "$TV" "
	grep -q 'css/perf.css' $APP/index.html ||
		sed -i '/css\/editorial.css/a <link rel=\"stylesheet\" href=\"css/perf.css\">' $APP/index.html
	grep -n 'css/perf.css' $APP/index.html
"
echo "Applied. Relaunch OpenHome (press Home) to load it."
