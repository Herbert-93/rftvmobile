# RF TV Mobile — full project

This repo contains everything for RF TV Mobile, built from the app mockup:

```
rftv-mobile/
├── backend/        Node.js + TypeScript + Express API, Firebase Admin SDK, deployed to Render
├── admin-panel/    Next.js (TypeScript) web app for managing content, deployed to Render
├── mobile/         Flutter app (Android/iOS) — the actual RF TV Mobile app
├── firestore.rules       Firestore security rules
├── firestore.indexes.json
└── firebase.json
```

**How the pieces fit together:** the Flutter app and the Next.js admin panel both talk
to the **backend API**, never directly to Firestore for writes. The backend uses the
Firebase **Admin SDK** (full trust, server-side only) to read/write Firestore and to
verify who's calling it. Firebase Authentication is the single source of truth for
user identity across all three apps.

This is a complete, working starter — not a fully audited production app. Read the
"Before you launch" section at the end before shipping to real users.

---

## 0. Prerequisites

Install these once:

- [Node.js 18+](https://nodejs.org) and npm
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.3+) and a way to run it — Android Studio (Android emulator) and/or Xcode (iOS simulator, Mac only)
- [Firebase CLI](https://firebase.google.com/docs/cli): `npm install -g firebase-tools`
- [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup): `dart pub global activate flutterfire_cli`
- A free [Render](https://render.com) account
- A free [Firebase](https://console.firebase.google.com) account
- Git, and a GitHub (or GitLab) repo to push this project to — Render deploys from a git repo, not a zip upload

---

## 1. Create the Firebase project

1. Go to the [Firebase console](https://console.firebase.google.com) → **Add project** → name it (e.g. `rftv-mobile`).
2. **Authentication** → Get started → enable **Email/Password**. (Optional: enable Google sign-in too — the Flutter/mockup screens have a Google button; wiring it up needs `google_sign_in` package + platform config, left as a TODO in `login_screen.dart`.)
3. **Firestore Database** → Create database → start in **production mode** → pick a region close to your users.
4. **Project settings → Service accounts** → **Generate new private key**. This downloads a JSON file — you'll use three fields from it (`project_id`, `client_email`, `private_key`) for the **backend**.
5. **Project settings → General → Your apps → Add app → Web app**. Register it (nickname doesn't matter) and copy the `firebaseConfig` values — you'll use these for the **admin panel**.
6. Deploy the security rules included in this repo:
   ```bash
   cd rftv-mobile
   firebase login
   firebase use --add          # pick your project, give it an alias e.g. "default"
   firebase deploy --only firestore:rules,firestore:indexes
   ```

---

## 2. Backend (Node.js + TypeScript + Firebase Admin)

```bash
cd backend
cp .env.example .env
```

Edit `.env` and fill in:
- `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY` — from the service account JSON in step 1.4. Keep the quotes and `\n` sequences in `FIREBASE_PRIVATE_KEY` exactly as they appear in the JSON's `private_key` field.
- `CORS_ORIGINS` — for local dev, `http://localhost:3000` (admin panel) is enough. Add your Render admin-panel URL once deployed.

Install and run locally:

```bash
npm install
npm run dev
```

You should see `RF TV backend listening on port 4000`. Visit `http://localhost:4000/health` to confirm.

**Seed sample content** (channels, a schedule, radio status, donation config) so the app isn't empty:

```bash
npm run seed
```

**Make yourself an admin** (required to log into the admin panel — do this after you've signed up at least once through the Flutter app or Firebase console with the email you want to use):

```bash
npm run set-admin -- you@example.com
```

### Deploy the backend to Render

1. Push this repo to GitHub.
2. In Render: **New → Web Service** → connect the repo.
3. Root directory: `backend`. Build command: `npm install && npm run build`. Start command: `npm start`.
4. Add the same environment variables as your `.env` (`FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY`, `CORS_ORIGINS`, `NODE_ENV=production`).
   - For `FIREBASE_PRIVATE_KEY` in Render's dashboard, paste it with literal `\n` characters (not real line breaks) — the code in `src/config/firebase.ts` converts them back.
5. Deploy. Render gives you a URL like `https://rftv-backend.onrender.com` — you'll need it for the admin panel and the Flutter app.
   - (Alternative: there's a `render.yaml` in `backend/` and `admin-panel/` if you prefer Render's "Blueprint" one-click setup instead of the manual steps above.)

> Free Render web services spin down after inactivity and take ~30–60s to wake up on the next request. Fine for a starter/demo; upgrade the plan before real users depend on it.

---

## 3. Admin panel (Next.js)

```bash
cd admin-panel
cp .env.example .env.local
```

Fill in `.env.local`:
- `NEXT_PUBLIC_FIREBASE_*` — from step 1.5 (the web app config).
- `NEXT_PUBLIC_API_URL` — `http://localhost:4000` for local dev, or your Render backend URL once deployed.

Run locally:

```bash
npm install
npm run dev
```

Open `http://localhost:3000` → redirects to `/login`. Sign in with the account you ran `npm run set-admin` on. If it says you don't have admin access, double check you ran the script against the right email and that you're signing in with the same one.

### Deploy the admin panel to Render

Same pattern as the backend: **New → Web Service**, root directory `admin-panel`, build command `npm install && npm run build`, start command `npm start`, and set the `NEXT_PUBLIC_*` env vars in Render's dashboard (point `NEXT_PUBLIC_API_URL` at your deployed backend).

Once both are deployed, go back into the **backend's** `CORS_ORIGINS` env var on Render and add the admin panel's Render URL, then redeploy the backend so it accepts requests from it.

---

## 4. Mobile app (Flutter)

```bash
cd mobile
flutter pub get
```

### Connect Firebase

```bash
flutterfire configure
```

Pick the same Firebase project from step 1. This overwrites `lib/firebase_options.dart` with real values and generates `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`. (The placeholder `firebase_options.dart` in this repo will not work until you do this.)

### Point the app at your backend

Open `lib/services/api_service.dart`. The default `baseUrl` (`http://10.0.2.2:4000`) only works for the **Android emulator** talking to a backend running on your machine. Change it depending on where you're running:

| Target | `baseUrl` |
|---|---|
| Android emulator, local backend | `http://10.0.2.2:4000` (default) |
| iOS simulator, local backend | `http://localhost:4000` |
| Physical device, local backend | `http://<your-computer's-LAN-IP>:4000` |
| Any device, deployed backend | `https://rftv-backend.onrender.com` (your Render URL) |

### Run it

```bash
flutter run
```

Sign up a new account from the app (or use the same one you made admin). You should land on Home and see the seeded channels.

### Build a release APK / app bundle

```bash
flutter build apk --release        # .apk for sideloading / testing
flutter build appbundle --release  # .aab for Play Store
```

For iOS, open `mobile/ios/Runner.xcworkspace` in Xcode to set your signing team, then `flutter build ipa --release`.

---

## 5. Day-to-day: managing content

Once everything is deployed, the workflow is:

1. Sign into the **admin panel** with an admin account.
2. **Channels** — add/edit which channels appear, mark one "Live now".
3. **Programs** — build the schedule shown in "Up next" on the app.
4. **Radio** — flip the switch when RF Radio actually launches, edit the coming-soon copy until then.
5. **Donations** — set preset amounts and which mobile money providers are enabled; see incoming donation records.
6. **Users** — see who's signed up. Grant new admins with `npm run set-admin -- email@x.com` in the backend (there's no UI for this on purpose — it's a sensitive action best done from a trusted machine).

Changes in the admin panel write to Firestore through the backend and are visible in the app the next time a screen fetches data (pull-to-refresh on Home; other screens fetch fresh on open).

---

## Before you launch (important gaps in this starter)

This gets you a real, working app end-to-end, but a few things are intentionally left
as follow-ups rather than guessed at:

- **Mobile money payments**: `POST /donations` records a donation *intent* in Firestore but does not move money. Integrate MTN Mobile Money / Airtel Money's collection APIs in `backend/src/routes/donations.ts` before this is a real payment flow.
- **Actual video/audio streaming**: screens are wired to real schedule/config data, but there's no video player yet. Add a package like `video_player` or `better_player` in Flutter and point it at your `streamUrl` fields.
- **Google sign-in**: the login screen has a Google button that's currently a visual placeholder. Wire up `google_sign_in` + Firebase's Google provider if you want it working.
- **Settings persistence**: toggle switches in the Settings screen are local-only right now; persist them to the user's Firestore doc if you want them to stick between sessions.
- **Rate limiting / abuse protection**: the backend has no rate limiting. Consider adding it (e.g. `express-rate-limit`) before opening it to the public internet.
- **Automated tests**: none included. Worth adding before this grows much further.
