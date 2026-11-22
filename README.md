# repo-template

A GitHub template for Cristian Sarmiento's personal repositories
([crisesarmiento](https://github.com/crisesarmiento)). It ships the files and
checklists used to start a repo the same way each time: issue and pull request
templates, standard labels, security docs, and notes for branch rules and a
GitHub Project.

This is a starting point for new personal projects. It is not an official
product of any other organization.

## Use this template

1. On the GitHub page for this repository, choose **Use this template** →
   **Create a new repository**.
2. Pick a name, a visibility (public or private), and the owner
   `crisesarmiento`.
3. Work through the post-creation checklist below. Then replace this README
   with a description of the new project (what it is, how to run it, and its
   status).

To publish this repository itself, enable **Template repository** in its
GitHub settings after it is created. Do not use it as a template until that
flag is on.

## Post-creation checklist

Do these in the new repository (Settings, or the `gh api` commands documented
in [docs/repo-settings.md](docs/repo-settings.md)). Do not run those commands
until the maintainer has approved them for that repository.

- [ ] One-line **description** and **3 to 8 topics**.
- [ ] Default branch is `main`, or `develop` if this project works on
      `develop`.
- [ ] **Ruleset** on the default branch: required pull request, required
      green CI, no force-push, no branch deletion, linear history, squash
      merge only, delete the head branch on merge. See
      [docs/repo-settings.md](docs/repo-settings.md).
- [ ] Apply standard labels: `scripts/sync-labels.sh OWNER/REPO` (only when
      asked). Delete unused GitHub default labels. Adjust `area:*` to the
      project.
- [ ] Enable **Dependabot** (version updates already have
      `.github/dependabot.yml`; also enable security updates) and uncomment
      the npm example if the project uses npm.
- [ ] Enable **secret scanning** and **push protection**.
- [ ] Enable **private vulnerability reporting**.
- [ ] Create **milestones** with target dates.
- [ ] Create or link a **GitHub Project** (Board, Table, and Roadmap). See
      [docs/github-project.md](docs/github-project.md).
- [ ] Fill in the command placeholders in `AGENTS.md`.
- [ ] Set the **local git identity inside this repository only** (no global
      config). See [docs/repo-settings.md](docs/repo-settings.md).
- [ ] Replace this README with the project's own README.

### Public repositories (also)

- [ ] Keep `LICENSE`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and
      `SECURITY.md`.
- [ ] Enable **Discussions** (Q&A, Ideas, Show and tell). Turn the Wiki off.
- [ ] Add a social preview image.
- [ ] If the project is unofficial with respect to another organization, say
      so clearly in the project README.

### Private repositories (differences)

- [ ] Delete `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md`.
- [ ] Delete `LICENSE` unless you plan to open the repository later (no
      license means all rights reserved).
- [ ] Leave Discussions off unless you need them.
- [ ] `SECURITY.md` is optional; keep secret scanning if the plan allows it.
- [ ] On a free personal account, a ruleset on a private repository may be
      unavailable. Check first. If it cannot be enabled, keep the same rules
      in `AGENTS.md`.
- [ ] You may remove the `good first issue` and `help wanted` labels if they
      will not be used.

## What is in this template

| Path | Purpose |
| --- | --- |
| [LICENSE](LICENSE) | MIT, copyright Cristian Sarmiento |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Issue → branch → small PR, squash merge, conventional commits |
| [SECURITY.md](SECURITY.md) | Private vulnerability reporting (no email) |
| [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) | Contributor Covenant 2.1, reports through GitHub |
| [AGENTS.md](AGENTS.md) | Command placeholders and rules for coding agents |
| [.github/ISSUE_TEMPLATE/](.github/ISSUE_TEMPLATE/) | Bug, Feature, and Decision forms; blank issues off |
| [.github/pull_request_template.md](.github/pull_request_template.md) | `Closes #`, what changed, how tested, checklist |
| [.github/dependabot.yml](.github/dependabot.yml) | Weekly GitHub Actions updates; commented npm example |
| [.github/labels.yml](.github/labels.yml) | Standard labels |
| [scripts/sync-labels.sh](scripts/sync-labels.sh) | Apply those labels with `gh label create --force` |
| [docs/github-project.md](docs/github-project.md) | Project views, fields, and automations |
| [docs/repo-settings.md](docs/repo-settings.md) | Rulesets, security settings, and per-repo git identity |

## License

MIT. See [LICENSE](LICENSE).
