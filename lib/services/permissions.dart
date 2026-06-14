import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Android 13+ (API 33) では POST_NOTIFICATIONS のランタイム許可が無いと
/// メディア通知を提示できず、`startForegroundService()` 後に `startForeground()` を
/// 5秒以内に呼べずに ANR になる。再生でフォアグラウンドサービスを起動する前に
/// 通知許可を要求しておく。
///
/// - iOS はメディア操作にこの許可が不要（Now Playing / Remote Command を使う）ため対象外。
/// - Web も対象外。
Future<void> ensureNotificationPermission() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  if (await Permission.notification.isGranted) return;
  await Permission.notification.request();
}
