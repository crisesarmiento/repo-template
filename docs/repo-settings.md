# Repository settings and local git identity

This document describes settings to apply **by hand, with the scripts in this
repository, or with `gh api` after the repository exists**, and how to set the
git author **inside each personal repository**. Do not run the commands below
until the maintainer has approved them for a named repository. They are not
applied by creating a repo from this template.

Replace `OWNER/REPO` with the repository, and `DEFAULT_BRANCH` with `main`
(or `develop` if that is the working branch).

## 1. Merge and repository options

In the GitHub UI: **Settings → General**.

- Default branch: `main`, or `develop` if the project works on `develop`.
- Allow **squash merging** only. Disable merge commits and rebase merges.
- Enable **automatically delete head branches**.
- Description: one line.
- Topics: 3 to 8 topics.
- Wikis: off.
- Discussions: on for public repositories (categories: Q&A, Ideas, Show and
  tell). Off for private repositories unless they are needed.
- For this template repository itself, enable **Template repository**.

Equivalent API (do not run until approved):

```bash
gh api --method PATCH repos/OWNER/REPO \
  -f description='One-line description' \
  -f has_wiki=false \
  -f has_discussions=true \
  -f allow_squash_merge=true \
  -f allow_merge_commit=false \
  -f allow_rebase_merge=false \
  -f delete_branch_on_merge=true \
  -f squash_merge_commit_title='PR_TITLE' \
  -f squash_merge_commit_message='COMMIT_MESSAGES'
```

For a private repository, omit `has_discussions` or set it to `false`.

Add topics:

```bash
gh api --method PUT repos/OWNER/REPO/topics \
  -H "Accept: application/vnd.github+json" \
  -f names[]='topic-one' -f names[]='topic-two'
```

## 2. Branch rules

Preferred over classic branch protection. This template ships a ruleset file
and a script that applies it with `gh`.

The file [`.github/rulesets/main.json`](../.github/rulesets/main.json)
is in the REST format accepted by
`gh api repos/OWNER/REPO/rulesets --input`. It targets the default
branch (`~DEFAULT_BRANCH`), with enforcement set to Active, and
enforces:

- A pull request is required before merging. Approvals are 0, so a solo
  owner can merge their own PR. Stale reviews are dismissed on push. The
  only allowed merge method is squash.
- Force pushes are blocked (`non_fast_forward`).
- The target branch cannot be deleted (`deletion`).

There are no bypass actors. A solo owner does not need a bypass to merge
their own PR, because `required_approving_review_count` is 0. Leaving
`bypass_actors` empty means nobody, including the repository admin, can
push directly to the default branch or skip the pull request rule.

Status checks are not in the base file, because a new repository may not
have CI yet. Pass `--checks` when the checks exist (see below). Linear
history is kept by the squash-only merge setting in the previous section,
together with `allowed_merge_methods: ["squash"]` in the ruleset.

### Apply

Do not run this until the maintainer has approved it for a named
repository.

```bash
scripts/apply-ruleset.sh OWNER/REPO
```

The script uses `gh` for all API calls and `jq` to build the payload.
It is idempotent: if a ruleset named
`Default branch` already exists on the repository, it is updated with
`PUT` instead of creating a duplicate.

To preview the JSON without changing the repository:

```bash
scripts/apply-ruleset.sh OWNER/REPO --dry-run
```

Re-running the script replaces the ruleset with the payload you asked
for. If you previously added status checks, pass `--checks` again when
you re-apply.

### Status checks

When CI exists, add a `required_status_checks` rule with the real check
names and require the branch to be up to date:

```bash
scripts/apply-ruleset.sh OWNER/REPO --checks ci,test
```

Replace `ci,test` with the names that GitHub Actions (or other CI)
actually publishes. You can combine this with `--dry-run`.

### Private repositories

Rulesets and classic branch protection are available on private
repositories only with GitHub Pro, Team, or Enterprise. A free personal
or organization plan can use them on public repositories only.

The script checks whether the repository is private and warns. It then
tries the API anyway, in case the account already has a paid plan. If
GitHub responds with HTTP 403, the script prints the explanation and
exits non-zero. In that case (for example `research-lab` on a free
plan), keep the same rules in `AGENTS.md` and do not push to the default
branch.

### Rollback

After a successful apply, the script prints a delete command with the
ruleset id:

```bash
gh api --method DELETE repos/OWNER/REPO/rulesets/RULESET_ID
```

### Manual alternative

In the UI: **Settings → Rules → Rulesets → New ruleset**. Configure the
same rules as in `.github/rulesets/main.json`. If `allowed_merge_methods`
is rejected by the API, set squash-only in the repository merge settings
instead and omit that parameter.

## 3. Security features

In the UI: **Settings → Code security and analysis** (wording may vary).

- Dependabot version updates: this template already includes
  `.github/dependabot.yml` for GitHub Actions, plus a commented npm example.
  Enable Dependabot security updates as well.
- Secret scanning: on.
- Push protection: on.
- Private vulnerability reporting: on.

Equivalent API (do not run until approved):

```bash
# Private vulnerability reporting
gh api --method PUT repos/OWNER/REPO/private-vulnerability-reporting

# Dependabot alerts (security updates are enabled in the UI or with the
# automated-security-fixes endpoint)
gh api --method PUT repos/OWNER/REPO/vulnerability-alerts
gh api --method PUT repos/OWNER/REPO/automated-security-fixes

# Secret scanning and push protection
gh api --method PATCH repos/OWNER/REPO \
  --input - <<'JSON'
{
  "security_and_analysis": {
    "secret_scanning": { "status": "enabled" },
    "secret_scanning_push_protection": { "status": "enabled" }
  }
}
JSON
```

Public repositories typically have secret scanning available. On a private
repository, some of these features may require a paid plan; if a call fails,
enable what the plan allows and keep the rest as policy in `AGENTS.md` and
`SECURITY.md`.

## 4. Labels, milestones, and the Project

- Apply standard labels: `scripts/sync-labels.sh OWNER/REPO` (only when asked).
  Then delete unused GitHub default labels by hand. Adjust `area:*` labels to
  the repository. On a private repository you may remove `good first issue`
  and `help wanted` if they will not be used.
- Create a milestone per delivery milestone, with a target date.
- Create or link a GitHub Project as described in
  [github-project.md](github-project.md).

## 5. Local git identity (personal repositories only)

Set the author **inside each of Cristian Sarmiento's personal repositories**,
after cloning or creating that repository. Do **not** use `git config --global`. Do **not** use `includeIf`. Employer or client work repositories
must never receive this identity.

On GitHub, enable **Keep my email private** and **Block command line pushes
that expose my email**. The address to use is your GitHub noreply address,
shown under **Settings → Emails** after those options are on. Do not write
that address into files in this repository.

### Backup

Inside the personal repository, save any existing local values (they may be
empty):

```bash
git config --local --get user.name  > /tmp/git-user-name.backup || true
git config --local --get user.email > /tmp/git-user-email.backup || true
```

### Apply (inside the repository, no --global)

```bash
git config user.name 'Cristian Sarmiento'
git config user.email '<your GitHub noreply address>'
```

### Verify

```bash
git config --local --get user.name
git config --local --get user.email
git config --show-origin --get-regexp '^user\.(name|email)$'
```

Confirm that the values come from this repository's `.git/config`, not from
the global config, and that a test commit in a throwaway clone shows the
expected name and noreply address.

### Rollback

```bash
git config --unset user.name
git config --unset user.email
```

To restore previous local values, if the backup files are not empty:

```bash
git config user.name "$(cat /tmp/git-user-name.backup)"
git config user.email "$(cat /tmp/git-user-email.backup)"
```

If this identity was applied by mistake in a work repository, unset it
immediately with the commands above and do not create further commits until
the author is correct.
