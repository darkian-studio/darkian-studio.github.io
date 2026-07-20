---
layout: doc
permalink: /docs/dsterm/
title: dsterm — the runtime bridge
lede: dsterm is the open-source Rust server that Darkian Studio connects to — it exposes a PTY, protocol bridges (LSP, DAP, MCP, extension host), and command execution over HTTP and WebSocket, so one runtime can back the whole IDE. It runs anywhere you have a shell: Termux on Android, Linux, macOS, or Windows.
description: "dsterm is the open-source Rust backend behind Darkian Studio: an interactive PTY, LSP/DAP/MCP/extension-host bridges, and command execution over HTTP and WebSocket. Install, CLI usage, configuration, and API reference."
---

`dsterm` is the runtime bridge described in the [architecture overview]({{ '/docs/architecture/' | relative_url }}). It is a standalone, open-source Rust server ([darkian-studio/dsterm](https://github.com/darkian-studio/dsterm)) that the Darkian Studio editor talks to over a single connection. Because the PTY, language servers, debugger, extension host, and command execution are all reached through `dsterm`, they share one runtime session — the same `PATH`, filesystem, and installed SDKs.

> The standard [install flow]({{ '/install/' | relative_url }}) installs and starts `dsterm` for you. This page is for understanding it, running it manually, or connecting DS to a remote host.

## Features

- **Interactive PTY** — full terminal sessions streamed over WebSocket.
- **Shell integration** — OSC 633 exit-code tracking for bash, zsh, and fish.
- **Silent execution** — a non-interactive command runner with stdout/stderr capture.
- **Streaming execution** — chunked command output streamed over WebSocket.
- **LSP bridge** — WebSocket proxy to any Language Server Protocol server.
- **DAP bridge** — WebSocket proxy to any Debug Adapter Protocol server.
- **MCP bridge** — WebSocket proxy to any Model Context Protocol server.
- **Extension Host bridge** — a Node.js process bridge with newline-delimited JSON.
- **AST bridge** — tree-sitter scope analysis for Python, JavaScript, and TypeScript.
- **Prometheus metrics** — a `/metrics` endpoint with session counters.
- **TOML configuration** — an optional config file for all tunable parameters.
- **Graceful shutdown** — drains sessions on SIGTERM / SIGINT.
- **Automatic updates** — `dsterm update` downloads the latest binary.

## Installation

The DS setup command already installs `dsterm`. To install it directly:

**Termux (Android), Linux, macOS** (bash):

<div class="code-block">
  <button class="copy-btn" type="button">Copy</button>
  <pre><code>curl -L https://raw.githubusercontent.com/darkian-studio/dsterm/main/install.sh | bash</code></pre>
</div>

**Windows** (PowerShell):

<div class="code-block">
  <button class="copy-btn" type="button">Copy</button>
  <pre><code>irm https://raw.githubusercontent.com/darkian-studio/dsterm/main/install.ps1 | iex</code></pre>
</div>

Both installers detect your platform and download the matching prebuilt binary from the latest release:

- **Termux (Android)** — native Android binary (arm64, armv7, x86_64).
- **Linux** — static musl binary (x86_64, aarch64, armv7) that runs on any distribution without glibc version constraints.
- **macOS** — native binary (Apple Silicon arm64, Intel x86_64).
- **Windows** — native binary (x86_64).

When no prebuilt binary matches your platform, the installers fall back to building from source with `cargo` (requires a [Rust toolchain](https://rustup.rs)):

<div class="code-block">
  <button class="copy-btn" type="button">Copy</button>
  <pre><code>cargo install --git https://github.com/darkian-studio/dsterm dsterm</code></pre>
</div>

<div class="callout warn">
  <p><strong>Note on remote runtimes.</strong> <code>dsterm</code> itself ships a Windows binary, but connecting a <em>Darkian Studio workspace</em> to a Windows-hosted <code>dsterm</code> endpoint is not supported in this beta. Use Termux or a Linux/macOS host for remote runtimes.</p>
</div>

## Update

`dsterm` checks for updates on every start and notifies you when one is available. To update immediately:

<div class="code-block">
  <button class="copy-btn" type="button">Copy</button>
  <pre><code>dsterm update</code></pre>
</div>

## Usage

```text
dsterm [OPTIONS] [COMMAND]

Commands:
  update  Check for and install the latest release
  lsp     Start a standalone WebSocket LSP bridge
  help    Print help

Options:
  -p, --port <PORT>            Server port [default: 8767]
  -i, --ip                     Bind to LAN IP instead of 127.0.0.1
  -c, --command <CMD>          Custom shell / program for PTY sessions
      --config <PATH>          TOML configuration file
      --allow-any-origin       Disable CORS origin restriction (dangerous)
  -h, --help                   Print help
  -V, --version                Print version
```

### Examples

```bash
# Start on default port (localhost:8767)
dsterm

# Start with a custom shell
dsterm -c /usr/bin/zsh

# Start on LAN IP with a config file
dsterm -i --config /etc/dsterm.toml

# Standalone LSP proxy for rust-analyzer
dsterm lsp rust-analyzer

# Check for updates
dsterm update
```

<div class="callout danger">
  <p><strong><code>--allow-any-origin</code> disables the CORS origin restriction.</strong> Only use it on a trusted, private network — it lets any web origin reach your runtime.</p>
</div>

## Configuration

Create a TOML file and pass it with `--config`. All fields are optional — omitted fields use the defaults shown:

```toml
[terminal]
max_scrollback_bytes = 262144   # 256 KB per session
output_coalesce_ms = 8          # WebSocket flush interval
read_buffer_bytes = 8192        # PTY read buffer size
inactivity_timeout_secs = 1800  # Evict idle sessions after 30 min

[bridges]
kill_timeout_secs = 2           # Grace period when killing bridge processes
```

## API reference

Full protocol documentation lives in the `dsterm` repository under [`docs/api/`](https://github.com/darkian-studio/dsterm/tree/main/docs/api):

| Document | Contents |
|---|---|
| [CLI.md](https://github.com/darkian-studio/dsterm/blob/main/docs/api/CLI.md) | CLI flags and health endpoints |
| [TERMINAL.md](https://github.com/darkian-studio/dsterm/blob/main/docs/api/TERMINAL.md) | Interactive PTY API |
| [EXECUTE_COMMAND.md](https://github.com/darkian-studio/dsterm/blob/main/docs/api/EXECUTE_COMMAND.md) | `POST /execute-command` |
| [SILENT_EXECUTION.md](https://github.com/darkian-studio/dsterm/blob/main/docs/api/SILENT_EXECUTION.md) | Silent exec + streaming |
| [BRIDGES.md](https://github.com/darkian-studio/dsterm/blob/main/docs/api/BRIDGES.md) | LSP / DAP / MCP / Extension Host bridges |
| [AST.md](https://github.com/darkian-studio/dsterm/blob/main/docs/api/AST.md) | AST scope endpoint |

## Observability

`GET /metrics` returns Prometheus-compatible metrics:

```text
# HELP dsterm_terminal_sessions_total Terminal sessions created since startup
# TYPE dsterm_terminal_sessions_total counter
dsterm_terminal_sessions_total 42
# HELP dsterm_terminal_sessions_active Currently active terminal sessions
# TYPE dsterm_terminal_sessions_active gauge
dsterm_terminal_sessions_active 3
```

## Building from source

```bash
git clone https://github.com/darkian-studio/dsterm.git
cd dsterm
cargo build --release
# Binary: target/release/dsterm
```

A Rust stable toolchain is required.

## Related

- **[Architecture]({{ '/docs/architecture/' | relative_url }})** — how DS uses the bridge.
- **[Install]({{ '/install/' | relative_url }})** — the standard setup that installs `dsterm` automatically.
- **[dsterm on GitHub](https://github.com/darkian-studio/dsterm)** — source, releases, and issues.
