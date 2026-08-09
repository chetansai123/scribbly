# Cloud sync setup (one-time)

Scribbly works fully offline with no account. Cloud sync + login is optional and
uses a free [Supabase](https://supabase.com) project. The app already has the
project URL + **public** publishable key baked in (safe to commit — it's
protected by Row-Level Security). You only need to do the steps below once.

## 1. Create the database tables (required — 2 min)

Supabase Dashboard → **SQL Editor** → **New query** → paste all of
[`supabase-setup.sql`](supabase-setup.sql) → **Run**.

That script creates two tables:

- **`workspaces`** — one row per user, holding their whole set of notes, with
  Row-Level Security so each signed-in user can only read/write their **own** row.
- **`shares`** — one row per short share link. Without it, **Copy link** still
  works but falls back to the old form that carries the entire note inside the
  URL, so a long note produces a several-thousand-character link.

The script is safe to re-run: it only creates what is missing.

After this, **email + password** sign-in already works.

## 2. (Optional) Instant email sign-in for testing

By default Supabase emails a confirmation link on sign-up. To test without it:
Dashboard → **Authentication → Sign In / Providers → Email** → turn **off**
"Confirm email" → Save. (Turn it back on for production if you like.)

## 3. Allow your app's URL (required for Google + hosted use)

Dashboard → **Authentication → URL Configuration**:
- **Site URL:** your deployed URL, e.g. `https://myscribbly.vercel.app`
- **Redirect URLs (allow list):** add each origin you use, e.g.
  - `https://myscribbly.vercel.app/**`
  - `http://localhost:8765/**`  (for local testing)

> ### ⚠️ If you ever change hosting, you MUST update both fields above
>
> Supabase does not error on an unlisted redirect URL — it **silently ignores it and
> sends you to Site URL instead**. So moving from one host to another without updating
> these two fields looks like this:
>
> 1. You sign in on the new URL.
> 2. Google auth completes and drops you on the **old** host.
> 3. The session is stored under the old origin, so the new one never sees a login —
>    it asks you to sign in again on every single visit.
>
> Nothing in the app code causes this and nothing in the code can fix it; `redirectTo`
> is already `location.origin + location.pathname`. It is purely these two dashboard
> fields. This exact thing happened on the Netlify → Vercel move.

## 4. (Optional) Enable "Continue with Google"

1. Supabase → **Authentication → Sign In / Providers → Google** → enable. Copy the
   **Callback URL** it shows (looks like
   `https://<your-project>.supabase.co/auth/v1/callback`).
2. [Google Cloud Console](https://console.cloud.google.com) → create/select a project →
   **APIs & Services → OAuth consent screen** → External → fill app name + your email → save.
3. **APIs & Services → Credentials → Create credentials → OAuth client ID → Web application**:
   - **Authorized JavaScript origins:** your app origins (`https://myscribbly.vercel.app`, `http://localhost:8765`)
   - **Authorized redirect URIs:** the Supabase **Callback URL** from step 1
   - Create → copy the **Client ID** and **Client secret**.
4. Paste the Client ID + secret back into Supabase's Google provider → Save.

Email/password works without any of step 4.

## Notes

- **Nothing secret is in this repo.** Only the public publishable key is in the
  client; the `service_role` secret is never used here.
- Free tier easily covers a personal/portfolio app. Text notes are tiny.
- Storage model: the whole workspace (folders + files) is one JSON row per user.
  On login it pulls your latest; on edit it pushes (debounced). Guests stay local.

## Share links

Pressing **Copy link** writes a snapshot of that one note into `shares` and hands
back `https://your-app/#s=k3Rt9wQ`. Points worth knowing:

- **A share is an unlisted link, not a private one.** Anyone holding the id can
  read that note — the same bargain as an unlisted YouTube video. Nothing lists
  the ids, and 62⁷ (≈3.5 trillion) of them makes guessing one impractical, but
  don't share anything you would mind a link-holder reading.
- **A share is a snapshot.** Editing the note afterwards does not change an
  already-sent link; press Copy link again to send the newer version.
- **Sharing needs no account.** The insert policy is open to anonymous visitors,
  which is what lets a guest share. There is deliberately no update or delete
  policy, so a published link can never be rewritten under whoever you sent it to.
- **Offline, or no `shares` table** → the app silently falls back to the old
  whole-note-in-the-URL link, so Copy link never fails outright.
- Old `#doc=…` links shared before this existed still open, and always will.
- Tidying up later, e.g. drop shares older than a year:
  `delete from public.shares where created_at < now() - interval '1 year';`
