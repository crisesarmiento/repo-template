# Agent notes

Replace the command placeholders with this repository's real install, build,
lint, and test commands. Keep this file accurate; agents and humans rely on it.

## Commands

```bash
# Install
# <install command, e.g. npm install>

# Lint
# <lint command, e.g. npm run lint>

# Test
# <test command, e.g. npm test>

# Build
# <build command, e.g. npm run build>
```

## Rules

- One issue = one branch = one small pull request.
- Never push to the default branch (`main`, or `develop` if that is the
  working branch). Open a PR instead.
- Do not force-push to the default branch, and do not delete it.
- Do not commit secrets, credentials, `.env` files, tokens, private keys, or
  unredacted logs.
- Do not install tools, dependencies, or services unless the issue or the
  maintainer asked for them.
- Stay inside the issue's scope. If the work grows, stop and open another
  issue.
- Run lint and tests before opening or updating a PR. Do not weaken, skip, or
  delete tests just to go green.
- Use conventional commit messages (`feat:`, `fix:`, `docs:`, `test:`,
  `chore:`).
- Squash merge only, after CI is green and the maintainer accepts the PR.

## Branch protection

If this repository cannot enable a ruleset (for example a private repository
on a free personal plan), the rules above still apply: required PR, green CI,
no force-push, no deletion of the default branch, squash merge, and a linear
history.
