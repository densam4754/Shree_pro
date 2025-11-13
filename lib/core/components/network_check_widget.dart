import 'package:flutter/material.dart';
import '../network/network_info.dart';
import 'app_toast.dart';
import 'app_dialog.dart';

/// A widget that checks network connectivity on initState
/// and shows a toast/dialog if no connection is detected
/// 
/// Usage:
/// ```dart
/// NetworkCheckWidget(
///   child: YourPage(),
///   showDialog: true, // Show dialog instead of toast (default: false)
/// )
/// ```
class NetworkCheckWidget extends StatefulWidget {
  final Widget child;
  
  /// Whether to show a dialog instead of toast (default: false = toast)
  final bool showDialog;
  
  /// Custom message to show when offline
  final String? offlineMessage;
  
  /// Custom title for offline message
  final String? offlineTitle;

  const NetworkCheckWidget({
    super.key,
    required this.child,
    this.showDialog = false,
    this.offlineMessage,
    this.offlineTitle,
  });

  @override
  State<NetworkCheckWidget> createState() => _NetworkCheckWidgetState();
}

class _NetworkCheckWidgetState extends State<NetworkCheckWidget> {
  bool _hasShownOfflineMessage = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivityOnInit();
  }

  Future<void> _checkConnectivityOnInit() async {
    // Small delay to ensure context and plugins are ready
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;

    try {
      // Use NetworkChecker.checkConnection() which includes DNS fallback verification
      final isConnected = await NetworkChecker.checkConnection();

      // Debug log to see what's happening
      debugPrint('NetworkCheckWidget: NetworkChecker.checkConnection() result: $isConnected');

      if (!isConnected && !_hasShownOfflineMessage) {
        debugPrint('NetworkCheckWidget: No internet connection detected');
        _hasShownOfflineMessage = true;
        _showOfflineMessage();
      } else if (isConnected) {
        debugPrint('NetworkCheckWidget: Connection available, no error shown');
      }
    } catch (e) {
      // If check fails, log but don't show error (might be temporary)
      debugPrint('NetworkCheckWidget: Connectivity check error: $e');
      debugPrint('NetworkCheckWidget: Not showing error - assuming connection available');
    }
  }

  void _showOfflineMessage() {
    if (!mounted) return;

    final title = widget.offlineTitle ?? 'No Internet Connection';
    final message = widget.offlineMessage ?? 
        'Please check your network connection and try again.';

    if (widget.showDialog) {
      // Show dialog
      AppDialog.showError(
        context: context,
        title: title,
        message: message,
      );
    } else {
      // Show toast
      AppToast.showError(
        context: context,
        title: title,
        message: message,
        duration: const Duration(seconds: 4),
        position: ToastPosition.top,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

