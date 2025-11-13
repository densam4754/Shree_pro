import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../../../core/components/app_input_field.dart';
import '../../../../../core/components/app_dialog.dart';
import '../../../../../core/components/network_check_widget.dart';
import '../../../../../core/theme/app_theme.dart';

class ResetPasswordPage extends StatefulWidget {
  final String username;
  final String otp;

  const ResetPasswordPage({
    super.key,
    required this.username,
    required this.otp,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      final newPassword = _newPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (newPassword != confirmPassword) {
        AppDialog.showError(
          context: context,
          title: 'Password Mismatch',
          message: 'New password and confirm password do not match',
        );
        return;
      }

      if (newPassword.length < 6) {
        AppDialog.showError(
          context: context,
          title: 'Invalid Password',
          message: 'Password must be at least 6 characters long',
        );
        return;
      }

      // TODO: Implement password reset API call
      // For now, show success and navigate to login
      AppDialog.showSuccess(
        context: context,
        title: 'Password Reset',
        message: 'Your password has been reset successfully',
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

            return NetworkCheckWidget(
              child: Scaffold(
      backgroundColor: isDark ? AppTheme.grey900 : AppTheme.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Bootstrap.chevron_left,
            color: isDark ? AppTheme.white : AppTheme.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_user,
                      size: 60,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                Text(
                  'Reset password',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.white : AppTheme.black,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Create your Shree Pro Account Password',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                  ),
                ),

                const SizedBox(height: 48),

                // New Password Field
                AppInputField(
                  controller: _newPasswordController,
                  labelText: 'New password',
                  hintText: 'Enter your new password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  showPasswordToggle: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Confirm Password Field
                AppInputField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm password',
                  hintText: 'Confirm your new password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  showPasswordToggle: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _newPasswordController.text.trim()) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: AppTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Login',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Login Link
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Know your password? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        ),
                        children: [
                          TextSpan(
                            text: 'Log in',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
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
      ),
    );
  }
}

