# Repository settings and local git identity

This document describes settings to apply **by hand or with `gh api` after
the repository exists**, and how to set the git author **inside each personal
repository**. Do not run the commands below until the maintainer has approved
them for a named repository. They are not applied by creating a repo from this
template.

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

## 2. Ruleset for the default branch

Preferred over classic branch protection. In the UI: **Settings → Rules →
Rulesets → New ruleset**.

Target: the default branch (`~DEFAULT_BRANCH`). Enforcement: Active.

Rules to enable:

- Require a pull request before merging (approvals may be 0 on a
  single-maintainer repo; the point is that direct pushes are blocked).
- Require status checks to pass (name the real CI check, for example `ci`),
  and require the branch to be up to date.
- Block force pushes (`non_fast_forward`).
- Block deletions of the target branch.
- Require a linear history.

Also set squash merge only, as in the previous section. If the ruleset UI
offers allowed merge methods, restrict them to squash.

On a **free personal account**, rulesets may be unavailable for **private**
repositories. Check before relying on them. If they cannot be enabled, keep
the same rules in `AGENTS.md` and do not push to the default branch.

Example API payload (do not run until approved; replace the status check
name). Save the JSON to a file and send it with `gh api --method POST repos/OWNER/REPO/rulesets --input ruleset.json`:

```json
{
  "name": "Default branch",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["~DEFAULT_BRANCH"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": true,
        "required_reviewers": [],
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false,
        "allowed_merge_methods": ["squash"]
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": true,
        "do_not_enforce_on_create": false,
        "required_status_checks": [
          { "context": "ci" }
        ]
      }
    },
    { "type": "non_fast_forward" },
    { "type": "deletion" },
    { "type": "required_linear_history" }
  ]
}
```

If `allowed_merge_methods` is rejected by the API, set squash-only in the
repository merge settings instead and omit that parameter.

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
