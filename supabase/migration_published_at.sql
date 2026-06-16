-- 記事の公開日時カラムを追加（バックログ: 掲載日時の表示）。
-- 本番 Supabase の SQL Editor で一度だけ実行する。冪等（既にあれば何もしない）。
-- backend が公開日時付き記事を変換する前に必ず適用すること
-- （未適用のままだと published_at 更新が失敗し status=failed になる）。
alter table articles add column if not exists published_at timestamptz;
