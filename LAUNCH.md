---
sitemap: false
---

# Launch & discovery checklist

The site ships the technical SEO/AEO foundation automatically (sitemap, canonicals,
robots allowing AI crawlers, JSON-LD, `llms.txt`, fast static pages). The steps
below are the **manual, account-based** actions that actually get it discovered —
they can't be automated from the repo.

## 1. Google Search Console (do first)
- [ ] Add a **URL-prefix** property for `https://darkian-studio.github.io`
      (domain/DNS verification isn't available on a `github.io` subdomain).
- [ ] Verify via the **HTML tag** method, then paste the token into
      `_config.yml` → `webmaster_verifications.google` and uncomment it.
- [ ] Submit `https://darkian-studio.github.io/sitemap.xml`.
- [ ] URL Inspection → **Request indexing** for `/`, `/install/`, `/faq/`, `/docs/vs-vscode/`.

## 2. Bing Webmaster Tools (high-leverage for AI)
> ChatGPT Search and Copilot draw on the Bing index, so this feeds AI answers too.
- [ ] Add the site (you can import from Search Console once GSC is set up).
- [ ] Verify via **HTML meta tag** → paste into `_config.yml` →
      `webmaster_verifications.bing` and uncomment.
- [ ] Submit the sitemap.

## 3. Backlinks you control (the real accelerator)
- [x] Repo homepage field set to the site URL (done by owner).
- [ ] Link the site from `darkian-studio/app` **README** (added — keep it).
- [ ] Add the site link to every **GitHub Release** description.
- [ ] Add it to `CONTRIBUTING.md` / issue templates where relevant.

## 4. Off-site mentions (compounds over months)
- [ ] Show HN + Reddit (r/androiddev, r/termux, r/opensource).
- [ ] A `dev.to` / blog post: "a real IDE on Android via Termux".
- [ ] Get listed in "best mobile IDE" / "Termux setup" roundups and awesome-lists.
- [ ] Submit `llms.txt` to directories (llmstxt.site, directory.llmstxt.cloud).

## 5. Ongoing
- [ ] Keep `/changelog/` current with every release (recency is a ranking + AI-citation factor).
- [ ] Watch GSC/Bing coverage reports for crawl errors.
- [ ] Re-run Lighthouse (CI already enforces ≥90 on `/` and `/install/`).

## Realistic timeline
- **Indexed:** ~2–14 days with a sitemap + one crawled backlink.
- **AI live-retrieval citations:** days–weeks once indexed (esp. via Bing).
- **Ranking for competitive terms / model "just knows" DS:** months; driven by
  off-site authority, not on-page markup.
