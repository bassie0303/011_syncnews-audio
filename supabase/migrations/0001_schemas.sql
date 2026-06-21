-- SyncNews Audio: スキーマ分離（公開 syncnews / 金庫 syncnews_vault）
--
-- 目的: 第三者著作物（記事本文・原文・その英訳・その音声）を公開API経路から隔離する。
--   - syncnews        … 公開スキーマ。Exposed・RLSでマルチテナント制御。事実/状態/所有のみ。
--   - syncnews_vault  … 金庫スキーマ。非Exposed。第三者著作物を隔離。service_role / Edge Function のみ。
--
-- 重要: Supabase ダッシュボードの「Exposed schemas」には **syncnews だけ** 追加し、
--       **syncnews_vault は追加しない**（これが公開ゲート）。詳細は README / CLAUDE.md 参照。
--
-- 適用は手動（Supabase SQL Editor）で、0001 → 0002 → 0003 の順に実行する。

-- ── 公開スキーマ（Exposed・RLS） ───────────────────────────────
create schema if not exists syncnews;
grant usage on schema syncnews to anon, authenticated, service_role;
-- テーブル/シーケンスの既定権限。行アクセスは各テーブルの RLS で制御する。
alter default privileges in schema syncnews
  grant all on tables to authenticated, service_role;
alter default privileges in schema syncnews
  grant all on sequences to authenticated, service_role;

-- ── 金庫スキーマ（非Exposed・service_role 専用） ──────────────
create schema if not exists syncnews_vault;
-- anon/authenticated には usage を渡さない＝公開APIから到達不能にする。
revoke all on schema syncnews_vault from anon, authenticated;
grant usage on schema syncnews_vault to service_role;
alter default privileges in schema syncnews_vault
  grant all on tables to service_role;
alter default privileges in schema syncnews_vault
  grant all on sequences to service_role;
