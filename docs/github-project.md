# GitHub Project setup

Create one GitHub Project per repository, or one Project for a family of
related repositories. Do this in the GitHub UI after the repository exists.
This document is a checklist, not a script; do not apply it automatically.

Save the Project number and field IDs in a `project-ids.md` file kept by the
bot or person who owns the board, not in this template.

## Views

- **Board**, grouped by Status.
- **Table**, for triage and bulk edits.
- **Roadmap**, organized by Milestone or target date.

## Status

Use this sequence, in this order:

`Backlog` → `Ready` → `In progress` → `In review` → `Done`

Move an item to `Done` only after the work is accepted and, for code changes,
the pull request is merged. Closing an issue without acceptance is not enough
to mark it done by hand if you are still deciding; the automatic workflow
below still moves a closed issue to `Done`, so reopen it if the work was not
accepted.

## Fields

| Field | Type | Values |
| --- | --- | --- |
| Priority | Single select | P1, P2, P3 |
| Area | Single select | Values chosen per repository (for example UI, Data, CI) |
| Size | Single select | XS, S, M, L |
| Owner/Bot | Single select or text | Who reviews or owns the item |
| Decision | Single select | Proposed, Approved, Rejected |
| Milestone / Hito | Milestone, or a linked milestone | The delivery milestone |
| Target date | Date | Optional target for the item |

The **Decision** field supports a rule like "a Decision must be Approved
before implementation." Open a Decision issue first, set the field to
Proposed, and start work only after it is Approved.

## Automations (Project workflows)

Enable these built-in workflows:

- Item added to the Project → set Status to `Backlog`.
- Pull request merged → set Status to `Done`.
- Issue closed → set Status to `Done`.
- Auto-add issues and pull requests from the linked repository.

## After creating the Project

1. Link the repository (or each repository in the family).
2. Add the fields and views above.
3. Enable the workflows.
4. Record the Project number and GraphQL field IDs in the owner's
   `project-ids.md`.
