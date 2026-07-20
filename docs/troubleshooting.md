---
layout: doc
permalink: /docs/troubleshooting/
title: Troubleshooting
lede: To diagnose a Darkian Studio problem, copy the Diagnostics logs (and any crash report) from Settings → Diagnostics and attach them to a bug report — you don't need ADB or Flutter.
description: "Troubleshoot Darkian Studio: how to attach diagnostics logs and crash reports, what to include in a bug report, and the known limitations of the first beta."
---

DS keeps its own logs and crash reports, so you can collect everything a maintainer needs to reproduce an issue from inside the app.

## How to attach diagnostics / logs

DS keeps its own logs and crash reports — you do **not** need ADB or Flutter.

1. Open **Settings → Diagnostics → Diagnostics logs**.
2. Use the **copy** action (top bar) to copy the full log buffer.
3. If the app crashed, also open **Settings → Diagnostics → Crash reports** and copy the relevant report.
4. Paste both into the bug report, or attach them as files.

You can redact paths/identifiers; please keep timestamps and error messages intact — they are what we use to triage.

## What to include in a bug report

Before filing, gather the information above so maintainers can reproduce quickly, then open the bug report:

- **[Open the Bug report template]({{ site.bug_report_url }})** and paste in your diagnostics logs and any crash report.
- Include your DS version and platform. Check your version in-app via **Settings → About → Check for updates**.
- Keep timestamps and error text intact; redact only sensitive paths or identifiers.

Requesting something instead? Use the **[Feature request template]({{ site.feature_request_url }})**, or start a thread in **[Discussions]({{ site.discussions_url }})**.

## Known limitations

These are the known limitations of the first public beta, kept in sync with the project README:

- **`dsterm` remote on Windows fails.** Connecting a DS workspace to a Windows-hosted `dsterm` endpoint is not supported in this beta; use Termux or a Linux/macOS host for remote runtimes.
- The setup script provisions the runtime on the **device/local host** only.
- Extension host features are opt-in and may be limited on low-end devices.
- Beta tags may ship with breaking changes between releases.

## Still stuck?

- Re-read the **[install steps]({{ '/install/' | relative_url }})** and re-run the setup command — it's idempotent and skips already-installed components.
- Confirm you installed **Termux from F-Droid**, not the Play Store build (which is outdated and breaks DS).
- Confirm your APK came from **[GitHub Releases]({{ site.releases_url }})** — no other source is trusted.
