import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_theme.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

enum ToastPosition {
  top,
  bottom,
  center,
}

class AppToast {
  /// Show a toast message using fluttertoast package
  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    String? title,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    ToastPosition position = ToastPosition.top,
  }) {
    // Determine colors based on type
    Color bgColor;
    Color txtColor;

    switch (type) {
      case ToastType.success:
        bgColor = backgroundColor ?? Colors.green;
        txtColor = textColor ?? AppTheme.white;
        break;
      case ToastType.error:
        bgColor = backgroundColor ?? Colors.red;
        txtColor = textColor ?? AppTheme.white;
        break;
      case ToastType.warning:
        bgColor = backgroundColor ?? Colors.orange;
        txtColor = textColor ?? AppTheme.white;
        break;
      case ToastType.info:
        bgColor = backgroundColor ?? AppTheme.primaryBlue;
        txtColor = textColor ?? AppTheme.white;
        break;
    }

    // Map ToastPosition to ToastGravity
    ToastGravity gravity;
    switch (position) {
      case ToastPosition.top:
        gravity = ToastGravity.TOP;
        break;
      case ToastPosition.bottom:
        gravity = ToastGravity.BOTTOM;
        break;
      case ToastPosition.center:
        gravity = ToastGravity.CENTER;
        break;
    }

    // Build message with icon and title if provided
    String displayMessage = message;
    if (title != null) {
      displayMessage = '$title\n$message';
    }

    // Show toast using fluttertoast with error handling
    try {
      Fluttertoast.showToast(
        msg: displayMessage,
        toastLength: duration.inSeconds >= 4 ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: gravity,
        timeInSecForIosWeb: duration.inSeconds,
        backgroundColor: bgColor,
        textColor: txtColor,
        fontSize: 14.0,
        webBgColor: '#${((bgColor.r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}${((bgColor.g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}${((bgColor.b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}', // Convert RGB to hex
        webPosition: position == ToastPosition.top ? 'top' : (position == ToastPosition.bottom ? 'bottom' : 'center'),
      );
    } catch (e) {
      // If fluttertoast plugin is not available (needs full rebuild), fallback to debug print
      // This prevents crashes during hot reload when native plugins aren't linked
      if (e.toString().contains('MissingPluginException')) {
        // ignore: avoid_print
        // This is a fallback when the plugin isn't available - only happens during development
        debugPrint('AppToast: fluttertoast plugin not linked (needs full rebuild)');
        debugPrint('AppToast: Message would be: $displayMessage');
        // Optionally, you could use ScaffoldMessenger as fallback, but that also requires context
        // For now, just log it to avoid crashes
      } else {
        // Re-throw other errors
        rethrow;
      }
    }
  }

  /// Show success toast
  static void showSuccess({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.top,
  }) {
    show(
      context: context,
      message: message,
      type: ToastType.success,
      title: title,
      duration: duration,
      position: position,
    );
  }

  /// Show error toast
  static void showError({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
    ToastPosition position = ToastPosition.top,
  }) {
    show(
      context: context,
      message: message,
      type: ToastType.error,
      title: title,
      duration: duration,
      position: position,
    );
  }

  /// Show warning toast
  static void showWarning({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.top,
  }) {
    show(
      context: context,
      message: message,
      type: ToastType.warning,
      title: title,
      duration: duration,
      position: position,
    );
  }

  /// Show info toast
  static void showInfo({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.top,
  }) {
    show(
      context: context,
      message: message,
      type: ToastType.info,
      title: title,
      duration: duration,
      position: position,
    );
  }
}
