# System Changes

Do not make changes outside the current project that affect the machine or the user account. Such changes outlive the task, affect unrelated projects, and are hard to audit or undo.

This covers:
- Installing, upgrading, or removing software outside the project: `brew`, `npm -g`, `pip install --user`, `pipx`, `cargo install`, `go install`, `uv tool`, installer scripts (`curl ... | sh`), and anything run with `sudo`.
- Changing user or system configuration: shell rc files, `git config --global`, `~/.ssh`, `~/.aws`, `defaults write`, `launchctl`, `/etc`, global package-manager settings.

Allowed without asking:
- Dependencies scoped to the project (e.g. `npm install` in the project, a virtualenv inside the project).
- Read-only checks (`command -v`, `brew list`, `git config --global --get`).

Do not work around this rule: don't download binaries and run them from a temp directory, and don't use `npx`, `uvx`, or `pipx run` for tools that aren't already installed.

When a task cannot be completed without such a change:
1. Stop before making it.
2. Give the user the exact command, what it changes, and how to undo it.
3. Wait. Continue only after the user confirms they ran it, or explicitly tells you to run it.

Approval applies to that single command only. It does not carry over to later changes, even similar ones.
