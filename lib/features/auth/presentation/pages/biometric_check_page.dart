import 'package:flutter/material.dart';
import '../../../../core/components/network_check_widget.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/developer_logger.dart';
import '../../../../presentation/pages/dashboard/stations/dashboard.dart';
import 'login_page.dart';

/// Biometric Check Page
/// Shows a black screen with white text and lock icon for biometric authentication
class BiometricCheckPage extends StatefulWidget {
  final String username;

  const BiometricCheckPage({super.key, required this.username});

  @override
  State<BiometricCheckPage> createState() => _BiometricCheckPageState();
}

class _BiometricCheckPageState extends State<BiometricCheckPage> {
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticating = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Authenticating...';
    });

    try {
      // Check if biometrics are enabled in preferences
      // This check is done in login_page before navigating here

      // Perform biometric authentication
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Authenticate to access Shree Pro',
        useErrorDialogs: true,
        stickyAuth: true,
      );

      if (authenticated && mounted) {
        log('✅ Biometric authentication successful', tag: 'BiometricCheckPage', isSuccess: true);
        
        // Navigate to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(username: widget.username),
          ),
        );
      } else {
        if (mounted) {
          setState(() {
            _statusMessage = 'Authentication failed or cancelled';
            _isAuthenticating = false;
          });

          // Navigate back to login after showing error
          if (mounted) {
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      log('❌ Biometric authentication error: $e', tag: 'BiometricCheckPage', isError: true);
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: $e';
          _isAuthenticating = false;
        });

        // Navigate back to login after error
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
            return NetworkCheckWidget(
              child: Scaffold(
      backgroundColor: AppTheme.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Lock Text at Top
              Text(
                'Lock',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.white,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 40),

              // Lock Icon
              Icon(
                Icons.lock,
                size: 80,
                color: AppTheme.white,
              ),

              const SizedBox(height: 40),

              // Status Message
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.white.withOpacity(0.7),
                    ),
                  ),
                ),

              const Spacer(flex: 2),

              // Loading Indicator
              if (_isAuthenticating)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                ),

              const SizedBox(height: 40),

              // Retry Button (if authentication failed)
              if (!_isAuthenticating && _statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.white,
                      foregroundColor: AppTheme.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

