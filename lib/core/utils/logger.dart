import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

/// Basit ve düzenli loglama aracı
class AppLogger {
  static const String _tag = 'AutoAssist';

  /// Bilgi mesajı
  static void info(String message) {
    _log('info', message);
  }

  /// Uyarı mesajı
  static void warning(String message) {
    _log('warning', message);
  }

  /// Hata mesajı
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('error', message);
    if (error != null) {
      debugPrint('[$_tag] 🚨 KRİTİK HATA: $error');
      dev.log(message, name: _tag, error: error, stackTrace: stackTrace, level: 1000);
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('[$_tag] 📜 STACK TRACE: $stackTrace');
    }
  }

  /// API istek kaydı
  static void apiRequest(String method, String url, [dynamic body]) {
    debugPrint('[$_tag] [HTTP] ⬆️ $method $url');
    if (body != null) {
      debugPrint('[$_tag] [HTTP] [body] $body');
    }
  }

  /// API yanıt kaydı
  static void apiResponse(String method, String url, int statusCode, [dynamic body]) {
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    debugPrint('[$_tag] [HTTP] $emoji $statusCode $method $url');
    if (body != null) {
      debugPrint('[$_tag] [HTTP] [response] $body');
    }
  }

  /// Supabase operasyon kaydı
  static void supabaseOp(String op, String table, [dynamic data]) {
    debugPrint('[$_tag] [⚡] [Supabase] $op -> Table: $table');
    if (data != null) {
      debugPrint('[$_tag] [⚡] [data] $data');
    }
  }

  static void _log(String level, String message) {
    final emoji = _getEmoji(level);
    debugPrint('[$_tag] [$level] $emoji $message');
  }

  static String _getEmoji(String level) {
    switch (level) {
      case 'info': return 'ℹ️';
      case 'warning': return '⚠️';
      case 'error': return '🚨';
      default: return '📝';
    }
  }
}
