#!/usr/bin/env bash
#
# Plain output style uninstaller for Claude Code.
# Removes ~/.claude/output-styles/plain.md and removes the outputStyle key
# from ~/.claude/settings.json (or restores .bak if present).
#
# Usage:
#   ./uninstall.sh
#

set -euo pipefail

STYLES_DIR="$HOME/.claude/output-styles"
STYLE_FILE="$STYLES_DIR/plain.md"
SETTINGS_FILE="$HOME/.claude/settings.json"
SETTINGS_BAK="${SETTINGS_FILE}.bak"

# 1. Remove the style file
if [ -f "$STYLE_FILE" ]; then
  rm "$STYLE_FILE"
  echo "✓ Removed $STYLE_FILE"
else
  echo "• $STYLE_FILE not found (skipping)"
fi

# 2. Revert settings.json
if [ -f "$SETTINGS_BAK" ]; then
  # Prefer restoring the backup left by install.sh — most faithful
  mv "$SETTINGS_BAK" "$SETTINGS_FILE"
  echo "✓ Restored $SETTINGS_FILE from backup"
elif [ -f "$SETTINGS_FILE" ]; then
  # No backup — strip the outputStyle key in-place
  python3 - "$SETTINGS_FILE" <<'PYEOF'
import json, sys, os
path = sys.argv[1]
try:
    with open(path) as f:
        data = json.load(f)
    if not isinstance(data, dict):
        print(f"• {path} is not a JSON object; leaving untouched")
        sys.exit(0)
except (json.JSONDecodeError, FileNotFoundError):
    print(f"• {path} unreadable; leaving untouched")
    sys.exit(0)

prev = data.pop("outputStyle", None)
if prev is None:
    print(f"• outputStyle key not in {path} (nothing to remove)")
    sys.exit(0)

if prev != "plain":
    # Was set to something else — restore it, don't silently strip
    data["outputStyle"] = prev
    print(f"• outputStyle was '{prev}', not 'plain' — leaving as is")
    sys.exit(0)

if data:
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    print(f"✓ Removed outputStyle key from {path}")
else:
    os.remove(path)
    print(f"✓ Removed {path} (became empty)")
PYEOF
else
  echo "• $SETTINGS_FILE not found (skipping)"
fi

echo ""
echo "Done. Start a new Claude Code session — or run /clear — to apply."
