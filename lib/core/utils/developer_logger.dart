import 'package:flutter/foundation.dart';

/// Simple log function for debugging
/// [isError] - if true, adds ❌ emoji for error logs
/// [isSuccess] - if true, adds ✅ emoji for success logs
void log(String message, {String? tag, bool isError = false, bool isSuccess = false}) {
  if (kDebugMode) {
    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag ?? 'ShreePro';
    String emoji = '';
    if (isError) {
      emoji = '❌ ';
    } else if (isSuccess) {
      emoji = '✅ ';
    }
    debugPrint('[$logTag] [$timestamp] $emoji$message');
  }
}

