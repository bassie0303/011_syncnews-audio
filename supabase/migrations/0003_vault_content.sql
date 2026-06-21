-- 金庫スキーマ syncnews_vault: 第三者著作物（タイトル/本文原文/英訳）
--
-- アクセスは service_role / Edge Function 経由のみ。
--   - 0001 で anon/authenticated に schema usage を渡していないため、公開APIからは到達不能。
--   - 念のためテーブルにも RLS を有効化（既定 deny。service_role は RLS をバイパスする）。
--   - 音声ファイル（本文の二次的著作物）は Storage の「非公開バケット」に置き、
--     再生時に service_role が短期署名URL（6時間）を発行して渡す（DBには本文/音声を二重に持たない）。
--     パス規約: audio/{article_id}/{lang}.mp3

-- 見出し（第三者著作物）。一覧表示はサーバゲート(Railwayバックエンド)経由で本人分のみ返す。
create table syncnews_vault.article_titles (
  article_id uuid primary key references syncnews.articles(id) on delete cascade,
  title      text not null
);
alter table syncnews_vault.article_titles enable row level security;

-- 本文セグメント（原文＋英訳）。同期ハイライト用の文単位タイムスタンプを併せ持つ。
create table syncnews_vault.segments (
  article_id uuid not null references syncnews.articles(id) on delete cascade,
  lang       text not null check (lang in ('ja', 'en')),
  idx        int  not null,            -- トラック内の連番
  text       text not null,            -- 文（第三者著作物 / 翻訳=二次的著作物）
  start_ms   int  not null,            -- トラック先頭からの開始(ms)
  end_ms     int  not null,            -- 終了(ms)
  primary key (article_id, lang, idx)
);
alter table syncnews_vault.segments enable row level security;
