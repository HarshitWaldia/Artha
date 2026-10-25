# Artha

**Your knowledge. Your tools. One place.**

Artha is a cross-platform personal knowledge and utility workspace for collecting and accessing notes, books, YouTube videos, website bookmarks, tasks, and everyday tools from the web and mobile devices.

The name *Artha* (अर्थ) is a Sanskrit word associated with meaning, purpose, and value.

> **Tagline:** Find meaning in everything.

## Vision

Artha brings the useful parts of your digital life into one organized workspace. Save something once, then access it from your web browser or mobile app. The initial sync experience is manual: users choose when to press **Sync Now**.

## Features

### Planned product features

- **Notes:** Create, edit, search, pin, tag, and organize notes.
- **Books and documents:** Upload PDFs and other supported files to private cloud storage; open them on web and mobile.
- **YouTube library:** Save video links, organize them into collections, and play supported videos with an embedded YouTube player.
- **Website bookmarks:** Save URLs with titles and tags; open pages in-app when supported, otherwise use the external browser.
- **Tasks and utilities:** To-do lists, calculator, timers, unit conversion, QR generation, and more.
- **Cross-device sync:** A manual Sync Now action to upload local changes and retrieve updates from the cloud.
- **Dark minimalist UI:** A calm dashboard designed for quick access and search.

> **Starter status:** This repository is a scaffold, not a complete production app. The dashboards and shared sync contracts provide a starting point. Authentication, persisted content workflows, file uploads, and end-to-end sync still need implementation and testing.

## Technology stack

| Area | Technology |
|---|---|
| Web | Next.js, React, TypeScript |
| Android and iOS | Expo, React Native, TypeScript |
| Shared logic | TypeScript workspace package |
| Authentication | Supabase Auth |
| Database | Supabase PostgreSQL |
| File storage | Supabase Storage with private buckets |
| Data security | PostgreSQL Row Level Security (RLS) |
| Package manager | pnpm workspaces |

## Repository structure

```text
artha/
├── apps/
│   ├── web/                  # Next.js web application
│   └── mobile/               # Expo React Native application
├── packages/
│   └── shared/               # Shared models, validation, and sync contracts
├── supabase/
│   └── migrations/           # Database schema and storage policies
├── .env.example
├── pnpm-workspace.yaml
└── README.md
```

## Prerequisites

Install the following before getting started:

- Node.js 20 or newer
- pnpm 9.x
- A Supabase account and project
- Expo Go for a quick mobile preview, or Android Studio / Xcode for native builds

## Getting started

### 1. Install dependencies

From the repository root:

```bash
pnpm install
```

### 2. Configure Supabase

1. Create a project in the Supabase dashboard.
2. Open the SQL Editor.
3. Run the migration at `supabase/migrations/0001_initial_schema.sql`.
4. Find your project URL and publishable key (or legacy anon key) in the Supabase project settings.

Do **not** put a Supabase service-role key in either client app. Client-side access must be protected by RLS policies.

### 3. Configure environment variables

Create `apps/web/.env.local`:

```dotenv
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_OR_ANON_KEY
```

Create `apps/mobile/.env`:

```dotenv
EXPO_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_OR_ANON_KEY
```

Use your actual Supabase values. Never commit real secrets or environment files to source control.

### 4. Run the web app

```bash
pnpm dev:web
```

Open the local URL printed by Next.js in your terminal, typically `http://localhost:3000`.

### 5. Run the mobile app

```bash
pnpm dev:mobile
```

Follow Expo's terminal instructions to open the app on a device or emulator. For a physical phone, make sure it can reach your development machine over the local network.

### 6. Validate the workspace

```bash
pnpm typecheck
pnpm build:web
```

These commands validate TypeScript and build the web application. Fix any reported issues before deploying.

## Manual sync design

Artha's sync flow should be explicit and safe:

1. User presses **Sync Now**.
2. The client identifies records with pending local changes.
3. Pending changes are sent to the authenticated backend.
4. Remote records updated since the last successful sync are fetched.
5. The client reconciles records and records the sync cursor.
6. The UI shows a clear result: syncing, success, or failure.

### Data integrity rules

- Use stable UUIDs for records.
- Include `created_at`, `updated_at`, and a deletion marker (`deleted_at`) where appropriate.
- Scope all records to the authenticated user.
- Use RLS to enforce ownership in PostgreSQL.
- Use idempotent writes so retries do not create duplicate records.
- Track the last successful sync cursor per account and device.
- Detect concurrent edits using a version or `updated_at` check; do not silently overwrite conflicting content.
- Treat uploaded files separately from metadata, and use private storage with user-scoped access policies.
- Keep the UI honest: never show “Synced” until all required operations succeed.

The initial scaffold does not yet provide a fully durable offline-first database. If offline editing is added, implement a local database and persistent outbox on each platform before relying on it for important content.

## Suggested database entities

The SQL migration is the source of truth for the schema included in this starter. The product is expected to grow around these entities:

- `profiles` — user profile metadata
- `notes` — note content and organization metadata
- `saved_links` — YouTube videos and website bookmarks
- `tasks` — to-do items and task state
- `files` or document metadata — file name, storage path, MIME type, and size
- private Supabase Storage bucket — actual document bytes

Recommended common fields for syncable entities include `id`, `user_id`, `created_at`, `updated_at`, and `deleted_at`. Review the migration before deploying and add any missing tables or indexes as features are implemented.

## Security checklist

- Enable and test RLS for every user-owned table.
- Keep the document bucket private.
- Validate URL schemes and uploaded file types and size limits.
- Never trust a `user_id` supplied by a client without checking the authenticated session.
- Do not expose service-role credentials to the browser or mobile bundle.
- Add rate limits and server-side validation for operations that need extra protection.
- Test cross-user access denial before release.

## Phased MVP roadmap

### Phase 1 — Foundation
- [ ] Connect Supabase Auth on web and mobile.
- [ ] Create protected routes and account sign-out.
- [ ] Implement notes CRUD and user-scoped database policies.
- [ ] Implement the manual Sync Now flow for notes.
- [ ] Add loading, empty, error, and sync-status states.
- [ ] Test creating a note on web and retrieving it on mobile after sync.

### Phase 2 — Saved resources
- [ ] Save and edit website bookmarks.
- [ ] Save YouTube URLs and retrieve metadata where available.
- [ ] Upload PDFs to private cloud storage.
- [ ] Add a PDF reader on web and mobile.
- [ ] Add tags, collections, and global search.

### Phase 3 — Productivity tools
- [ ] Add tasks and checklists.
- [ ] Add calculator, timers, unit conversion, and QR tools.
- [ ] Add saved reading position and note pinning.
- [ ] Improve keyboard navigation and accessibility.

### Phase 4 — Robustness and release
- [ ] Implement persistent local queues if offline editing is required.
- [ ] Add conflict detection, retry/backoff, and idempotency.
- [ ] Add automated tests for sync, ownership, and conflict scenarios.
- [ ] Add upload progress and storage quotas.
- [ ] Configure production environments, monitoring, backups, and app-store builds.

## Contributing

1. Create a feature branch.
2. Keep shared data types and validation in `packages/shared`.
3. Keep platform-specific UI in `apps/web` and `apps/mobile`.
4. Add tests for changes to data access or synchronization.
5. Run `pnpm typecheck` and `pnpm build:web` before opening a pull request.

## License

No license has been selected yet. Add a `LICENSE` file before distributing the project publicly.
