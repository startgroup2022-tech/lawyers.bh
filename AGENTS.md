# AGENTS.md — lawyers-bh-client

The Flutter client for the Lawyers.bh platform. One app, two rooms: the client
workspace and the professional (lawyer) workspace. It talks to the **same
production backend as the website and the admin/lawyer portals** — there is no
separate mobile backend and no separate database.

## Layout

- `flutter_app/` — the Flutter app (its own git repo, branch `main`).
- The backend is **not** in this repo. It is the Next.js app in
  `startgroup2022-tech/lawyer-bh-project` at `apps/lawyers.bh` (Drizzle +
  Postgres). Read it there; never assume an endpoint from memory.

## Flutter app

```bash
cd flutter_app
flutter analyze          # must stay at "No issues found"
flutter test             # offline suite; the live tests skip without API_BASE_URL
```

Live verification against production (no account is created, no email is sent —
every auth case is a *rejected* request):

```bash
flutter test --dart-define=API_BASE_URL=https://www.lawyers.bh test/api_contract_test.dart
flutter test --dart-define=API_BASE_URL=https://www.lawyers.bh test/backend_integration_test.dart
```

`android/` and `ios/` are intentionally absent; Codemagic's workflows run
`flutter create --platforms=android,ios` before building. Do not commit them.

## The API (verified live, 2026-09)

The base URL is **`https://www.lawyers.bh`** — the mobile API is served by the
main Next.js deployment. `api.lawyers.bh` does **not** resolve, and the
`/api/v1/*` paths this app once used return **404**. Everything below was
confirmed against production.

### Envelope

Every `/api/mobile/*` route answers `{"ok": true, ...payload}` on success and
`{"ok": false, "error": "code"}` on failure. **Payload keys sit at the top
level** — there is no `data` wrapper (except `GET /api/mobile/lawyers`, which
does use `data`). `ApiClient._decode` handles both shapes.

### Client auth — `/api/mobile/client-auth/*`

Sign-in is **email + password**. Account creation and password reset use a
6-digit code sent **by email** (`mode: register|reset`); there is no SMS OTP.

| Route | Method | Body / notes |
| --- | --- | --- |
| `/login` | POST | `{email, password}` → `{ok, token, client, expiresAt}` |
| `/request` | POST | `{mode, email, password, fullName?, phone?, locale}` → `{ok, challengeId, retryAfterSeconds, expiresInSeconds}` |
| `/verify` | POST | `{challengeId, code}` → `{ok, token, client, expiresAt}` |
| `/session` | GET | bearer → `{ok, client}`; no/invalid token → `401 {ok:false,error:'unauthorized'}` |
| `/session` | DELETE | bearer → `{ok:true}` (logout) |
| `/account` | PATCH | `{fullName, phone}` → `{ok, client}` |
| `/password` | PATCH | `{currentPassword, newPassword}` |

`client` = `{id (UUID), email, fullName, phone}` — that is the whole mobile
client identity. There are no roles or permissions on it.

**Login returns `invalid_credentials` (401) for a malformed email as well as a
wrong password** — deliberate anti-enumeration. Field-level codes
(`invalid_email`, `invalid_password`, `invalid_name`, `invalid_phone`) come from
`/request`. Do not "fix" login to expect `invalid_email`.

### Who is a lawyer: the door, not a role claim

Clients and lawyers are **two disjoint account systems** in the one database:

| | Client | Lawyer |
| --- | --- | --- |
| Table | `mobile_client_accounts` | `bahrain_lawyers` |
| Sign-in | email + password | licence number + password |
| Route | `/api/mobile/client-auth/login` | `/api/lawyers/login` |
| Token | opaque, stored in `mobile_client_sessions` | signed `{lawyerId, countryCode, exp}`, 30-day TTL |
| Validated by | `GET /api/mobile/client-auth/session` | `GET /api/mobile/lawyer/session` |

Neither session carries a `role` field, and the tokens are **not
interchangeable** — a client token is rejected by the lawyer session route and
vice versa. So the app must **not** guess the account kind from a role claim:

- `AppUser.kind` (`AccountKind.client|lawyer`) records which door the session
  came through, set by the sign-in method that produced it.
- `AppUser.isProfessional` is driven by `kind`, so a lawyer session always opens
  `LawyerShell` and a client session always opens `ClientShell`.
- `account_kind` is persisted next to the token, so a restart restores the
  session through the **matching** endpoint instead of demoting a lawyer.
- `AppState.logout()` revokes a client session server-side
  (`DELETE /api/mobile/client-auth/session`); a lawyer token is stateless with no
  logout route, so clearing it locally is the whole operation.
- Every path that ends a session — logout, a rejected token, switching to guest —
  clears the token, `account_kind`, the guest flag and the in-memory user, so no
  role can survive into the next sign-in. `RootShell` shows the login screen
  whenever there is no signed-in user, which is what makes logout land on login
  instead of leaving a shell with no account behind it.

Lawyer login answers with `{success, message}` and a **status** (401 invalid
details, 403 unavailable), not an error code; the client door answers with
`{ok, error:<code>}`. `_friendlyError` handles both.

### Directory

- `GET /api/mobile/lawyers?countryCode=BH` → `{ok, countryCode, data:[{id (UUID),
  countryCode, fullNameAr, fullNameEn, phone, email, status, subscriptionType}]}`.
  Approved, active lawyers only. **No** rating, fee, bio, location, category
  filter or per-lawyer detail route — do not invent those fields.
- `GET /api/mobile/legal-documents/{terms|privacy|lawyer-agreement}?locale&countryCode`

### Lawyer (professional) side

- `POST /api/lawyers/login` `{licenseNumber, password, countryCode}` →
  `{success:true, data:{id, countryCode, licenseNumber, phone, status,
  isAvailable, token}}`. This is the **only** lawyer sign-in that issues a mobile
  lawyer token.
- With that token: `GET /api/mobile/lawyer/session`, `/earnings`, `/withdrawals`.
- `GET /api/mobile/communications/conversations` (lawyer session).

### Not available to the client app

These are real platform features, but with **no client-facing endpoint** on this
deployment. The app must say so, not render a silent empty list:

- Client messaging — `/api/mobile/communications/*` needs a lawyer session or a
  per-request SOS capability token.
- Notifications — `/api/mobile/notifications` and `/lawyer/notifications` need a
  lawyer/dispatch token. Only `/api/mobile/notification-preferences` is client-side.
- Cases, contracts, bookings, payments, leads, documents — web-portal surfaces.
  There is no client `/cases`, `/contracts`, `/bookings`, `/leads` or
  `/documents`.
- Client-created SOS requests — only the dispatch side of SOS is exposed.
- Per-lawyer detail — the directory is the only lawyer read for clients. There
  is no `/lawyers/{id}`, no rating, bio, experience, fee, city, availability or
  specialisation field anywhere in the client API. `LawyerProfileScreen` shows
  only the published directory fields (name ar/en, phone, email, status,
  subscription type) and does **not** invent the rest.

`ApiException.featureUnavailable()` (code `feature_not_available`, 501) is the
honest failure for these. Keep it: it is what stops a spinner or a fake empty
state from hiding a missing feature.

## Home sections and "قريبًا"

`home_screen.dart` orders the screen as welcome header → short banner → **main
sections grid** → featured lawyers. A section is either wired to a real
destination (directory, consult list, services → the lawyer directory) or marked
`available: false`, which renders a "قريبًا" tag and a snackbar naming the
missing API when tapped. Voice consultation, booking and emergency dispatch are
in the second group on purpose — do not point them at a fabricated screen.

## Conventions

- Arabic-first UI, RTL. All user-facing strings are Arabic.
- One brand palette in `lib/theme/app_theme.dart`: official red `#B91D1C`.
  `LawyerColors` aliases the same tokens — the professional workspace shares the
  red identity, not a separate navy/gold one. `BadgeTone` is
  `{ green, neutral, amber, red }`.
- The official mark is bundled under `assets/brand/` and rendered through
  `widgets/brand_logo.dart` (`BrandLogo` / `BrandSeal`).
- Role routing lives in `lib/screens/root_shell.dart`, driven by
  `AppState.isProfessional`. A mobile client is never professional, so a client
  always lands in `ClientShell`.
- Every call goes through `ApiClient`, which throws `ApiException` carrying the
  server's error code and message. Screens show the Arabic message.
- Screens degrade per section, not per screen: one failing endpoint shows its
  message in place while the rest of the screen keeps working.
- Loading state must always be cleared — success, error, or timeout. A hung
  request must end in an error with a retry, never a permanent spinner.

## Codemagic

`codemagic.yaml` defines three workflows. `android-debug` needs no signing keys
and is the one to run first. Replace the `CHANGE_ME@your-email.com` recipients
before running.
