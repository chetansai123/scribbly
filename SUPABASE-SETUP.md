# Cloud sync setup (one-time)

Scribbly works fully offline with no account. Cloud sync + login is optional and
uses a free [Supabase](https://supabase.com) project. The app already has the
project URL + **public** publishable key baked in (safe to commit — it's
protected by Row-Level Security). You only need to do the steps below once.

## 1. Create the database table (required — 2 min)

Supabase Dashboard → **SQL Editor** → **New query** → paste all of
[`supabase-setup.sql`](supabase-setup.sql) → **Run**.

This creates a `workspaces` table (one row per user) with Row-Level Security so
each signed-in user can only read/write their **own** notes.

After this, **email + password** sign-in already works.

## 2. (Optional) Instant email sign-in for testing

By default Supabase emails a confirmation link on sign-up. To test without it:
Dashboard → **Authentication → Sign In / Providers → Email** → turn **off**
"Confirm email" → Save. (Turn it back on for production if you like.)

## 3. Allow your app's URL (required for Google + hosted use)

Dashboard → **Authentication → URL Configuration**:
- **Site URL:** your deployed URL, e.g. `https://magnificent-shortbread-d30ef8.netlify.app`
- **Redirect URLs (allow list):** add each origin you use, e.g.
  - `https://magnificent-shortbread-d30ef8.netlify.app/**`
  - `http://localhost:8000/**`  (for local testing)

## 4. (Optional) Enable "Continue with Google"

1. Supabase → **Authentication → Sign In / Providers → Google** → enable. Copy the
   **Callback URL** it shows (looks like
   `https://<your-project>.supabase.co/auth/v1/callback`).
2. [Google Cloud Console](https://console.cloud.google.com) → create/select a project →
   **APIs & Services → OAuth consent screen** → External → fill app name + your email → save.
3. **APIs & Services → Credentials → Create credentials → OAuth client ID → Web application**:
   - **Authorized JavaScript origins:** your app origins (Netlify URL, `http://localhost:8000`)
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
