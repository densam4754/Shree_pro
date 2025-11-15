import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shree_pro/features/auth/data/services/user_api.dart';
import 'package:shree_pro/features/auth/domain/models/user.dart';
import 'package:shree_pro/core/components/app_dialog.dart';
import 'package:shree_pro/core/theme/app_theme.dart';
import 'package:shree_pro/core/injection/injection_container.dart';
import 'package:shree_pro/core/services/api_endpoints.dart';
import '../login_page.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserApi userApi = UserApi();
  User? user;
  bool isLoading = true;

  String _getUserInitials(User user) {
    final first = user.firstName.trim();
    final last = user.lastName.trim();
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0].toUpperCase()}${last[0].toUpperCase()}';
    }
    if (user.username.isNotEmpty) {
      final sanitized = user.username.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
      if (sanitized.length >= 2) {
        return sanitized.substring(0, 2).toUpperCase();
      }
      if (sanitized.isNotEmpty) {
        return sanitized[0].toUpperCase();
      }
    }
    return 'US';
  }

  @override
  void initState() {
    super.initState();
    _loadUserDataFromPreferences();
  }

  /// Load user data directly from SharedPreferences (no auth token required)
  Future<void> _loadUserDataFromPreferences() async {
    setState(() => isLoading = true);
    
    // Load cached user data from preferences only
    final cachedUser = await userApi.getCachedUserData();
    
    if (mounted) {
    setState(() {
        user = cachedUser;
      isLoading = false;
    });
    }
  }

  /// Manual refresh - reload from preferences
  Future<void> refreshUserData() async {
    setState(() => isLoading = true);
    await _loadUserDataFromPreferences();
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

        // Clear ALL SharedPreferences data (including cached user data)
        await sharedPreferences.clear();
        
        // Also clear user data cache flag explicitly
        await sharedPreferences.remove('userDataCached');
        
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

    final slivers = <Widget>[
      SliverAppBar(
        backgroundColor: isDark ? AppTheme.grey900 : AppTheme.grey100,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        pinned: false,
        floating: true,
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
          'Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.white : AppTheme.black,
          ),
        ),
      ),
    ];

    if (isLoading) {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          ),
        ),
      );
    } else if (user != null) {
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: 
                      // isDark
                      //     ? [
                      //         AppTheme.grey800,
                      //         AppTheme.grey700,
                      //       ] :
                           [
                              AppTheme.primaryBlue.withOpacity(0.1),
                              AppTheme.lightBlue.withOpacity(0.1),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? Border.all(color: AppTheme.grey700) : null,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryBlue,
                              AppTheme.halfDeepBlue,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getUserInitials(user!),
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: AppTheme.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "${user!.firstName} ${user!.lastName}",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.white : AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "@${user!.username}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Personal Information', isDark),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context: context,
                  icon: Icons.account_circle_outlined,
                  label: 'Username',
                  value: user!.username,
                  isDark: isDark,
                ),
                _buildInfoCard(
                  context: context,
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user!.email,
                  isDark: isDark,
                ),
                _buildInfoCard(
                  context: context,
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: user!.phone,
                  isDark: isDark,
                ),
                _buildInfoCard(
                  context: context,
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: user!.address.isNotEmpty ? user!.address : 'Not provided',
                  isDark: isDark,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Account Information', isDark),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context: context,
                  icon: Icons.badge_outlined,
                  label: 'Role',
                  value: user!.roleName,
                  isDark: isDark,
                ),
                if (user!.roleDesc.isNotEmpty)
                  _buildInfoCard(
                    context: context,
                    icon: Icons.description_outlined,
                    label: 'Role Description',
                    value: user!.roleDesc,
                    isDark: isDark,
                  ),
                const SizedBox(height: 32),
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
                    icon: const Icon(Icons.logout, size: 20, color: AppTheme.white),
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    } else {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: isDark ? AppTheme.grey400 : AppTheme.grey600,
              ),
              const SizedBox(height: 16),
              Text(
                'No profile data found',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isDark ? AppTheme.white : AppTheme.black,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Profile data will be available after login',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.grey900 : AppTheme.grey100,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refreshUserData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: slivers,
          ),
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

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: const Color(0xFF595959))
            : Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? AppTheme.white : AppTheme.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

