# Security policy

## Report a vulnerability privately

Do **not** open a public issue or pull request to disclose a suspected
vulnerability.

Use this repository's private vulnerability reporting form:

**Security → Advisories → Report a vulnerability**

On GitHub, that form lives at:

`https://github.com/<owner>/<repo>/security/advisories/new`

Replace `<owner>` and `<repo>` with this repository's owner and name. A GitHub
account is required. Reports are shared privately with the repository's
security maintainers rather than posted as public issues.

If the form is unavailable, do not post sensitive details publicly. You may
open a minimal issue asking the maintainer to restore the private reporting
channel, without describing the vulnerability. There is no email contact for
security or conduct reports.

## What to include

- The affected release or commit, operating system, and relevant component.
- Expected versus observed behavior, likely impact, and affected trust boundary.
- Minimal reproduction steps using synthetic data in an environment you control.
- A suggested mitigation, if known.

Do not include tokens, credentials, credential files, private configuration,
or unredacted user data, even in a private report. If a credential has been
exposed, revoke or rotate it through the provider; do not send the credential
to the maintainer.

A report is welcome even if you are unsure whether it is a security issue.

## Testing and coordinated disclosure

Test only local instances or systems you own or are explicitly authorized to
test. This policy does not grant access to other systems and does not authorize
disruptive testing or data collection.

The maintainer will assess the report and coordinate fixes and disclosure
through the private advisory. Please keep vulnerability details private while a
fix and publication plan are discussed. There is no guaranteed response or
remediation deadline, and no bounty program is offered by this policy.

## Versions and fixes

Include the exact version or commit in your report. Fix targets are determined
during triage. Released fixes are documented in release notes and, when
appropriate, a published security advisory.

For ordinary non-security bugs and feature proposals, use the public issue
forms described in [CONTRIBUTING.md](CONTRIBUTING.md).
