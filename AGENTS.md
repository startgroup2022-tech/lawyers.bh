# AGENTS.md — lawyers-bh-client

Flutter client + central PHP backend for the Lawyers.bh platform. One app,
two rooms: the client workspace and the professional (lawyer) workspace.

## Layout

- `flutter_app/` — the Flutter app (its own git repo, branch `main`).
- `backend/` — PHP 8.4 backend (not a git repo; do not edit casually).

## Flutter app

```bash
cd flutter_app
flutter analyze          # must stay at "No issues found"
flutter test             # 23 tests (lawyer_workspace_test.dart + brand_identity_test.dart)
flutter build apk --debug
```

The four backend defects this app used to work around were fixed in the
backend, so the contracts below now hold.

`android/` and `ios/` are intentionally absent; Codemagic's workflows run
`flutter create --platforms=android,ios` before building. Do not commit them.
The same rule applies locally: generate them for a build, then they stay
ignored by `.gitignore`.

Both rooms share two screens that the backend scopes by membership rather than
by client-side role checks: `messages_screen.dart` (`/conversations`) and the
account hubs are reached from the client shell's "حسابي" tab and the lawyer
shell's "المزيد" tab.

### Conventions

- Arabic-first UI, RTL. All user-facing strings are Arabic.
- One brand palette in `lib/theme/app_theme.dart`: official red `#B91D1C`
  (`AppColors.brand`). `LawyerColors` is an alias of the same tokens — the
  professional workspace shares the red identity, not a separate navy/gold one.
  The retired gold (`#C59B27`) is gone; `BadgeTone` is
  `{ green, neutral, amber, red }`.
- The official mark is bundled under `assets/brand/` (`logo_color.png`,
  `logo_white.png`) and rendered through `widgets/brand_logo.dart`
  (`BrandLogo` / `BrandSeal`). Reference assets by that widget, not inline.
- Role routing lives in `lib/screens/root_shell.dart`: it picks
  `ClientShell` or `LawyerShell` from `AppState.isProfessional`, which is
  derived from `GET /auth/me` (`roles` + primary `role`). Never route on the
  OTP-verify response alone — it carries only the primary role.
- Services in `lib/services/` mirror backend modules one-to-one. Every call
  goes through `ApiClient`, which throws `ApiException` carrying the server's
  `message` and error code.
- Screens degrade per section, not per screen: one failing endpoint shows its
  server message in place while the rest of the screen keeps working. Do not
  introduce screen-wide error states for a single module.

### Backend contract notes

These are real backend behaviours the client must respect:

- `PATCH /lawyer/profile` writes **only** the fields present in the request
  (`array_intersect_key`); omitted NOT NULL columns are preserved. Verified live:
  patching one field leaves the others intact.
- `GET /lawyer/profile` works (the `lawyer_verification_events.status` column
  bug is fixed — it reads `to_status`).
- The leads write path works: `POST /leads`, `GET /leads/{id}`,
  `PATCH /leads/{id}`, `POST /leads/{id}/activities` and
  `POST /leads/{id}/convert` all succeed. The API maps its `notes` field onto
  the real `lead_activities.body` column.
- `leads.convert` requires a `client_id` on the lead and a resolvable lawyer;
  a clientless lead returns 422, not 500.
- `lawyers.languages` is stored as a JSON string, not a JSON array.

See `docs/SECTION-32-IMPLEMENTATION-REPORT.md` for the full defect list with
file/line references.

### Codemagic

`codemagic.yaml` defines three workflows. `android-debug` needs no signing
keys and is the one to run first. It still needs a git remote — the local repo
has none, so nothing can be built until the code is pushed to GitHub/GitLab/
Bitbucket. Replace the `CHANGE_ME@your-email.com` recipients before running.
