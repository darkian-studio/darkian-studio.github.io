---
layout: doc
permalink: /docs/vs-acode/
title: Darkian Studio vs Acode
lede: Acode is a lightweight, open-source Android editor with a focused PTY/LSP backend; Darkian Studio is a mobile-first IDE whose editor, terminal, LSP, debugger, git, and extensions all run against one shared runtime over a bridge. Choose DS for built-in language intelligence and DAP debugging; choose Acode for a fast, minimal, Play Store-available editor.
description: "Darkian Studio vs Acode: one shared runtime for editor, LSP, debugger, and extensions versus a lightweight Android editor with a focused PTY/LSP backend. Architecture and a feature-by-feature table."
---

> Versions compared: Darkian Studio 1.0.0-beta (first public beta, July 2026) and Acode 1.12.6 (released June 18, 2026). DS capabilities were verified against the application and its runtime (`dsterm`); Acode capabilities were verified against the Acode and `acodex_server` (`axs`) source repositories.

## At a glance

| | Darkian Studio | Acode |
|---|---|---|
| Focus | Full mobile IDE (editor + LSP + debugger + git + extensions) | Lightweight mobile code editor |
| Runtime bridge | `dsterm`: PTY, LSP, DAP, extension host, execution | `axs`: PTY + stdio→WS LSP proxy |
| Language intelligence | Built-in LSP client | LSP installed as plugins |
| Debugging | DAP (breakpoints, variables, watch, call stack) | Interactive JS console only |
| Extensions | Open VS X (VS Code-compatible, partial API) | Community JS plugins |
| Distribution | GitHub Releases APK (beta) | Play Store, F-Droid, GitHub (MIT) |

## Executive summary

Acode is a lightweight, open-source code editor and web IDE for Android, built on the Ace editor. It is designed for editing and managing code on a phone, with a terminal backed by a Rust PTY server (`axs`), Git/SSH support, and a community plugin store. Darkian Studio is a mobile-first development environment that runs on Android and Linux. Its editor, terminal, language intelligence, debugger, Git, and extensions all operate against one runtime reached through `dsterm`, a Rust server that bridges PTY, language servers, debug adapters, and an extension host over a single port. The two tools share the Android stage but differ in architecture: Acode layers IDE conveniences on top of a mobile editor, while DS routes every core function through one runtime abstraction.

## How each tool works

```
Developer
  ↓
Editor (Ace in Acode; web editor in DS)
  ↓
Runtime bridge (Acode plugin layer → axs; DS → dsterm)
  ↓
Runtime (the shell environment axs / dsterm talks to)
  ↓
Git / LSP / terminal  (DS also routes debugger and extensions here)
```

| | Acode | Darkian Studio |
|---|---|---|
| Editing | Ace editor (in-app web view) | Code editor (in-app web view) |
| Runtime bridge | `axs` (Rust): PTY over WebSocket + stdio→WS LSP proxy | `dsterm` (Rust): PTY, LSP bridge, DAP bridge, extension-host bridge, execution |
| Runtime | `axs` talks to the shell it is configured to reach (e.g. Alpine via proot) | Termux on Android, or a `dsterm` host on Linux/macOS |
| Language intelligence | LSP installed as plugins, bridged to `axs` | Built-in LSP client against runtime or extension-host servers |
| Debugger | Interactive JavaScript console only | DAP bridge to debug adapters in the runtime |
| Extensions | Acode community plugins (JavaScript addons) | Open VS X extensions run through a `vscode`-API host |

## Architectural differences

### Runtime bridge scope

`axs` (the backend Acode uses) is a focused Rust server: it serves a PTY over WebSocket and, as a separate subcommand, proxies a stdio language server to WebSocket. It does not itself host a debugger, an extension host, or Git; those live in the Acode app and talk to `axs` only for the terminal and the LSP transport.

`dsterm` (the backend DS uses) is a broader Rust server. Beyond the PTY and an LSP bridge, it also exposes a DAP bridge (proxy to any Debug Adapter Protocol server), an extension-host bridge, a Model Context Protocol bridge, and silent/streaming command execution. Crucially, `dsterm` is a multiplexed endpoint rather than a collection of unrelated bridges: every feature is reached through one connection, which is why the terminal, language servers, debugger, extension host, and command execution all share a single runtime session.

### One runtime for everything

In DS, the editor, terminal, Git, LSP servers, debugger, and extensions all share one environment: the same `PATH`, filesystem, environment variables, installed SDKs, and interpreter. A package you install in the terminal is visible to the language server and the debugger without extra configuration. In Acode, the terminal and an LSP server can run in the same `axs` environment, but the debugger is only the in-editor JavaScript console, and extensions are separate JavaScript addons that don't share a single hosted runtime the way DS's extension host does.

### Language intelligence

Acode provides completion and IntelliSense via LSP through community plugins — you install and configure a language server per language. Darkian Studio includes a **built-in** LSP client: completion, hover, signature help, go-to-definition/references/implementation, rename, formatting, code actions, diagnostics, folding, semantic tokens, and inlay hints, handled against language servers running in the runtime or the extension host. In both, the language servers themselves still need to be available in the runtime.

### Debugging

Acode offers an interactive JavaScript console for evaluating and debugging JS — a single useful feature, not a general debugger. Darkian Studio debugs through the Debug Adapter Protocol: `dsterm` proxies any DAP adapter over WebSocket, and DS renders breakpoints, variable inspection, watch expressions, the call stack, and a debug console — so it can debug any language that ships a standard DAP adapter.

### Extensions and compatibility

Acode has a community Plugin Store of JavaScript addons written against Acode's own plugin API. Darkian Studio integrates the Open VS X marketplace, so users can browse and install VS Code-compatible extensions (`.vsix`), run through an extension host (`ds-extension-host`) that implements a subset of the `vscode` API.

Important nuance: **availability of an extension in Open VS X does not guarantee compatibility.** Compatibility depends on which portions of the `vscode` API the extension actually uses. Extensions that contribute diagnostics, commands, configuration, or file-system access work; those that depend on the editor surface, a built-in terminal, the debug view, or SCM UI will not behave as in VS Code. Microsoft-exclusive remote extensions are blocked.

### Project management

Acode manages files and projects with an in-app file browser, FTP/SFTP, and GitHub sync. Darkian Studio includes workspace roots, trusted workspaces, tasks, and test runners (pytest, Flutter, Cargo collectors) as project-level structures.

## Feature comparison

Legend: ✅ supported · ⚠️ partial / opt-in / stubbed · ❌ not supported

| Capability | Darkian Studio (1.0.0-beta) | Acode (1.12.6) |
|---|---|---|
| Multi-file editing with tabs | ✅ | ✅ |
| Syntax highlighting (many languages) | ✅ | ✅ |
| Command palette | ✅ | ✅ |
| Find / replace (including all files) | ✅ | ✅ (all-files search is beta) |
| Minimap | ✅ | ❌ |
| Integrated terminal | ✅ (dsterm-backed) | ✅ (axs PTY, Alpine proot, no root) |
| Built-in LSP client | ✅ | ⚠️ installed as plugins |
| Debugging (DAP: breakpoints, variables, watch, stack) | ✅ | ⚠️ JS console only |
| Interactive JS console | ❌ | ✅ |
| Git: clone / commit / push / pull / branch | ✅ | ✅ |
| Git: conflict resolution UI | ✅ | ⚠️ basic |
| Git: stash | ✅ | ⚠️ via tooling |
| Git: blame | ✅ | ⚠️ via tooling |
| SSH / remote file access | ✅ (SFTP/FTP/FTPS/WebDAV, dsterm) | ✅ (SSH, FTP/SFTP) |
| Extension marketplace (browse/install) | ✅ (Open VS X) | ✅ (community Plugin Store) |
| VS Code-compatible extensions | ⚠️ partial `vscode` API surface | ❌ |
| Test runner (pytest / Flutter / Cargo) | ✅ | ❌ |
| Tasks / build automation | ✅ | ⚠️ via plugins |
| Trusted workspace gating | ✅ | ❌ |
| Runs on Android | ✅ | ✅ |
| Runs on Linux/macOS/Windows desktop | ⚠️ Linux only | ❌ |
| Remote runtime (connect to a host) | ✅ (dsterm to Linux/macOS) | ⚠️ terminal/LSP remote; editor stays local |
| Shared runtime for editor/LSP/debugger/extensions | ✅ | ❌ |

## When to choose Acode

- You want a fast, open-source Android editor with minimal setup and a built-in terminal.
- You do web and scripting work and value the interactive JavaScript console and Emmet.
- You prefer a turnkey community Plugin Store and a mature Android editing experience.
- You want an MIT-licensed tool available on the Play Store and F-Droid.
- You don't need structured (DAP) debugging beyond JavaScript.

## When to choose Darkian Studio

- You want language intelligence as a built-in client capability rather than a plugin you install and configure per language.
- You need structured debugging (breakpoints, variables, watch, call stack) through a debug-adapter bridge to a real runtime.
- You want the terminal, language servers, debugger, and extensions to run in the same runtime and share one `PATH`, filesystem, and set of SDKs.
- You want to install VS Code-compatible extensions from Open VS X, understanding the extension API is a partial surface.
- You want Git conflict resolution, tasks, and test runners integrated into the workflow.

Ready to try it? **[Install Darkian Studio]({{ '/install/' | relative_url }})** or read the **[architecture overview]({{ '/docs/architecture/' | relative_url }})**.
