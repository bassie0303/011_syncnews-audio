# SyncNews Audio ブラウザ拡張

開いているニュース記事を、ツールバーのボタン**ワンクリック**で SyncNews Audio に登録（変換開始）する Chrome/Edge 拡張機能です。

ブックマークレット（`backend` の `/bookmarklet`）の拡張版で、ページを開いたままボタンを押すだけで登録できます。

## 仕組み

ボタンを押すと、現在タブのURLを変換ワーカーの `POST /api/submit` に送ります。
バックエンドが「記事行の作成 ＋ 変換開始」を1発で行い、アプリの一覧に「コンバート中…」として現れます。

- バッジ `…` 送信中 → `✓` 受付成功 / `✗` 失敗（数秒で消えます）
- 送信先は `background.js` の `API_BASE` 定数（本番Railway URL）

## インストール（未署名・ローカル読み込み）

Chrome / Edge:

1. `chrome://extensions`（Edge は `edge://extensions`）を開く
2. 右上の **「デベロッパー モード」** をオンにする
3. **「パッケージ化されていない拡張機能を読み込む」** をクリック
4. この `extension/` フォルダを選択
5. ツールバーに「S」アイコンが出る（見えなければパズルピース→ピン留め）

以降、登録したいニュース記事のページで **アイコンをクリック** すれば登録されます。

## 注意

- `host_permissions` は本番の変換ワーカードメインに限定しています。デプロイ先URLを変えたら
  `manifest.json` の `host_permissions` と `background.js` の `API_BASE` を更新してください。
- 現状 `/api/submit` は認証なしのため、URLを知っていれば誰でも登録できます（API消費保護は別タスク）。
- Chrome Web Store への公開は未対応（ローカル読み込みのみ）。
