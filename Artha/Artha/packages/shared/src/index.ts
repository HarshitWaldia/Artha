import { z } from "zod";
export const ItemTypeSchema = z.enum(["note", "bookmark", "youtube", "document", "task"]);
export type ItemType = z.infer<typeof ItemTypeSchema>;
export const ItemSchema = z.object({
  id: z.string().uuid(), user_id: z.string().uuid(), type: ItemTypeSchema,
  title: z.string().max(500), description: z.string().max(5000).nullable().optional(),
  url: z.string().url().nullable().optional(), storage_path: z.string().nullable().optional(),
  content: z.record(z.unknown()).default({}), tags: z.array(z.string().max(64)).default([]),
  revision: z.number().int().nonnegative().default(0), created_at: z.string(), updated_at: z.string(), deleted_at: z.string().nullable().optional()
});
export type ArthaItem = z.infer<typeof ItemSchema>;
export type PendingMutation = { mutationId: string; itemId: string; operation: "upsert" | "delete"; baseRevision: number | null; payload?: Partial<ArthaItem>; queuedAt: string };
export type SyncResult = { pushed: number; pulled: number; conflicts: Array<{ itemId: string; localRevision: number | null; remoteRevision: number }>; completedAt: string };
export type SyncAdapter = {
  getPendingMutations(): Promise<PendingMutation[]>;
  pushMutations(mutations: PendingMutation[]): Promise<{ acknowledgedMutationIds: string[]; conflicts: SyncResult["conflicts"] }>;
  pullChanges(cursor: string | null): Promise<{ items: ArthaItem[]; nextCursor: string | null }>;
  applyRemoteItems(items: ArthaItem[]): Promise<void>;
  acknowledgeMutations(ids: string[]): Promise<void>;
  saveCursor(cursor: string | null): Promise<void>;
};
/** Called only from the user's Sync Now action. Platform adapters must persist queue/cursor durably. */
export async function syncNow(adapter: SyncAdapter, cursor: string | null): Promise<SyncResult> {
  const pending = await adapter.getPendingMutations();
  const push = await adapter.pushMutations(pending);
  await adapter.acknowledgeMutations(push.acknowledgedMutationIds);
  const pull = await adapter.pullChanges(cursor);
  await adapter.applyRemoteItems(pull.items);
  await adapter.saveCursor(pull.nextCursor);
  return { pushed: push.acknowledgedMutationIds.length, pulled: pull.items.length, conflicts: push.conflicts, completedAt: new Date().toISOString() };
}
export function classifyUrl(raw: string): "youtube" | "bookmark" | "invalid" {
  try { const url = new URL(raw); if (!["http:", "https:"].includes(url.protocol)) return "invalid"; return ["youtube.com", "www.youtube.com", "youtu.be", "m.youtube.com"].includes(url.hostname) ? "youtube" : "bookmark"; }
  catch { return "invalid"; }
}
