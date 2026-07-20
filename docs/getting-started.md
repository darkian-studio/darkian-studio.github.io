---
layout: doc
permalink: /docs/getting-started/
title: Getting started
lede: After install, Darkian Studio walks the same path as any IDE — open a project, use the terminal, edit with LSP, run a debugger, and commit with git — all against one runtime.
description: "A first-run tour of Darkian Studio after install: opening a project, the terminal, your first LSP-powered edit, a first debug session, and a first git action."
---

This tour assumes you've finished [install]({{ '/install/' | relative_url }}) and that **Verify setup** reports the runtime is ready. Everything below runs against that one runtime, so the terminal, language servers, and debugger all share the same `PATH`, filesystem, and installed SDKs.

> Screenshots and GIFs are placeholders for now and will be added as the beta matures.

## 1. Open a project

DS works against a workspace root — a folder in your runtime. Open an existing folder in Termux (or your runtime host), or clone one with git first (see step 5). Once opened, the file tree, editor, and terminal all point at that same directory.

## 2. Use the terminal

The integrated terminal is a full shell through your runtime — Termux on Android. Anything you install here (a language toolchain, a formatter, a language server) is immediately visible to the editor, LSP, and debugger, because they all share the runtime. That's the point of the one-runtime model.

## 3. Make your first LSP-powered edit

Open a source file in a language whose server is available in the runtime. DS's built-in LSP client provides completion, hover, signature help, go-to-definition/references, rename, formatting, code actions, and diagnostics. If a language server isn't installed yet, install it in the terminal (step 2), then reopen the file.

## 4. Start your first debug session

DS debugs through the Debug Adapter Protocol (DAP): it bridges to a debug adapter running in your runtime and renders breakpoints, variable inspection, watch expressions, the call stack, and a debug console. Set a breakpoint in the gutter, start a session, and step through your code.

## 5. Make your first git action

DS provides git as a dedicated panel: clone, stage, commit, push, pull, stash, branch, resolve conflicts, and view blame — all operating against the runtime's git. Clone a repo to create a workspace, make a change, then stage and commit it.

## Where to go next

- **[Architecture]({{ '/docs/architecture/' | relative_url }})** — why any machine with a terminal can act as DS's backend.
- **[Troubleshooting]({{ '/docs/troubleshooting/' | relative_url }})** — if a step above didn't work.
- **[FAQ]({{ '/faq/' | relative_url }})** — quick answers to common questions.
