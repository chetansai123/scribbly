# Scribbly — Issues & Features

All changes are local in [index.html](index.html). **Nothing deployed yet.**

---

## Fixed

### 1. [CRITICAL] Clicking a file showed the previous file's content
Title changed, body didn't. Two independent defects, both fixed:

- **A formatter error left the old note on screen.** `updatePreview()` did `#preview.innerHTML = render(v)` with no guard and set the word count *after* it. Any throw inside `render()` left the previous file's HTML in place and froze the counter — which is exactly the "title says Interview Asked Questions, body shows JS Fundamentals, footer says `0 words · 0 chars`" screenshot. Now: counts update first, `render()` is wrapped in try/catch with a plain-text fallback, and `setMode()` re-renders on switch.
- **The debounced save wrote to the wrong note.** `onEdit()` set a 350 ms timer that read `state.active` and `#editor.value` *at fire time*, not at typing time. Typing and clicking another file within 350 ms silently discarded the edit. Now the edit captures `{id, text}` when you type, and `flushSave()` runs before every file switch and on tab close/hide.

### 2. Answers typed into a note didn't show up
Same debounce race as above. Fixed and regression-tested.

### 3. Numbered-list formatting
- `1.text` → the marker had no gutter, so "1." visually collided with the text and read as "1text". Marker now sits in its own 1.6em gutter.
- `1` / `2` / `3` with text but no dot never became a list. Added `ORD_LOOSE`: two or more consecutive **ascending** numbered lines become a list; a single stray "2 apples" stays prose.

### 4. Read mode wasn't full width
`#preview` had a hard `max-width:900px`. Read mode now spans the page.

### 5. Sign-in didn't register after the OAuth redirect
Could not reproduce without your live Supabase session, so the auth path was made to recover explicitly instead of relying on implicit pickup: the CDN import retries once, `getSession()` is polled directly after a redirect rather than trusting `detectSessionInUrl`, the `#access_token` is stripped from the URL once used, and a redirect that never completes now says so instead of silently sitting on "Sign in". **Needs verification against the real deployment.**

### 6. Formatted pane empty while the editor had text
Same root cause as 1.

### 7. Backup exported one note at a time
Added **📦 Download ALL my notes (.zip)** — real folder structure, one click. Also fixed `backupData()`, which was silently **dropping every embedded image** from the JSON backup.

### 8. [Safety] `pushWorkspace()` could overwrite the cloud with an empty tree
It upserts the whole workspace, so a blank or half-booted session would replace good data with nothing. Now refuses to push a tree containing zero files.

### 9. [CRITICAL] Dictating, then clicking another file, overwrote that file
Same family as issue 1, but through the microphone. `toggleMic()` captured the note's
text into `micBefore`/`micAfter` at start, and every speech result then did
`ta.value = micBefore + interim + micAfter`. Clicking a different file mid-dictation
did not stop the mic — so the next result wrote the **old** note's text into the
**newly opened** note, and the debounced save committed it under the new note's id.
A silent overwrite of a whole file. Now dictation is pinned to the note it started in:
`openFile()` stops the mic first, the paint step refuses to write when
`state.active` has moved, and stopping flushes the spoken text to the note it
belonged to. Regression-tested from both sides — the note spoken into keeps the text,
the note switched to is untouched.

### 10. Code lost all indentation
Every line went through `.trim()` into a `<p>`, so pasted Java/JS collapsed to the left margin. Added `codeLike()` detection (indent, braces, `;`, code keywords **plus** code punctuation) grouping runs of 2+ lines into `<pre>` with indentation preserved and a common-indent `dedent()`. Block code is now monospace so brackets actually align. Guarded against eating prose: lines like "If you delete a middle element…" stay prose.

---

## Added

- **Auto-continuing lists (Word / Notepad style).** Enter on `- `, `* `, `1. `, or `- [ ] ` starts the next item; numbers auto-increment; `- [x]` continues as `- [ ]`; indentation is kept; Enter on an empty marker ends the list.
- **Export everything**, subfolders and files, no manual per-file downloads:
  - `Folder/Note.html` — self-contained, looks exactly like Read mode, pictures embedded; open and Ctrl/Cmd-P → Save as PDF.
  - `Folder/Note.txt` — plain words, no markdown symbols.
  - `READ-ME first.txt` + `scribbly-backup.json` (restorable).
- **📄 Save ALL notes as one PDF** — every note, each on its own page, via the browser's print dialog.
- **Per-note Save as PDF** and **Download .txt** in the Share menu.

- **Undo / redo.** The app rewrites the textarea's `.value` directly (lists, voice, images, Tab), which **wipes the browser's own undo stack** — so `Ctrl/⌘+Z` was unreliable. Replaced with a per-note history:
  - `⌘+Z` / `Ctrl+Z` undo · `⌘+Shift+Z` / `Ctrl+Shift+Z` / `Ctrl+Y` redo · `⌘/Ctrl+S` force-save.
  - **↶ ↷ buttons** in the toolbar (44×44 on touch) — phones have no keyboard, so these are the only undo there.
  - History is **per note**: undo in one note can never restore another note's text.
  - A burst of typing collapses into one undo step; structural edits (list continue, voice, image) are their own step.
  - Capped at 100 steps × 8 recently-edited notes so memory stays bounded.

- **Voice typing fixes.** The lag had a specific cause: `onEdit()` ran on **every interim result**, re-rendering the whole document several times a second. On a 13k-character note that is what made it crawl.
  - Preview redraw is now throttled (~450 ms) while dictating; counts still update live. Measured: 30 interim results now cause **6 renders instead of 30**.
  - Final results are locked into the anchor immediately, so Chrome's automatic mid-session restarts can no longer duplicate or drop text.
  - Restart is delayed 250 ms to stop the `InvalidStateError` restart spin.
  - Language is now selectable (defaults to the device language instead of hard-coded `en-US`) — **en-IN and Indian languages included**, since accent match is the single biggest accuracy factor.
  - Clear message on `network` errors; mic stops cleanly.

- **Formatting toolbar** above the editor: **• List**, **1. List**, **☑ Tasks**, **B**, *I*, highlight, code. Select any number of lines and press the button — they become a list, numbered 1,2,3… in order. Press again to strip the markers off. Switching bullet → numbered replaces the marker rather than stacking. Blank lines are skipped by the numbering, indentation is preserved, and a partial selection expands to whole lines. Each press is a single undo step.
  - Shortcuts: `⌘/Ctrl+B` bold, `⌘/Ctrl+I` italic, `⌘/Ctrl+Shift+8` bullets, `⌘/Ctrl+Shift+7` numbered (same as Google Docs).

- **Trimmed the starting notes.** New installs previously got 3 nested folders and 4 sample files. Now it is two flat reference notes — **Welcome** and **Rate Limiter** — and no folders. Removed the orphaned URL Shortener / Two Pointers seed text, added a code sample to Rate Limiter, and fixed the Welcome note which still pointed at the deleted "Interview Prep" folder.
  - ⚠️ This only affects a **fresh** install (a browser with no saved data). Existing notes are untouched — the seed runs only when nothing is stored.

- **Mic keyboard shortcut:** `⌘/Ctrl+Shift+Space` starts/stops dictation, `Esc` stops. No more reaching for the Speak button. It is now written down where you'd actually find it: a **Talk instead of typing** section in the Welcome note, the 💾 panel, and the Speak button's tooltip.

---

## Voice typing, rebuilt

The lag had a cause I had guessed wrong before. It is not the formatted pane — that
was already throttled. Measured on this machine, one dictation update costs:

| Note size | Cost of a single update |
| --- | --- |
| 11 characters | 0.04 ms |
| 3,300 characters | 4.1 ms |
| 22,000 characters | 13–18 ms |
| 77,000 characters | 52 ms |

It is the **`<textarea>` re-laying out all of its own text on every change**, and it
scales with the length of the note. Emptying the formatted pane changed it by 5%
(14.07 ms → 13.39 ms), so the preview was never the problem. Interim speech results
arrive several times a second, so on a long note — on a phone, several times slower
again — that alone is what made it crawl.

- **The update rate now follows the measured cost.** When you press Speak, the app
  times one real re-layout of the note you are in, on the device you are on, and
  spaces interim updates to keep that work under ~12% of the main thread. A short
  note updates every frame (2 ms gap — indistinguishable from instant); a 22k note
  updates ~8 times a second; a 77k note ~2.5 times a second. **Finalised words are
  never delayed** — they go in the moment they are confirmed, which is what you are
  actually reading. The formatted pane scales the same way and is skipped entirely
  in Write mode.
- **An edit now rewrites only the characters that changed**, by diffing against what
  is already on screen (`setRangeText` over the changed span, never `value =`).
  Verified: 18 speech results into a 22k note performed **0 full-textarea rewrites**
  and touched at most 89 characters each. This is not where the speed came from —
  it measured within noise of the old way — but it keeps the scroll position and the
  browser's own undo stack intact instead of resetting both several times a second.
- **Spoken punctuation.** Say "comma", "full stop", "question mark", "new line",
  "new paragraph", "new bullet", "new task" and you get the real thing, capitalised
  as a new sentence. Toggle in 💾 if you'd rather have the literal words.
  - Deliberately *not* commands: **"period"** and **"newline"**. Both are ordinary
    words in these notes ("grace period", "split on the newline character") and both
    already have an unambiguous spoken form, so mapping them swallowed more real
    words than it saved. "check box" went the same way; "new checkbox" stays.
- **It reads like writing now.** Sentence case after `.`/`?`/`!`, after a line break,
  and after a list marker — applied across a whole utterance, so "one full stop two"
  gives "One. Two", not "One. two". Spacing joins correctly against whatever is
  already there, and standalone "i" becomes "I". English only — Hindi, Telugu, Tamil
  and the rest are left exactly as recognised.
- **No word lost at a pause.** Chrome ends the recognition session on every pause; the
  restart was on a fixed 250 ms delay, which is 250 ms of speech dropped each time.
  It now restarts immediately and only backs off (80 ms → 1.5 s) if the engine says
  it isn't ready, giving up with a clear message after 6 failures instead of spinning.
- **Long dictations save.** Every result reset a 700 ms debounce, so a three-minute
  unbroken dictation never actually reached storage. There is now a hard flush every
  4 seconds regardless.
- **Typing mid-dictation no longer corrupts the note.** Type, paste, or undo while the
  mic is live and speech simply continues from the new cursor position.
- **Fixed: dictation stalled in a background tab.** The batching used
  `requestAnimationFrame`, which browsers pause when the tab is hidden. There is now a
  timer fallback.

Also fixed while in here: the Welcome note's own section headings ran into their body
text — "Formatting buttonsSelect a few lines…", "SharingHit Share for…". They are
proper sub-headings now.

---

## Note on PDFs

The browser cannot write PDF files directly without a bundled PDF library, and the app is deliberately dependency-free (one HTML file). The print route is the standard way to get a *real* PDF — the page is styled for print with page breaks and no-split rules for code blocks, images, quotes and tables, so "Save as PDF" produces a proper document rather than a screenshot.

## Still to verify on the live site

- Issue 5 (sign-in) against the real Supabase project.
- Pop-ups must be allowed for the two PDF actions.

---

## Testing

`tests.html` — DOM test harness. Serve the folder and open it:

```
python3 -m http.server 8765
```
then `http://localhost:8765/tests.html` → **Run tests**.

It loads the real `index.html` in a frame and drives it through **real DOM events** —
clicking the actual buttons, dispatching real `keydown` / `blur`. UI paths are never
exercised by calling app functions by name: a shadowed global resolves the same way
for a test as it does for the bug, so a name-based test agrees with the very defect
it should catch. That is exactly how the duplicate `commitEdit` shipped through three
commits and several "verified" runs.

30 checks across 7 groups: creating a file, renaming without losing text, folders and
nesting, edits landing on the right note, persistence, repair of data damaged by older
builds, and source guards (no duplicate top-level `function` declarations; every inline
handler in the tree resolves to a real function).

Each group is isolated — a crash in one cannot hide the groups after it.

**Verified to fail:** reintroducing the duplicate `commitEdit` turns 30 passing into
14 failing, and the source guard names `commitEdit` outright.

**Your notes are safe.** The harness shares `localStorage` with the app, so it copies
`scribbly_v2` aside before the first test and restores it when the run ends, including
on crash or refresh. **Restore my notes** recovers an interrupted run.
