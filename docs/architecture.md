---
layout: doc
permalink: /docs/architecture/
title: Architecture
lede: Darkian Studio separates the editor from the runtime — one runtime, local or remote, serves the editor, terminal, LSP, debugger, git, and extensions over a single bridge. That's why any machine with a terminal can act as DS's backend.
description: "How Darkian Studio works at a high level: one runtime — local or remote — serves the editor, terminal, LSP, debugger, git, and extensions over a bridge."
---

Darkian Studio is a client for a runtime. The editor is the client; the runtime is whatever the bridge points at. Because one runtime backs every core feature, the editor, terminal, language servers, debugger, git, and extensions all share the same environment — the same `PATH`, filesystem, environment variables, and installed SDKs.

## One runtime, reached over a bridge

Instead of bundling a full OS inside the app, DS reaches a runtime over a single bridge connection:

```
You
  ↓
Editor (the DS client)
  ↓
Bridge (one connection)
  ↓
Runtime  (Termux on Android, or a Linux/macOS host)
  ↓
Terminal · LSP · Debugger · Git · Extensions
```

The terminal, language servers, debugger, extension host, and command execution are all reached through that one connection, which is why they share a single runtime session rather than running as unrelated, disconnected services.

## Why this matters

- **Consistency.** A package you install in the terminal is immediately visible to the language server and the debugger — no separate configuration.
- **Portability.** The runtime can be the phone itself (Termux) or a remote Linux/macOS host. Point the bridge at a different target and the same editor works against it.
- **Any terminal can be a backend.** Because the runtime is reached over a bridge, any machine you can run the runtime on can serve as DS's backend.

## Local or remote

On Android, DS drives a Termux runtime on the device. On Linux and macOS, it can use a system runtime or connect to a remote host, so the editor, terminal, language servers, debugger, and extensions all run against that runtime. Connecting to a **Windows-hosted** runtime is not supported in this beta — use Termux or a Linux/macOS host.

## Learn more

- **[Getting started]({{ '/docs/getting-started/' | relative_url }})** — put the model into practice.
- **[DS vs VS Code]({{ '/docs/vs-vscode/' | relative_url }})** and **[DS vs Acode]({{ '/docs/vs-acode/' | relative_url }})** — how this architecture differs from other tools.
