import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../../core/components/app_dialog.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../core/injection/injection_container.dart';
import '../../../core/services/api_endpoints.dart';
import '../../../core/services/biometric_service.dart';
import '../../../features/auth/presentation/pages/profile/profile_page.dart';

class SettingsPage extends StatefulWidget {
  final String username;
  const SettingsPage({super.key, required this.username});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _biometricEnabled = false;
  String _appVersion = '1.0.0';
  final BiometricService _biometricService = BiometricService();
  bool _isCheckingBiometric = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadBiometricSetting();
  }

  Future<void> _loadBiometricSetting() async {
    final enabled = sharedPreferences.getBool('biometricEnabled') ?? false;
    setState(() {
      _biometricEnabled = enabled;
    });
  }

  Future<void> _handleBiometricToggle(bool value) async {
    if (value) {
      // Enable biometric - check permissions and availability
      setState(() {
        _isCheckingBiometric = true;
      });

      try {
        // Check if device supports biometrics
        final isSupported = await _biometricService.isDeviceSupported();
        if (!isSupported) {
          if (!mounted) return;
          AppDialog.showError(
            context: context,
            title: 'Biometric Not Supported',
            message: 'Your device does not support biometric authentication.',
          );
          setState(() {
            _biometricEnabled = false;
            _isCheckingBiometric = false;
          });
          return;
        }

        // Check if biometrics are available
        final isAvailable = await _biometricService.isBiometricsAvailable();
        if (!isAvailable) {
          if (!mounted) return;
          AppDialog.showError(
            context: context,
            title: 'Biometric Not Available',
            message: 'Please set up biometric authentication (fingerprint or face ID) in your device settings.',
          );
          setState(() {
            _biometricEnabled = false;
            _isCheckingBiometric = false;
          });
          return;
        }

        // Test authentication to request permission
        final authenticated = await _biometricService.authenticate(
          localizedReason: 'Enable biometric login for Shree Pro',
        );

        if (authenticated) {
          // Save preference
          await sharedPreferences.setBool('biometricEnabled', true);
          setState(() {
            _biometricEnabled = true;
          });
          if (!mounted) return;
          AppDialog.showSuccess(
            context: context,
            title: 'Biometric Login Enabled',
            message: 'Biometric authentication has been enabled successfully.',
          );
        } else {
          setState(() {
            _biometricEnabled = false;
          });
        }
      } catch (e) {
        if (!mounted) return;
        AppDialog.showError(
          context: context,
          title: 'Error',
          message: 'Failed to enable biometric login: $e',
        );
        setState(() {
          _biometricEnabled = false;
        });
      } finally {
        setState(() {
          _isCheckingBiometric = false;
        });
      }
    } else {
      // Disable biometric
      await sharedPreferences.setBool('biometricEnabled', false);
      setState(() {
        _biometricEnabled = false;
      });
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await AppDialog.showConfirmation(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    );

    if (confirm == true) {
      try {
        // Clear ALL secure storage keys
        await secureStorage.delete(key: ApiEndpoints.accessTokenKey);
        await secureStorage.delete(key: ApiEndpoints.usernameKey);
        
        // Also clear any other possible auth keys
        await secureStorage.delete(key: 'access_token');
        await secureStorage.delete(key: 'username');
        await secureStorage.delete(key: 'refresh_token');
        
        // Clear ALL data from secure storage to be thorough
        await secureStorage.deleteAll();

        // Clear ALL SharedPreferences data
        await sharedPreferences.clear();
        
        // Small delay to ensure storage is cleared
        await Future.delayed(const Duration(milliseconds: 100));

        if (!mounted) return;
        
        // Navigate to login and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        AppDialog.showError(
          context: context,
          title: 'Logout Error',
          message: 'Failed to logout properly: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.grey900 : AppTheme.grey100,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              backgroundColor: isDark ? AppTheme.grey900 : AppTheme.grey100,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              floating: true,
              pinned: false,
              snap: true,
              automaticallyImplyLeading: false,
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: Icon(
                        Bootstrap.chevron_left,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              title: Text(
                'Settings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.white : AppTheme.black,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Account', isDark),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      subtitle: 'Manage your profile information',
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(username: widget.username),
                          ),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy',
                      subtitle: 'Control your privacy settings',
                      isDark: isDark,
                      onTap: () {
                        _showPrivacyDialog(context, isDark);
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Preferences', isDark),
                    const SizedBox(height: 12),
                    _buildSwitchTile(
                      icon: Icons.fingerprint_outlined,
                      title: 'Biometric Login',
                      subtitle: 'Use fingerprint or face ID',
                      value: _biometricEnabled,
                      isDark: isDark,
                      onChanged: _isCheckingBiometric
                          ? null
                          : (bool value) {
                              _handleBiometricToggle(value);
                            },
                    ),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return _buildSettingsTile(
                          icon: themeProvider.isDarkMode
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          title: 'Theme',
                          subtitle: themeProvider.isDarkMode
                              ? 'Dark Mode'
                              : themeProvider.themeMode == ThemeMode.system
                                  ? 'System Default'
                                  : 'Light Mode',
                          isDark: isDark,
                          onTap: () {
                            _showThemeSelectorDialog(
                                context, themeProvider, isDark);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('App Settings', isDark),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      subtitle: 'Read our terms and conditions',
                      isDark: isDark,
                      onTap: () {
                        _showTermsDialog(context, isDark);
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'How we protect your data',
                      isDark: isDark,
                      onTap: () {
                        _showPrivacyPolicyDialog(context, isDark);
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Support', isDark),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help with the app',
                      isDark: isDark,
                      onTap: () {
                        _showHelpDialog(context, isDark);
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.email_outlined,
                      title: 'Contact Us',
                      subtitle: 'Send us feedback or report issues',
                      isDark: isDark,
                      onTap: () {
                        _showContactDialog(context, isDark);
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      title: 'About Us',
                      subtitle: 'Learn more about Shree Pro',
                      isDark: isDark,
                      onTap: () {
                        _showAboutUsDialog(context, isDark);
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Updates', isDark),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      icon: Icons.system_update_outlined,
                      title: 'Check for Updates',
                      subtitle: 'Current version: $_appVersion',
                      isDark: isDark,
                      onTap: () {
                        _checkForUpdates(context, isDark);
                      },
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Shree Pro',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color:
                                  isDark ? AppTheme.grey400 : AppTheme.grey600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version $_appVersion',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  isDark ? AppTheme.grey500 : AppTheme.grey500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '© 2024 Shree Pro. All rights reserved.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  isDark ? AppTheme.grey500 : AppTheme.grey500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.logout,
                            size: 20, color: AppTheme.white),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.grey800 : AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: AppTheme.grey700)
            : Border.all(color: AppTheme.grey200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.white : AppTheme.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AppTheme.grey400 : AppTheme.grey600,
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? AppTheme.grey400 : AppTheme.grey600,
              size: 16,
            ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    ValueChanged<bool>? onChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.grey800 : AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: AppTheme.grey700)
            : Border.all(color: AppTheme.grey200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.white : AppTheme.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AppTheme.grey400 : AppTheme.grey600,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryBlue,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showAboutUsDialog(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.grey800 : AppTheme.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon at top
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryBlue,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Center(
                child: Text(
                  'About Shree Pro',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.white : AppTheme.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Shree Pro is a comprehensive fuel station management system designed to streamline operations and enhance productivity.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppTheme.grey300 : AppTheme.grey700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Features:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.white : AppTheme.black,
                ),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem('• Customer Management', isDark),
              _buildFeatureItem('• Sales & Purchase Tracking', isDark),
              _buildFeatureItem('• Supplier Management', isDark),
              _buildFeatureItem('• Taxpayer & Insurance Records', isDark),
              _buildFeatureItem('• Real-time Analytics & Reports', isDark),
              const SizedBox(height: 16),
              Text(
                'Version: $_appVersion',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                ),
              ),
              const SizedBox(height: 24),
              // Button at bottom
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? AppTheme.grey400 : AppTheme.grey600,
        ),
      ),
    );
  }

  void _checkForUpdates(BuildContext context, bool isDark) {
    AppDialog.showInfo(
      context: context,
      title: 'Check for Updates',
      message: 'You are using the latest version of Shree Pro.\n\nVersion: $_appVersion',
    );
  }

  void _showThemeSelectorDialog(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.grey800 : AppTheme.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Select Theme',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.white : AppTheme.black,
                ),
              ),
              const SizedBox(height: 20),
              // Theme Options
              _buildThemeOption(
                context: context,
                icon: Icons.light_mode_outlined,
                title: 'Light Mode',
                isSelected: themeProvider.themeMode == ThemeMode.light,
                isDark: isDark,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
              _buildThemeOption(
                context: context,
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                isSelected: themeProvider.themeMode == ThemeMode.dark,
                isDark: isDark,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
              _buildThemeOption(
                context: context,
                icon: Icons.brightness_auto_outlined,
                title: 'System Default',
                isSelected: themeProvider.themeMode == ThemeMode.system,
                isDark: isDark,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 24),
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withOpacity(0.1)
              : (isDark ? AppTheme.grey700 : AppTheme.grey100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : (isDark ? AppTheme.grey600 : AppTheme.grey300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryBlue
                  : (isDark ? AppTheme.grey400 : AppTheme.grey600),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : (isDark ? AppTheme.white : AppTheme.black),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.grey800 : AppTheme.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.privacy_tip_outlined,
                    color: AppTheme.primaryBlue,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Privacy Settings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.white : AppTheme.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your privacy is important to us. Shree Pro is designed to protect your data and ensure secure access to your fuel station management system.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.grey300 : AppTheme.grey700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Privacy Features:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem('• Secure authentication with biometric login', isDark),
                    _buildFeatureItem('• Encrypted data storage', isDark),
                    _buildFeatureItem('• No data sharing with third parties', isDark),
                    _buildFeatureItem('• Local data processing', isDark),
                    _buildFeatureItem('• User-controlled data access', isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.grey800 : AppTheme.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: AppTheme.primaryBlue,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Terms & Conditions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.white : AppTheme.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'By using Shree Pro, you agree to the following terms and conditions:',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.grey300 : AppTheme.grey700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '1. Usage Agreement',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You agree to use Shree Pro only for lawful purposes and in accordance with these Terms.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '2. Account Responsibility',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You are responsible for maintaining the confidentiality of your account credentials.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '3. Data Accuracy',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You are responsible for ensuring the accuracy of all data entered into the system.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '4. Service Availability',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'We reserve the right to modify or discontinue the service at any time.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.grey800 : AppTheme.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.privacy_tip_outlined,
                    color: AppTheme.primaryBlue,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Privacy Policy',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.white : AppTheme.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shree Pro is committed to protecting your privacy. This policy explains how we collect, use, and safeguard your information.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.grey300 : AppTheme.grey700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Data Collection',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'We collect only the information necessary to provide our fuel station management services. This includes account credentials, transaction data, and usage information.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Data Security',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your data is encrypted and stored securely. We use industry-standard security measures to protect your information from unauthorized access.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Data Usage',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'We use your data solely to provide and improve our services. We do not sell, trade, or share your personal information with third parties.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Rights',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You have the right to access, modify, or delete your personal data at any time through the app settings.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.grey800 : AppTheme.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline,
                    color: AppTheme.primaryBlue,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Help & Support',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.white : AppTheme.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need help? We\'re here to assist you with any questions or issues you may have.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.grey300 : AppTheme.grey700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Getting Started',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Login with your credentials\n• Navigate using the sidebar menu\n• Access your dashboard for quick insights',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Managing Data',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Add customers, suppliers, and taxpayers\n• Record sales and purchases\n• Track insurance information',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Reports & Analytics',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• View sales analytics on the dashboard\n• Generate reports for different periods\n• Export data for external analysis',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Still need help?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Contact our support team through the "Contact Us" option in settings.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.grey800 : AppTheme.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    color: AppTheme.primaryBlue,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Contact Us',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.white : AppTheme.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We\'d love to hear from you! Get in touch with us through any of the following channels:',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.grey300 : AppTheme.grey700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: 'support@shreepro.com',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: '+1 (555) 123-4567',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: '123 Business Street\nCity, State 12345',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(
                      icon: Icons.access_time_outlined,
                      label: 'Business Hours',
                      value: 'Monday - Friday: 9:00 AM - 6:00 PM\nSaturday: 10:00 AM - 4:00 PM',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'For technical support or feature requests, please include your app version and device information.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.primaryBlue,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.white : AppTheme.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

