import 'dart:convert';

import 'package:http/http.dart' as http;

/// Railway 上の変換ワーカー（FastAPI）への呼び出し。
///
/// `POST {base}/api/convert {article_id, source_url}` を叩いて変換を開始する。
/// 進捗は articles.status（Supabase）で管理されるため、ここでは開始だけを担う。
class ConvertApi {
  ConvertApi(this.baseUrl);

  /// 例: https://syncnews-convert.up.railway.app
  /// `--dart-define=CONVERT_API_BASE=...` で渡す。
  final String baseUrl;

  Future<void> start({
    required String articleId,
    required String sourceUrl,
  }) async {
    if (baseUrl.isEmpty) {
      throw StateError('CONVERT_API_BASE が未設定です');
    }
    final res = await http.post(
      Uri.parse('$baseUrl/api/convert'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'article_id': articleId, 'source_url': sourceUrl}),
    );
    // 変換ワーカーは失敗時も HTTP 200 + {"ok": false, "error": ...} を返す規約。
    if (res.statusCode != 200) {
      throw Exception('変換ワーカー応答エラー: ${res.statusCode} ${res.body}');
    }
  }

  /// 記事を削除（履歴削除／進行中ならコンバートのキャンセルを兼ねる）。
  /// Storage音声とDB行（cascadeでtracks/segments）を service_role で削除する。
  Future<void> deleteArticle(String articleId) async {
    if (baseUrl.isEmpty) {
      throw StateError('CONVERT_API_BASE が未設定です');
    }
    final res = await http.delete(Uri.parse('$baseUrl/api/articles/$articleId'));
    if (res.statusCode != 200) {
      throw Exception('削除に失敗: ${res.statusCode} ${res.body}');
    }
  }
}
