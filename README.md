# ✎ Scribbly — notes that format & draw themselves

A hand-drawn notebook web app. You type plain notes; Scribbly formats them for you —
colours, sizes, spacing — automatically, and even turns arrow-text into hand-drawn
diagrams. No toolbar gymnastics, no accounts, no build step. It's a single self-contained
web page that runs anywhere and installs to your phone as an app.

> **Live demo:** _add your deployed URL here_ · **Tech:** vanilla HTML + CSS + JS (zero dependencies), PWA

![Scribbly screenshot](docs/screenshot.png) <!-- optional: drop a screenshot at docs/screenshot.png -->

---

## Why it exists

Plain-text editors (Notepad, etc.) show every line the same size and colour — long notes
become an unreadable wall of text. Scribbly reads the *structure* of what you type and styles
it like a crafted, hand-drawn page, so notes are pleasant to read and revisit (great for
interview prep — HLD system design, DSA, and the like).

## Features

- **Auto-formatting** — first line → title; `ALL CAPS` or a line ending in `:` → heading;
  `#`/`##` markdown too. Bullets, numbered lists, `- [ ]` checkboxes, tables, blockquotes,
  ` ``` ` code, `**bold**`, `*italic*`, `==highlight==` — all styled live as you type.
- **Text → diagrams** — type `Start -> Validate -> Save -> Done` (or a ` ```flow ` block) and
  it draws hand-drawn crayon boxes and arrows, using a tiny custom SVG sketch engine (no
  libraries).
- **Screenshot → diagram (optional AI)** — upload a photo of a flowchart and it redraws it in
  the same sketch style. Runs **fully client-side** using *your own* Anthropic API key, which
  is stored only in your browser (see [Security](#security)).
- **Folders & files** — nested tree with VS Code–style inline create/rename, drag-to-move.
- **Voice dictation** — speak and text appears at your cursor (Web Speech API).
- **Two themes** — a light "notebook" (ruled paper, crayon headings) and a dark "blackboard".
- **Share** — WhatsApp / Telegram / Email / copy-link / download as a standalone `.html`.
- **Offline & installable (PWA)** — works without a connection; "Add to Home Screen" on mobile.
- **Local-first** — notes auto-save to your browser; **Backup / Restore** as a JSON file.

## Run it locally

It's just static files — open `index.html` directly, or serve the folder:

```bash
# any static server works; here's Python's
python3 -m http.server 8000
# then visit http://localhost:8000
```

The service worker and "install" prompt only activate over `http(s)` (not `file://`).

## Deploy

See [DEPLOY.md](DEPLOY.md) — one-minute drag-and-drop to Netlify, or GitHub Pages / Vercel.

## Project structure

```
index.html          the whole app (markup, styles, logic)
manifest.json       PWA manifest
service-worker.js   offline cache (network-first, so redeploys show immediately)
icon.svg            app icon
DEPLOY.md           hosting instructions
```

## Security

- **No secrets in this repository.** There are no API keys, tokens, or personal data in the
  code. Search the source — the only `sk-ant-…` is a placeholder in an input field.
- The optional screenshot→diagram feature calls the Anthropic API **directly from your
  browser** with a key *you* paste at runtime. That key is kept in `localStorage` on your
  device only; it is never committed, logged, or sent anywhere except Anthropic's API on your
  own requests. Don't hard-code a key into the source.
- All your notes stay in your browser (`localStorage`) unless you export a backup yourself.

## License

[MIT](LICENSE) — do whatever you like; attribution appreciated.
