# Put Scribbly on your phone

Scribbly is a set of plain static files — no server, no build step. To open it on your
phone (and get an installable app icon), host these 4 files anywhere:

```
index.html          ← the app
manifest.json        ← makes it installable
service-worker.js    ← offline support + install
icon.svg             ← the app icon
```

Pick one path below. All are free.

---

## Option A — Netlify Drop (fastest, ~60 seconds, no CLI)

1. Zip the folder (already done for you: **scribbly.zip**), or keep the 4 files together.
2. Go to **https://app.netlify.com/drop**
3. **Drag the folder (or scribbly.zip) onto the page.**
4. You get a live URL like `https://something.netlify.app` instantly.
5. Open that URL on your phone → in the browser menu tap **"Add to Home Screen" / "Install"**.

> To keep the URL permanently and re-deploy later, make a free Netlify account when it prompts you (optional for a first test).

Same drag-and-drop works at **https://tiiny.host** if you prefer.

---

## Option B — GitHub Pages (permanent, free, version-controlled)

1. Create a free GitHub account and a new **public** repo (e.g. `scribbly`).
2. Upload the 4 files to the repo root (GitHub's web UI has an "Add file → Upload files" button).
3. Repo **Settings → Pages → Build and deployment → Source: Deploy from a branch**, pick `main` / root, **Save**.
4. Wait ~1 minute. Your app is at `https://<your-username>.github.io/scribbly/`.
5. Open on your phone → **Add to Home Screen / Install**.

---

## Option C — Vercel (free, great if you like a CLI)

```bash
npm i -g vercel
cd path/to/scribbly
vercel        # follow the prompts; accept defaults
```

You'll get a `https://….vercel.app` URL. Install it on your phone the same way.

---

## Notes

- **Data does not sync across devices yet.** Each browser keeps its own notes. Use
  **💾 → Save backup** on one device and **Restore** on another to move notes, or ask me to
  wire up real cloud sync (Supabase) with a login.
- **After you change `index.html` and re-deploy**, the app updates automatically on next open
  (the service worker is network-first). If a phone still shows an old version, close and
  reopen the tab once.
- **The 🪄 screenshot→diagram feature** calls the Anthropic API directly from your browser using
  the key you paste in 💾. That key stays in your browser's local storage on that device.
