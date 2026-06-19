// SyncNews Audio ブラウザ拡張（MV3 service worker）。
// ツールバーボタンを押すと、現在のタブのURLを変換ワーカーへ登録する。
// バックエンドの POST /api/submit が「記事行作成＋変換開始」を1発で行う。

const API_BASE = "https://syncnews-convert-production.up.railway.app";

async function setBadge(text, color) {
  await chrome.action.setBadgeBackgroundColor({ color });
  await chrome.action.setBadgeText({ text });
}

chrome.action.onClicked.addListener(async (tab) => {
  const url = tab && tab.url ? tab.url : "";
  // 通常のWebページ以外（chrome:// 等）は登録しない。
  if (!/^https?:\/\//i.test(url)) {
    await setBadge("✗", "#dc2626");
    setTimeout(() => chrome.action.setBadgeText({ text: "" }), 4000);
    return;
  }

  await setBadge("…", "#4F46E5"); // 送信中
  try {
    const res = await fetch(`${API_BASE}/api/submit`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ url }),
    });
    const data = await res.json().catch(() => ({}));
    if (data && data.ok) {
      await setBadge("✓", "#16a34a"); // 受付成功
    } else {
      await setBadge("✗", "#dc2626"); // 受付失敗
    }
  } catch (e) {
    await setBadge("✗", "#dc2626"); // 通信失敗
  }
  // 数秒後にバッジを消す。
  setTimeout(() => chrome.action.setBadgeText({ text: "" }), 4000);
});
