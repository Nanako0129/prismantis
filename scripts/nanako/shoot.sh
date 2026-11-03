#!/bin/bash
# usage: shoot.sh <checkout> <name> <cols> <rows> '<options json>' '<steps json>'
# Installs the checkout into the persistent screenshot config (~/.claude-shots, logged in once by hand)
# with those prismantis options, drives a hidden Claude Code session through the steps (cwd $SHOT_CWD, default ~),
# and renders what it drew to <name>.png with xterm.js in headless Chrome.
set -euo pipefail
repo=$(cd "$1" && pwd -P); name=$2; cols=$3; rows=$4; opts=$5; steps=$6
root=${SHOTS_DIR:-$HOME/.cache/prismantis-shots}; mkdir -p "$root"; here=$(cd "$(dirname "$0")" && pwd)
C=$HOME/.claude-shots; M="$root/mkt"; X="$root/node_modules/@xterm/xterm"; HERE="$repo/.claude/skills/live-check"
cwd=${SHOT_CWD:-$HOME}
[ -x "$root/crop" ] || swiftc -O "$here/crop.swift" -o "$root/crop"
[ -d "$X" ] || npm i -s --prefix "$root" @xterm/xterm >/dev/null
export CLAUDE_CONFIG_DIR="$C"
claude plugin marketplace remove drive >/dev/null 2>&1 || true
rm -rf "$M" && mkdir -p "$M/.claude-plugin"
rsync -a --exclude .git --exclude node_modules "$repo/" "$M/prismantis/"
echo '{"name":"drive","owner":{"name":"drive"},"plugins":[{"name":"prismantis","source":"./prismantis"}]}' >| "$M/.claude-plugin/marketplace.json"
claude plugin marketplace add "$M" >/dev/null
claude plugin install prismantis@drive >/dev/null
others=$(cd "$C/plugins/cache" && for m in *; do [ "$m" = drive ] && continue; for p in "$m"/*; do [ -d "$p" ] && printf '%s@%s\n' "${p#*/}" "$m"; done; done | jq -R . | jq -s 'map({(.): false}) | add // {}')
jq --argjson o "$opts" --argjson off "$others" '.pluginConfigs["prismantis@drive"].options = $o | .enabledPlugins = ($off + {"prismantis@drive": true}) | .statusLine = {"type": "command", "command": "printf \" \""} | .spinnerTipsEnabled = false' "$C/settings.json" >| "$C/settings.tmp" && mv "$C/settings.tmp" "$C/settings.json"
perl -e 'alarm shift; exec @ARGV' 240 python3 "$here/capture_snap.py" "$root/$name.bin" "$cwd" "$cols" "$rows" "$steps" env -u CLAUDE_CODE_PLUGIN_DIRS -u CLAUDE_CODE_CHILD_SESSION claude "${@:7}" >/dev/null 2>&1 || echo "capture exited $?" >&2
[ -s "$root/$name.bin" ] || { echo "no capture for $name" >&2; exit 1; }
rm -f "$root/$name.png"
node "$HERE/render.mjs" "$root/$name.bin" "$root/$name.png" "$cols" "$rows" "$X" >/dev/null 2>&1 || [ -s "$root/$name.png" ]
for i in ${SNAPS:-}; do node "$HERE/render.mjs" "$root/$name.bin.$i" "$root/$name.$i.png" "$cols" "$rows" "$X" >/dev/null; echo "$root/$name.$i.png"; done
echo "$root/$name.png"
