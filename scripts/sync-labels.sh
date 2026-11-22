#!/usr/bin/env bash
# Apply the standard labels from .github/labels.yml to a repository.
# Usage: scripts/sync-labels.sh OWNER/REPO
#
# Creates or updates labels with `gh label create --force`.
# Does not delete existing labels.
# Do not run this against a repository unless the maintainer asked you to.

set -euo pipefail

usage() {
  echo "Usage: $0 OWNER/REPO" >&2
  echo "Applies labels from .github/labels.yml using: gh label create --force" >&2
  echo "Does not delete existing labels." >&2
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

repo="$1"
if [[ ! "$repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
  echo "error: argument must be OWNER/REPO, got: $repo" >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
labels_file="$repo_root/.github/labels.yml"

if [[ ! -f "$labels_file" ]]; then
  echo "error: labels file not found: $labels_file" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh is required" >&2
  exit 1
fi

# Parse the simple labels.yml subset (list of name/color/description maps)
# using Python's standard library only.
eval "$(python3 - "$labels_file" << 'ENDPARSE'
import re, shlex, sys
from pathlib import Path

text = Path(sys.argv[1]).read_text(encoding="utf-8")
items = []
current = None
for lineno, raw in enumerate(text.splitlines(), 1):
    line = raw.split("#", 1)[0].rstrip()
    if not line.strip():
        continue
    if line.startswith("- "):
        if current:
            items.append(current)
        current = {}
        line = "  " + line[2:]
    match = re.match(r"^\s*([A-Za-z0-9_]+):\s*(.*)$", line)
    if not match or current is None:
        raise SystemExit(f"unparsed line {lineno}: {raw}")
    key, value = match.group(1), match.group(2).strip()
    if (value.startswith('"') and value.endswith('"')) or (value.startswith("'") and value.endswith("'")):
        value = value[1:-1]
    current[key] = value
if current:
    items.append(current)

for index, item in enumerate(items):
    missing = [key for key in ("name", "color", "description") if not item.get(key)]
    if missing:
        raise SystemExit(f"label {index} missing fields: {', '.join(missing)}")
    print(f"LABELS_{index}_NAME={shlex.quote(item['name'])}")
    print(f"LABELS_{index}_COLOR={shlex.quote(item['color'])}")
    print(f"LABELS_{index}_DESCRIPTION={shlex.quote(item['description'])}")
print(f"LABEL_COUNT={len(items)}")
ENDPARSE
)"

if [[ "${LABEL_COUNT:-0}" -eq 0 ]]; then
  echo "error: no labels parsed from $labels_file" >&2
  exit 1
fi

echo "Applying ${LABEL_COUNT} labels to $repo"
for ((i = 0; i < LABEL_COUNT; i++)); do
  name_var="LABELS_${i}_NAME"
  color_var="LABELS_${i}_COLOR"
  desc_var="LABELS_${i}_DESCRIPTION"
  name="${!name_var}"
  color="${!color_var}"
  description="${!desc_var}"
  echo "  $name"
  gh label create "$name" --repo "$repo" --color "$color" --description "$description" --force
done

echo "Done. Unused GitHub default labels can be deleted by hand."
