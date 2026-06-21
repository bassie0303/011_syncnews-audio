# Supabase マイグレーション（手動適用）

第三者著作物を公開API経路から隔離する二スキーマ構成。**SQLの実行は手動**（Supabase SQL Editor）。

## 適用順
1. `0001_schemas.sql` — スキーマ作成・権限（syncnews / syncnews_vault）
2. `0002_syncnews_articles.sql` — 公開メタテーブル（RLS・Realtime）
3. `0003_vault_content.sql` — 金庫テーブル（タイトル・本文・英訳）

## ダッシュボードで必要な手動設定（SQLでは完結しない）

### 1. Exposed schemas（最重要・公開ゲート）
Settings → API → **Exposed schemas** に **`syncnews` だけ追加**する。
**`syncnews_vault` は絶対に追加しない**。これが第三者著作物を公開APIから出さない最後の砦。
（既存の `public` は、下の「旧構成のクローズ」が済むまでは残る点に注意）

### 2. Storage バケットを「非公開」に
- `audio` バケットを **Private** にする（公開URL不可）。
- 再生時はサーバ（Railway バックエンド / service_role）が **短期署名URL（6時間）** を発行して渡す。
- パス規約: `audio/{article_id}/{lang}.mp3`

### 3. Auth（メールアカウント）
Authentication → Providers で **Email** を有効化。RLS の `auth.uid()` に紐づくため、
記事の所有者付与（`articles.user_id`）に認証ユーザーが必要。

## 旧構成（public スキーマ）のクローズ ※未実施・別途設計
現状の本番は `public.articles / tracks / segments` を **anon に SELECT 全開放**し、
音声も **公開バケット**で、第三者著作物が露出している。新構成へ移行後に以下が必要（破壊的なので合意のうえ別途実施）:
- [ ] 旧 public の anon ポリシー撤去 / テーブル撤去
- [ ] 旧データ（タイトル・本文・音声）を新スキーマ＋非公開バケットへ移設
- [ ] `audio` バケットの公開→非公開化
- [ ] アプリ/バックエンドの読み書きを新スキーマへ切替（下記）

## アプリ/バックエンドの実装方針（合意済み・別タスク）
- **supabase-js / supabase_flutter は通常操作で schema=syncnews を使う**（`.schema('syncnews')`）。
- **vault に触る処理はサーバ側（service_role）に限定**。具体的には Railway バックエンドに
  再生用ゲート `GET /api/playback/{id}` を追加し、本人認証＋所有チェックのうえで
  「本文セグメント（日英）＋日英音声の署名URL（6時間）」を返す。
- 一覧/状態/Realtime は `syncnews.articles` を直読み（メタのみ＝安全）。タイトルはゲート経由で取得。
