---
layout: doc
permalink: /docs/github/
title: GitHub workspaces
lede: Open any GitHub repository as a workspace without cloning it. Sign in with GitHub, pick a repo and a branch, and DS reads and commits straight against the branch through GitHub's APIs.
description: "Work with a GitHub repository as a Darkian Studio workspace: sign in, browse public/private repos, pick a branch, edit and commit directly against it — no local clone needed."
---

A GitHub workspace lets you work with a repository on GitHub without copying it to your device. Files are not downloaded: DS talks to the repository's branch through GitHub's Contents and Git Data APIs, so you can browse, edit, search, run the git panel, and trigger GitHub Actions directly.

## Open a repository

1. On the **Welcome** screen, tap **GitHub**.
2. Sign in with your GitHub account. DS uses a standard OAuth flow in your browser — the token is exchanged and stored on the device; it never ships in the app.
3. Browse or search your repositories. Both **public and private** repos you have access to are listed.
4. Pick a repository, then pick the branch you want to work on.

The repository opens as a workspace. The file tree, editor, and git panel all point at that branch, and every file URI is stable — [switching branches](#git-panel) keeps the files you are viewing valid.

## Edit and commit

Edits are kept locally in the app and are only written to the remote branch when you **commit**. That means nothing on GitHub changes until you explicitly commit your work.

- **File tree and search** — browse the whole repository, open files, edit, create, rename, and delete. Search and grep run against the workspace without a local clone.
- **Commit** — the git panel computes your changes against the branch head, commits them through the Git Data API, and lands them directly on the branch. Because commits are written straight to GitHub, there is no separate push step.
- **Pull the latest** — not available: branch contents are fetched when the workspace is opened. If the branch has moved since then, a commit is refused until you re-open the workspace to re-sync.

## Git panel

The git panel works against your GitHub workspace, with a few intentional differences from a local checkout:

- Supporting the same actions as a local repo: view the change list and recent commits, stage changes, commit, switch branches, and discard per-file edits.
- **Pull is never allowed**: there is nothing to merge locally — your edits already live on the remote branch, so pulling would discard them. Re-open the workspace to see the latest instead.
- **Stash, remotes, and conflict-resolution UI are not available** in a GitHub workspace — the panel simply doesn't offer them.
- Switching branches is all-or-nothing: commit or discard your pending changes first, then switch. 
- If the remote branch has moved since the workspace was opened, your commit is refused — re-open the workspace to sync, then commit again.

## GitHub Actions

A small Actions panel sits behind the git panel: list the repository's workflows, see recent runs, trigger a manual `workflow_dispatch` run on the current branch, open a workflow file from its path, and drill into a run's jobs and logs with one-tap copy.

## Notes

- **Nothing is cloned or stored locally.** Editor features that depend on a local file — the runtime terminal, LSP-based language intelligence (completion, hover, diagnostics), and the debugger — operate against your runtime's filesystem, so they don't see a GitHub workspace. If you need those, clone the repository with git in the terminal and open the folder instead.
- The workspace reflects the branch you opened. To follow someone else's changes, re-open the workspace.
- Your files, edits, searches, git actions, and Actions runs all go through your signed-in GitHub account, so the same trust rules as the terminal apply — and your token stays on the device.