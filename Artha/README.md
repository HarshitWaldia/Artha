# Artha starter

Cross-platform personal knowledge and utility app: Next.js web, Expo React Native mobile, TypeScript shared package, Supabase Auth/Postgres/Storage.

## Requirements
- Node.js 20+
- pnpm 9+
- Supabase project

## Setup
1. `npm install -g pnpm`
2. `pnpm install`
3. Run `supabase/migrations/0001_initial_schema.sql` in Supabase SQL Editor.
4. Create `apps/web/.env.local` with `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`.
5. Create `apps/mobile/.env` with `EXPO_PUBLIC_SUPABASE_URL` and `EXPO_PUBLIC_SUPABASE_ANON_KEY`.
6. `pnpm dev:web` or `pnpm dev:mobile`.

Never put a service-role key in a client app. The dashboard buttons are starter UI; authentication, item CRUD, durable local queues and the actual sync adapters are the next implementation steps.

## Sync design
Manual only: when the user presses Sync Now, push durable queued mutations, acknowledge only confirmed mutations, pull changes since a stored cursor, apply changes, then persist the new cursor. Use stable mutation UUIDs for idempotent retries. Keep deletion tombstones until devices have synced. Detect revision conflicts; do not silently discard pending edits. Initial sync function in `packages/shared/src/index.ts` defines the contract but requires web IndexedDB and mobile SQLite adapters before production use.

## Phases
1. Auth, shared data repository, durable mutation queue, manual sync, error states.
2. Notes, bookmarks, YouTube embeds, private PDF storage and reader.
3. Tasks and utilities: calculator, unit converter, timer, color picker, password generator, QR, currency, BMI, Pomodoro.
4. Conflict UI, retries, RLS tests, accessibility, backup/data deletion, app store release.

Website embedding is not universally permitted; fall back to external browser. YouTube playback should use the official embedded player. Metadata fetching needs SSRF protection if implemented server-side.

