---
layout: doc
permalink: /docs/
title: Documentation
lede: The Darkian Studio docs cover installing, using, and troubleshooting DS, plus how its runtime bridge works and how it compares to VS Code, Acode, and Roxum.
description: "Darkian Studio documentation: getting started, architecture, troubleshooting, and comparisons with VS Code, Acode, and Roxum."
---

Darkian Studio (DS) is a real, mobile-first IDE for Android and Linux. Editor, terminal, LSP, debugging, git, AI chat, and local offline AI models all run against one runtime reached over a bridge. Start with install, then take the getting-started tour.

## Get set up

- **[Install]({{ '/install/' | relative_url }})** — install Termux, download the beta APK, run one setup command, verify.
- **[Getting started]({{ '/docs/getting-started/' | relative_url }})** — a first-run tour: open a project, use the terminal, edit with LSP, debug, and run git.

## Understand it

- **[Architecture]({{ '/docs/architecture/' | relative_url }})** — how one runtime serves the editor, terminal, LSP, debugger, git, and extensions over a bridge.
- **[AI features]({{ '/docs/ai/' | relative_url }})** — the chat agent, local GGUF models run fully offline, inline completions, and MCP.
- **[GitHub workspaces]({{ '/docs/github/' | relative_url }})** — open a repository on GitHub without cloning it: sign in, pick a branch, and edit and commit straight against it.
- **[dsterm]({{ '/docs/dsterm/' | relative_url }})** — the open-source Rust runtime bridge DS connects to: PTY, LSP/DAP/MCP/extension-host bridges, and command execution.

## Fix it

- **[Troubleshooting]({{ '/docs/troubleshooting/' | relative_url }})** — diagnostics logs, crash reports, what to include in a bug report, and known limitations.

## Compare it

- **[DS vs VS Code]({{ '/docs/vs-vscode/' | relative_url }})** — mobile-first runtime bridge versus a desktop-first editor with the full `vscode` API.
- **[DS vs Acode]({{ '/docs/vs-acode/' | relative_url }})** — one shared runtime for everything versus a mobile editor with a focused PTY/LSP backend.
- **[DS vs Roxum]({{ '/docs/vs-roxum/' | relative_url }})** — a bridge-runtime IDE with DAP/debugging and Open VS X extensions versus a native-Rust-editor Android IDE with on-device AI.

## Also useful

- **[FAQ]({{ '/faq/' | relative_url }})** — direct answers to the most common questions.
- **[Changelog]({{ '/changelog/' | relative_url }})** — what shipped in each release.
- **[GitHub Releases]({{ site.releases_url }})** · **[Report a bug]({{ site.bug_report_url }})** · **[Discussions]({{ site.discussions_url }})**
