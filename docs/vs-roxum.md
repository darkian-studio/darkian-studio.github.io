---
layout: doc
permalink: /docs/vs-roxum/
title: Darkian Studio vs Roxum
lede: Roxum is an Android IDE with a native Rust editor and on-device AI; Darkian Studio is an Android IDE whose editor, terminal, LSP, debugger, git, and extensions run against one shared runtime over a bridge. Choose DS for structured debugging, VS Code-compatible extensions, and GitHub workspaces; choose Roxum for a native editor you install from the Play Store.
description: "Darkian Studio vs Roxum: a native-Rust-editor Android IDE with on-device AI versus a bridge-runtime Android IDE with DAP debugging, Open VS X extensions, and GitHub workspaces. Architecture and a feature-by-feature table."
---

> Versions compared: Darkian Studio 1.0.0-beta (first public beta, August 2026) and Roxum 2.4.0 (latest Play Store release, July 2026). DS capabilities were verified against its runtime (`dsterm`) and the DS source; Roxum capabilities were verified against the Roxum source (`heckmon/roxum-ide`, v2.4.0). Input-latency and scrolling observations come from hands-on testing on a real device, not from benchmarks.

## At a glance

| | Darkian Studio | Roxum |
|---|---|---|
| Focus | Full mobile IDE (editor + LSP + debugger + git + extensions + AI) | Mobile code editor / mini-IDE (editor + LSP + terminal + git + AI) |
| Editor engine | CodeMirror 6 in an in-app web view, bridged from Dart | Native Rust editor (`code_forge`, rope / sum-tree, Zed-like) |
| Runtime bridge | `dsterm`: PTY, LSP, DAP, extension host, AI, execution over one connection | Shared libraries (PTY via `flutter_pty`; SSH via `dartssh2`) |
| Debugging | DAP (breakpoints, variables, watch, call stack) | ❌ none (diagnostics / problems panel only) |
| AI agent / offline models | ✅ built-in chat agent + local GGUF via inference server | ✅ agentic chat + local GGUF via `llama_flutter_android` |
| GitHub Copilot | ❌ | ✅ (bundled Copilot language server) |
| Extensions | Open VS X (VS Code-compatible, partial API) | ❌ none (own downloadable LSP/toolchain catalog only) |
| Distribution | GitHub Releases APK (beta) | Play Store, GitHub (MIT) |

## Executive summary

Roxum is a free, MIT-licensed, mobile-first code editor and mini-IDE for Android, built on Flutter, powered by a native Rust editor engine from the `code_forge` package. It focuses on editing with broad language support, a built-in terminal, Git/GitHub tooling, on-device and cloud AI, and a huge theme library. Darkian Studio is a mobile-first development environment for Android whose editor, terminal, language intelligence, debugger, Git, and extensions all operate against one shared runtime reached through `dsterm`, a Rust server that multiplexes PTY, LSP, DAP, an extension host, and command execution over a single connection. The two tools target the same stage — coding on a phone — but diverge sharply in architecture and depth: Roxum ships a genuinely native editor with strong built-in language/terminal/AI support, while DS routes every core function through one runtime abstraction and, in doing so, gains capabilities Roxum does not have — structured DAP debugging, VS Code-compatible extensions, and clone-less GitHub workspaces.

One asymmetry is worth stating plainly: DS is the younger project. It is a 1.0.0-beta distributed through GitHub Releases rather than the Play Store, so there is no store-driven auto-update channel or Play-install base yet, and its extension/theme ecosystem and community are smaller than Roxum's. The comparisons below are between the current builds — DS 1.0.0-beta and Roxum 2.4.0 — and neither product is finished.

## How each tool works

```
Developer
  ↓
Editor (native Rust editor in Roxum; web editor in DS)
  ↓
Runtime access (shared native libraries in Roxum; dsterm bridge in DS)
  ↓
Terminal / LSP / run   (DS also routes debugger, extensions, and AI here)
```

| | Roxum | Darkian Studio |
|---|---|---|
| Editing | Native Rust editor (`code_forge`) | CodeMirror 6 in an in-app web view |
| Runtime bridge | Shared Android libraries; local PTY + SSH shells | `dsterm` multiplexed server (PTY, LSP, DAP, extension host, AI) |
| Terminal | Native PTY (`flutter_pty`) + SSH terminal | PTY-hosted by `dsterm`, rendered as a native Android view |
| Language intelligence | Built-in LSP client in the editor engine | Built-in LSP client against runtime or extension-host servers |
| Debugger | Diagnostics / problems panel only | DAP bridge to debug adapters in the runtime |
| Extensions | Curated downloadable LSP/toolchain catalog | Open VS X `.vsix` via a `vscode`-API extension host |
| AI | Cloud providers + local GGUF + Copilot | Cloud providers + local GGUF via inference server |

## Architectural differences

### Native editor vs web editor over a bridge

Roxum's editor is native: the `code_forge` package embeds a Rust editing engine (rope / sum-tree data structures, similar to Zed) initialized at startup via `RustLib.init()`, rendered as a real Flutter widget, with syntax highlighting from `re_highlight`. There is no web view doing the editing. Darkian Studio's editor is a CodeMirror 6 bundle (`@codemirror/*` + Lezer grammars) loaded as a Flutter asset into an in-app web view, with Dart orchestrating the bridge — it maps 100+ languages, drives find/replace, folding, diagnostics, and the breakpoint gutter by calling into JavaScript, and receives editor events back over a `JavascriptChannel`.

On paper, the Rust editor sounds strictly better; in practice on Android the opposite holds. `code_forge` is reached over the `flutter_rust_bridge` FFI, and every edit operation serializes across that boundary. In hands-on testing, DS's web-view editor responded to keystrokes and scrolled smoothly regardless of file size. Roxum's native editor, in contrast, showed a multi-second delay before the first keystroke registered and stayed noticeably slower on subsequent input.

So the Flutter↔Rust bridge in Roxum adds latency instead of removing it, and the web-view editor in DS is the one that responds and scrolls smoothly in daily use. "Native Rust" is an implementation detail, not a performance win — what matters is where the per-keystroke and per-frame work actually happens.

### One runtime for everything (DS) vs focused native backends (Roxum)

In DS, the editor, terminal, LSP servers, debugger, extensions, and AI all communicate through one runtime abstraction reached through `dsterm`. They share one environment — the same `PATH`, filesystem, environment variables, installed SDKs, and interpreter — and a single runtime session. A package you install in the terminal is visible to the language server and the debugger with no extra configuration. `dsterm` multiplexes a PTY, a silent command runner, an LSP bridge, a DAP bridge, an extension-host bridge, a Model Context Protocol bridge, and an inference endpoint over one set of routes.

Roxum has no single runtime server. Its terminal runs a bundled shell (`libbash.so`) through a native PTY, and its language servers, Git, and other tooling spawn as separate processes using bundled shared libraries and on-demand languages, with paths resolved from the app's native library directory. Its "runtimes" (compilers/interpreters) are a curated catalog downloaded on demand. There is good integration — a language server for the active file is started and shared per workspace — but it is a set of cooperating native pieces rather than one multiplexed runtime session.

### Termux and remote connection

The two differ substantially on how you reach a real machine. Roxum connects to Termux over SSH: the Termux "connection" is stored as an SSH key, and opening a Termux session starts an SSH `shell()` through `dartssh2`, as do sessions to any saved SSH server. Remote work is a remote terminal and nothing more — there is no SFTP file browser, no remote LSP, and no port forwarding.

There is a deeper catch in the remote/Termux terminal itself: as of Roxum 2.4.0 (July 2026), the on-screen keyboard menu's arrow keys, ESC, HOME, and END all write through `sendToPty`, which targets a local PTY that a Termux/SSH session does not have, so those sequences are dropped, and the CTRL/ALT/SHIFT toggles early-return under the same condition.[^1] So over a Termux or SSH connection you can see the shell and run commands, but Ctrl-C, arrow history navigation, Alt combos, and the clipboard keys are dead keys; the session supports viewing and typing but not key-driven navigation.

DS reaches Termux as the local runtime over a local `dsterm` endpoint (the open-source `dsterm` server, available at `~/dsterm`), and to Linux/macOS hosts it connects `dsterm` directly or uses file-level remote backends (SFTP/FTP/FTPS/WebDAV) and GitHub workspaces. In DS the editor, terminal, language servers, debugger, and extensions can all run against a remote runtime, not just a remote shell. Because DS's own platform view feeds key events through a real input router (`DsTerminalInputRouter.kt`, unit-tested at `DsTerminalInputRouterTest.kt`), Ctrl-letter → control characters, arrow/Home/End/PageUp/PageDown CSI sequences, Alt-ESC prefixes, and chorded keybindings all work the same in every session — local or over `dsterm` — not just a cosmetic shell.

### Project storage: copied, not opened in place

Roxum keeps its projects on the phone in its own app-scoped storage — `/storage/emulated/0/Android/media/com.roxum/Projects` and `/storage/emulated/0/Android/media/com.roxum/Files` (`lib/utils/constants.dart:7,9`). When you import a folder, Roxum **copies** it into that private tree (`lib/utils/functions.dart:77-93`); it does not open it in place. The consequence is practical: unless the project is a Git repository you push somewhere, your work sits in Roxum's app-scoped storage with no built-in export path. There is no export-back-to-source gesture, no remote file sync, and no clone-less workflow — you can regenerate it only by hand-copying from Android's media directory, and uninstalling the app can orphan it.

DS, in contrast, edits against a real workspace you point it at — the Termux home or a `dsterm` host's filesystem — and its Git/GitHub integration is designed around the project being a genuine repository you can push from, plus clone-less GitHub workspaces and SFTP/FTP/WebDAV file remotes that move it off-device without copying.

### Debugging

Roxum ships no structured debugger. There is no Debug Adapter Protocol support anywhere in the source — no breakpoints, variables, watches, or call stack. Its "diag" view is an LSP diagnostics/problems panel, and process "running" just launches a program through a selected runtime.

Darkian Studio debugs through the Debug Adapter Protocol: `dsterm` proxies any DAP adapter over WebSocket, and DS renders breakpoints, variable inspection, watch expressions, the call stack, and a debug console — so it can debug any language that ships a standard DAP adapter. This is a capability Roxum does not offer.

### Extensions and compatibility

Roxum has no VS Code / VSIX / marketplace extension system. Its notion of an "extension" is an internal catalog of downloadable language servers and toolchains (Copilot LSP, rust-analyzer, gopls, CCLS, Dart analyzer, kmp-lsp, the VS Code-extracted HTML/CSS/JSON/Markdown servers, and bundled compilers/interpreters), delivered through Play dynamic-feature modules and an in-app download catalog.

Darkian Studio integrates the Open VS X marketplace as its extension backend, so users can browse and install VS Code-compatible extensions (`.vsix`) run through an extension host that implements a subset of the `vscode` API.

Important nuance: **availability of an extension in Open VS X does not guarantee compatibility.** Compatibility depends on which portions of the `vscode` API the extension actually uses. Extensions that contribute diagnostics, commands, configuration, or file-system access work; those that depend on the editor surface, an integrated terminal, the debug view, or SCM UI will not behave as in VS Code. In the current beta, extension contribution and command execution work; arbitrary JavaScript extension entry points are deferred to a later version.

## Feature comparison

Legend: ✅ supported · ⚠️ partial / opt-in / stubbed · ❌ not supported

| Capability | Darkian Studio (1.0.0-beta) | Roxum (2.4.0) |
|---|---|---|
| Multi-file editing with tabs | ✅ | ✅ |
| File explorer in deeply nested projects | ✅ breadcrumb navigation (one level per screen, full width) | ⚠️ recursive tree in a 350px drawer — at ~4 dirs deep names collapse to a ~10-char prefix and files become indistinguishable |
| Syntax highlighting (many languages) | ✅ | ✅ |
| Command palette | ✅ | ✅ |
| Find / replace in editor | ✅ | ✅ |
| Minimap | ⚠️ removed in current beta (was tried, dropped) | ⚠️ not in current release |
| Diff editor / pending-edit preview | ✅ | ✅ (pending-edit decorations) |
| Integrated terminal | ✅ (dsterm-backed) | ✅ (native PTY, bundled shell) |
| Terminal special keys (Ctrl / Alt / arrows) | ✅ in every session (input router, unit-tested) | ⚠️ local session only — non-functional over SSH/Termux |
| SSH / remote terminal | ⚠️ remote file backends + dsterm hosts; no bare SSH terminal | ✅ SSH terminal (password / key) |
| Remote file editing (SFTP/FTP/WebDAV) | ✅ | ❌ |
| Projects copied into app-managed storage on import | ❌ edits the real workspace you point at | ⚠️ app-scoped media dir; manual copy to export |
| Export / off-device recovery without git | ✅ (remotes, GitHub workspaces) | ❌ hand-copy from app media dir only |
| Built-in LSP client | ✅ | ✅ (in the editor engine) |
| LSP: completion / hover / signature help | ✅ | ✅ |
| LSP: definition / references / implementation | ✅ | ⚠️ via language servers |
| LSP: rename / formatting / code actions | ✅ | ✅ |
| LSP: diagnostics / problems panel | ✅ | ✅ |
| Semantic tokens / inlay hints | ✅ | ⚠️ partial |
| Debugging (DAP: breakpoints, variables, watch, stack) | ✅ | ❌ |
| Git: clone / commit / push / pull / stash / branch | ✅ | ✅ |
| Git: conflict resolution UI | ✅ | ⚠️ basic |
| Git: blame | ✅ | ⚠️ via tooling |
| Git: tags | ✅ | ✅ |
| GitHub sign-in + repo browsing | ✅ | ✅ |
| GitHub PR authoring | ✅ | ❌ |
| GitHub workspaces (no-clone editing) | ✅ | ❌ |
| AI chat agent (tool calling) | ✅ | ✅ |
| Offline local AI models (GGUF) | ✅ (inference server) | ✅ (`llama_flutter_android`) |
| AI inline completions (FIM) | ✅ | ✅ |
| GitHub Copilot | ❌ | ✅ |
| External AI providers | ✅ (OpenRouter, Together, Groq, Mistral, Custom, …) | ✅ (Gemini, OpenAI, Claude, Grok, DeepSeek, Together, Perplexity, OpenRouter, FireWorks, Custom) |
| Extension marketplace (browse/install) | ✅ (Open VS X) | ❌ |
| VS Code-compatible extensions | ⚠️ partial `vscode` API surface | ❌ |
| Test runner (pytest / Flutter / Cargo) | ✅ | ❌ |
| Tasks / build automation | ✅ | ❌ |
| Trusted workspace gating | ✅ | ❌ |
| Runs on Android | ✅ | ✅ |
| Responsive typing / scrolling (tested on device) | ✅ smooth | ❌ slow keystrokes, sticky scroll |
| Automated tests in the codebase | ✅ (large suite, unit tests pass) | ❌ (none) |
| Distribution | GitHub Releases APK (beta) | Play Store, GitHub (MIT) |
| License | Proprietary (free beta) | MIT |

## When to choose Roxum

- You want to install from the Google Play Store and let it update itself through normal Play delivery.
- You appreciate a native (non-web-view) editor architecture for maintainability, even though its Flutter↔Rust bridge currently lags on input latency.
- You rely on GitHub Copilot for completions and chat without managing a separate provider setup.
- You want broad cloud-AI provider choice and deep built-in themes/customization out of the box.
- You do light-to-mid editing and terminal work and don't need structured (DAP) debugging.
- You always work inside Git repositories and don't mind keeping projects in the app's own storage.

## When to choose Darkian Studio

- You need structured debugging — breakpoints, variable inspection, watch expressions, and a call stack — through a debug-adapter bridge to a real runtime.
- You want to install VS Code-compatible extensions from Open VS X, understanding the extension API is a partial surface.
- You want the terminal, language servers, debugger, and extensions to run in the same runtime and share one `PATH`, filesystem, and set of SDKs.
- You want your projects to live in a filesystem you own and can leave — a real workspace, not a copy held in app-managed storage.
- You want clone-less GitHub workspaces, Git conflict-resolution UI, tasks, and built-in test runners in the workflow.
- You want a codebase that ships with an extensive automated test suite rather than an untested binary.

Ready to try it? **[Install Darkian Studio]({{ '/install/' | relative_url }})** or read the **[architecture overview]({{ '/docs/architecture/' | relative_url }})**.

[^1]: In the Roxum source, a Termux/SSH session sets `runtime.sshSession` rather than a local PTY; `sendToPty` writes to the local PTY object so those sequences are dropped (`lib/terminal/terminal.dart:511-559`), and the CTRL/ALT/SHIFT toggles are gated on the same local PTY and early-return without it (`lib/terminal/terminal.dart:938`).
