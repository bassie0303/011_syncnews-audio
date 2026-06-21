-- 公開スキーマ syncnews: 記事メタ（事実・状態・所有関係のみ）
--
-- ここには第三者著作物を置かない:
--   - タイトル（見出し）／本文／英訳 は syncnews_vault に隔離（0003 参照）
--   - source_url は「どのページか」を指すポインタ（本文そのものではない）
--
-- マルチテナント: 認証ユーザー（メールアカウント）が自分の記事だけを参照/操作できる。
-- anon には一切許可しない（旧 public スキーマの anon 全開放とは方針が異なる）。

create type syncnews.convert_status as enum ('pending', 'processing', 'ready', 'failed');

create table syncnews.articles (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade, -- 所有者
  source_url   text not null,
  source_lang  text not null check (source_lang in ('ja', 'en')),
  status       syncnews.convert_status not null default 'pending',
  published_at timestamptz,                 -- 記事の公開日時（抽出時に取得・取れなければ null）
  error        text,                        -- 失敗理由（クレジット不足/変換エラー等。表示用の状態メッセージ）
  created_at   timestamptz not null default now()
);
create index on syncnews.articles (user_id, created_at desc);

alter table syncnews.articles enable row level security;

-- 本人の記事のみ参照/作成/更新/削除可。anon は不可（policy を作らない＝拒否）。
create policy "articles own select" on syncnews.articles
  for select to authenticated using (user_id = auth.uid());
create policy "articles own insert" on syncnews.articles
  for insert to authenticated with check (user_id = auth.uid());
create policy "articles own update" on syncnews.articles
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "articles own delete" on syncnews.articles
  for delete to authenticated using (user_id = auth.uid());

-- 一覧の status 変化を Realtime 購読（メタのみ＝露出して安全）。RLS が本人分に限定する。
alter publication supabase_realtime add table syncnews.articles;
