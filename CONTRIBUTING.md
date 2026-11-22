# Contributing

Thanks for wanting to help. Please read this guide before opening an issue or
a pull request. By participating, you agree to follow the
[Code of Conduct](CODE_OF_CONDUCT.md).

Security vulnerabilities should be reported privately. See
[SECURITY.md](SECURITY.md). Do not open a public issue for a vulnerability.

## Workflow

1. **Open or pick an issue** using the Bug, Feature, or Decision templates.
   Discuss the work there before writing a large change.
2. **Create a branch** from the default branch (`main`, or `develop` if that
   is the working branch). One issue = one branch = one small pull request.
3. **Make a small, focused change.** If the work grows, split it into another
   issue and another PR.
4. **Run lint and tests locally** and fix failures before opening the PR.
5. **Open a pull request** using the PR template. Link the issue with
   `Closes #N`.
6. **Squash merge** only, once review and CI are green. The branch should be
   deleted after the merge.

Do not push commits to the default branch. Do not force-push to shared
branches except when asked to rebase a feature branch.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:`, `fix:`, `docs:`, `test:`, `chore:`, `refactor:`, `ci:`

Keep the subject short and in the imperative mood, for example
`fix: handle empty input in the parser`.

## Pull requests

The PR description should say:

- What changed and why, and the issue it closes.
- How you tested it, including the exact commands and their results.
- Whether docs need an update, and whether any tests were changed or removed.

Checklist (also in the PR template):

- [ ] Lint and tests were run locally and are green.
- [ ] CI is green.
- [ ] Scope stays inside the issue.
- [ ] No secrets, credentials, or private data are committed.
- [ ] Screenshots or a short recording are included for UI changes.

## Decisions

Some changes need an explicit decision first (for example a public API, a
default, or a scope change). Open a Decision issue with options A, B, and C,
tradeoffs, and a recommendation. Do not implement the change until the
decision is approved.
