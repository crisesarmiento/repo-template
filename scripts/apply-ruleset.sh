#!/usr/bin/env bash
# Apply the default-branch ruleset from .github/rulesets/main.json.
# Usage: scripts/apply-ruleset.sh OWNER/REPO [--checks name1,name2] [--dry-run]
#
# Creates the ruleset, or updates it if a ruleset with the same name already
# exists. Status checks are added only when --checks is passed.
# Do not run this against a repository unless the maintainer asked you to.

set -euo pipefail

usage() {
  echo "Usage: $0 OWNER/REPO [--checks name1,name2] [--dry-run]" >&2
  echo "Applies .github/rulesets/main.json. Requires gh and jq." >&2
  echo "If a ruleset with the same name exists, it is updated (PUT), not duplicated." >&2
  echo "Pass --checks to require those status checks (for example: --checks ci,test)." >&2
  echo "Pass --dry-run to print the JSON payload without changing the repository." >&2
  exit 1
}

repo=""
checks=""
checks_provided=0
dry_run=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --checks)
      if [[ $# -lt 2 ]]; then
        echo "error: --checks requires a comma-separated list of check names" >&2
        usage
      fi
      checks="$2"
      checks_provided=1
      shift 2
      ;;
    --checks=*)
      checks="${1#--checks=}"
      checks_provided=1
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage
      ;;
    -*)
      echo "error: unknown option: $1" >&2
      usage
      ;;
    *)
      if [[ -n "$repo" ]]; then
        echo "error: unexpected argument: $1" >&2
        usage
      fi
      repo="$1"
      shift
      ;;
  esac
done

if [[ -z "$repo" ]]; then
  usage
fi

if [[ ! "$repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
  echo "error: argument must be OWNER/REPO, got: $repo" >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
ruleset_file="$repo_root/.github/rulesets/main.json"

if [[ ! -f "$ruleset_file" ]]; then
  echo "error: ruleset file not found: $ruleset_file" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh is required" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq is required" >&2
  exit 1
fi

if ! jq -e . "$ruleset_file" >/dev/null; then
  echo "error: invalid JSON in $ruleset_file" >&2
  exit 1
fi

ruleset_name="$(jq -r '.name' "$ruleset_file")"
if [[ -z "$ruleset_name" || "$ruleset_name" == "null" ]]; then
  echo "error: ruleset file is missing a name: $ruleset_file" >&2
  exit 1
fi

checks_json='[]'
if [[ "$checks_provided" -eq 1 ]]; then
  checks_json="$(printf '%s' "$checks" | jq -Rc '
    split(",")
    | map(gsub("^\\s+|\\s+$"; ""))
    | map(select(. != ""))
  ')"
  if [[ "$(printf '%s' "$checks_json" | jq 'length')" -eq 0 ]]; then
    echo "error: --checks requires at least one non-empty check name" >&2
    exit 1
  fi
fi

payload="$(jq --argjson checks "$checks_json" '
  if ($checks | length) > 0 then
    .rules += [
      {
        type: "required_status_checks",
        parameters: {
          strict_required_status_checks_policy: true,
          do_not_enforce_on_create: false,
          required_status_checks: ($checks | map({context: .}))
        }
      }
    ]
  else
    .
  end
' "$ruleset_file")"

payload_file="$(mktemp)"
err_file="$(mktemp)"
cleanup() {
  rm -f "$payload_file" "$err_file"
}
trap cleanup EXIT
printf '%s\n' "$payload" >"$payload_file"

is_http_403() {
  grep -qE 'HTTP[[:space:]]403|403[[:space:]]Forbidden|"status"[[:space:]]*:[[:space:]]*403' "$err_file"
}

explain_private_plan() {
  echo "error: cannot manage rulesets on $repo (HTTP 403)." >&2
  echo "Rulesets and branch protection on private repositories require GitHub Pro, Team, or Enterprise." >&2
  echo "A free plan cannot use them (for example research-lab). Keep the same rules in AGENTS.md and do not push to the default branch." >&2
  if [[ -s "$err_file" ]]; then
    echo "GitHub said:" >&2
    cat "$err_file" >&2
  fi
}

# Confirm the repository exists and whether it is private.
# gh writes the API body to stdout and the error summary to stderr.
set +e
repo_json="$(gh api --method GET "repos/$repo" 2>"$err_file")"
repo_status=$?
set -e
if [[ "$repo_status" -ne 0 ]]; then
  echo "error: failed to read repository $repo" >&2
  cat "$err_file" >&2
  exit 1
fi

private="$(printf '%s' "$repo_json" | jq -r '.private')"
if [[ "$private" == "true" ]]; then
  echo "warning: $repo is private. Rulesets and branch protection on private repositories require GitHub Pro, Team, or Enterprise. A free plan cannot use them (for example research-lab). Trying the ruleset API anyway in case this account's plan allows it." >&2
fi

set +e
rulesets_json="$(gh api --method GET --paginate "repos/$repo/rulesets?includes_parents=false" 2>"$err_file")"
list_status=$?
set -e
if [[ "$list_status" -ne 0 ]]; then
  if [[ "$private" == "true" ]] && is_http_403; then
    explain_private_plan
    exit 1
  fi
  echo "error: failed to list rulesets for $repo" >&2
  cat "$err_file" >&2
  exit 1
fi

existing_id="$(printf '%s' "$rulesets_json" | jq -r --arg name "$ruleset_name" '
  (if type == "array" then . else [.] end)
  | map(select(.name == $name))
  | .[0].id // empty
')"

if [[ -n "$existing_id" ]]; then
  method="PUT"
  path="repos/$repo/rulesets/$existing_id"
  action="update"
else
  method="POST"
  path="repos/$repo/rulesets"
  action="create"
fi

rollback_cmd="gh api --method DELETE repos/$repo/rulesets/<id>"
if [[ -n "$existing_id" ]]; then
  rollback_cmd="gh api --method DELETE repos/$repo/rulesets/$existing_id"
fi

if [[ "$dry_run" -eq 1 ]]; then
  echo "dry-run: would $action ruleset '$ruleset_name' on $repo via $method $path"
  printf '%s\n' "$payload" | jq .
  echo "rollback: $rollback_cmd"
  exit 0
fi

set +e
result_json="$(gh api --method "$method" "$path" --input "$payload_file" 2>"$err_file")"
apply_status=$?
set -e
if [[ "$apply_status" -ne 0 ]]; then
  if [[ "$private" == "true" ]] && is_http_403; then
    explain_private_plan
    exit 1
  fi
  echo "error: failed to $action ruleset '$ruleset_name' on $repo" >&2
  cat "$err_file" >&2
  exit 1
fi

applied_id="$(printf '%s' "$result_json" | jq -r '.id')"
if [[ -z "$applied_id" || "$applied_id" == "null" ]]; then
  echo "error: GitHub did not return a ruleset id after the $action" >&2
  printf '%s\n' "$result_json" >&2
  exit 1
fi

echo "Applied ruleset '$ruleset_name' (id $applied_id) on $repo ($action)."
echo "rollback: gh api --method DELETE repos/$repo/rulesets/$applied_id"
