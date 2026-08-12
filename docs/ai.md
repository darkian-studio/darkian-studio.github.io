---
layout: doc
permalink: /docs/ai/
title: AI in Darkian Studio
lede: Darkian Studio ships three AI layers — a tool-calling chat agent, fully offline local models (GGUF), and inline fill-in-the-middle completions — all routed through the same runtime as the editor and terminal.
description: "Darkian Studio's AI features: the built-in chat agent with tool calling, local GGUF models installed from Hugging Face and run fully offline, inline FIM completions, and Model Context Protocol (MCP) support."
---

Darkian Studio is built AI-first: an assistant, offline models, and inline completions work alongside the editor against the same runtime. That means an AI model you load inside DS has the same access to your runtime as the terminal does — the same `PATH`, filesystem, and installed SDKs.

## AI chat agent

The built-in chat agent is a full assistant, not a single-response chatbot:

- **Tool calling** — it can read and write files, search/grep the workspace, and run commands in the runtime.
- **Streaming responses** — tokens render as they arrive, with a thinking-mode toggle.
- **Session persistence** — conversations are saved and can be reopened; messages can be edited and re-sent.

### Providers

DS supports multiple providers for the agent and completions:

- **OpenAI-compatible endpoints** — point it at any provider that exposes an OpenAI-compatible API; OpenRouter, Together, Fireworks, Groq, and Mistral ship preconfigured.
- **Built-in free provider** — a hosted option bundled with DS that needs no API key, plus an optional free-keyed variant of the same endpoint.
- **Local endpoints** — Ollama, or a GGUF model loaded in your runtime is exposed as a local provider (see below).

## Local AI models (fully offline)

DS can run the whole stack on-device, with no cloud connection:

1. **Browse the Hugging Face marketplace** inside DS — search models with parameter counts, sizes, and quantisation shown.
2. **Install a GGUF model** — downloads through the runtime and installs it locally.
3. **Load and chat** — the runtime's inference server loads the model; the chat agent uses it as its local provider.

Loaded models show live state, parameter counts, quantisation, and resident-memory estimates. Models can be loaded and unloaded from inside the app.

## Inline completions

Fill-in-the-Middle (FIM) completions appear inline as you type:

- **Configurable providers** — each completion provider may use a chat-style or a legacy completion endpoint, so cloud and local models both work.
- **Per-model control** — providers are configured in the AI settings screen, including model selection and system prompts.

## Model Context Protocol (MCP)

DS is an MCP **client**: it can connect to MCP servers to give the AI agent additional tools and context, alongside its built-in file, search, and command tools.

## Privacy

- Cloud providers only see what you send them via the configured endpoint.
- Local GGUF models run entirely on your device or your runtime host — nothing leaves the machine.
- Your provider choice and keys are stored by the app's secure preferences, and each provider may be disabled independently.

## Learn more

- **[Getting started]({{ '/docs/getting-started/' | relative_url }})** — where AI fits in the first-run tour.
- **[dsterm]({{ '/docs/dsterm/' | relative_url }})** — the runtime bridge that hosts the inference server.
- **[FAQ]({{ '/faq/' | relative_url }})** — quick answers on AI, offline models, and providers.