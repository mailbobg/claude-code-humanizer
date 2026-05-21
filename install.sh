#!/usr/bin/env bash
#
# Plain output style installer for Claude Code.
# Installs ~/.claude/output-styles/plain.md and sets it as the global default
# in ~/.claude/settings.json.
#
# Usage:
#   ./install.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAIN_SRC="$SCRIPT_DIR/plain.md"
STYLES_DIR="$HOME/.claude/output-styles"
SETTINGS_FILE="$HOME/.claude/settings.json"

if [ ! -f "$PLAIN_SRC" ]; then
  echo "Error: plain.md not found next to this script." >&2
  echo "Expected at: $PLAIN_SRC" >&2
  exit 1
fi

mkdir -p "$STYLES_DIR"
cp "$PLAIN_SRC" "$STYLES_DIR/plain.md"
echo "✓ Installed style: $STYLES_DIR/plain.md"

if [ ! -f "$SETTINGS_FILE" ]; then
  mkdir -p "$(dirname "$SETTINGS_FILE")"
  printf '{\n  "outputStyle": "plain"\n}\n' > "$SETTINGS_FILE"
  echo "✓ Created $SETTINGS_FILE with outputStyle: plain"
else
  cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak"
  python3 - "$SETTINGS_FILE" <<'PYEOF'
import json, sys
path = sys.argv[1]
try:
    with open(path) as f:
        data = json.load(f)
    if not isinstance(data, dict):
        data = {}
except (json.JSONDecodeError, FileNotFoundError):
    data = {}
prev = data.get("outputStyle")
data["outputStyle"] = "plain"
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
if prev and prev != "plain":
    print(f"✓ Updated outputStyle: {prev} → plain (backup: {path}.bak)")
elif prev == "plain":
    print("✓ outputStyle already set to plain")
else:
    print(f"✓ Set outputStyle: plain in {path} (backup: {path}.bak)")
PYEOF
fi

echo ""
echo "Done. Start a new Claude Code session — or run /clear in an existing one — to activate."
echo "Verify with: /output-style  (should show 'plain' selected)"
