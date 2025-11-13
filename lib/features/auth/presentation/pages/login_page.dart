import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/components/app_input_field.dart';
import '../../../../core/components/app_dialog.dart';
import '../../../../core/components/network_check_widget.dart';
import '../../../../core/injection/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../../../core/utils/developer_logger.dart';
import '../../../../presentation/pages/dashboard/stations/dashboard.dart';
import '../bloc/auth_bloc.dart';
import 'forgot_password/forgot_password_page.dart';
import 'biometric_check_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkExistingAuth();
  }

  Future<void> _checkExistingAuth() async {
    try {
      log('Checking for existing authentication...', tag: 'LoginPage');

      // Get token from secure storage
      final token = await secureStorage.read(key: ApiEndpoints.accessTokenKey);

      // Get username from secure storage
      final username = await secureStorage.read(key: ApiEndpoints.usernameKey);

      log('Token exists: ${token != null && token.isNotEmpty}', tag: 'LoginPage');
      log('Username exists: ${username != null && username.isNotEmpty}', tag: 'LoginPage');

      // Check if we have both token and username
      if (token != null && token.isNotEmpty && username != null && username.isNotEmpty) {
        // Basic token format validation
        if (token.isEmpty || token.contains('error')) {
          log('❌ Token format invalid', tag: 'LoginPage', isError: true);
          if (mounted) {
            setState(() {
              _isCheckingAuth = false;
            });
          }
          return;
        }

        // Validate token using Cubit (clean architecture)
        // Note: We need to create a BlocProvider for this check
        // Since we're in initState, we'll use the global authBloc
        authBloc.add(ValidateTokenRequested(token: token));
        
        // Listen to the bloc state changes
        // We'll handle this in the BlocListener in the build method
        // For now, assume valid if we have token (will be validated by bloc)
        if (mounted) {
          setState(() {
            _isCheckingAuth = false;
          });
        }
      } else {
        log('No existing credentials found, showing login screen', tag: 'LoginPage');
        if (mounted) {
          setState(() {
            _isCheckingAuth = false;
          });
        }
      }
    } catch (e) {
      log('❌ Error checking authentication: $e', tag: 'LoginPage', isError: true);
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              username: _usernameController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Show loading indicator while checking authentication
    if (_isCheckingAuth) {
      return NetworkCheckWidget(
        showDialog: false,
        child: Scaffold(
          backgroundColor: isDark ? AppTheme.grey900 : AppTheme.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                ),
                const SizedBox(height: 16),
                Text(
                  'Checking authentication...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return NetworkCheckWidget(
      showDialog: false,
      child: BlocProvider.value(
        value: authBloc,
        child: Scaffold(
        backgroundColor: isDark ? AppTheme.grey900 : AppTheme.white,
        body: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) async {
              if (state is AuthLoginSuccess) {
                final username = _usernameController.text.trim();
                if (username.isEmpty) {
                  // Get username from storage if not in controller (auto-login case)
                  final storedUsername = await secureStorage.read(key: ApiEndpoints.usernameKey);
                  if (storedUsername != null && mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardPage(username: storedUsername),
                      ),
                    );
                  }
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardPage(username: username),
                    ),
                  );
                }
              } else if (state is AuthTokenValid) {
                // Token is valid, proceed with auto-login
                final username = await secureStorage.read(key: ApiEndpoints.usernameKey);
                if (username != null && mounted) {
                  log('✅ Auto-login successful for user: $username', tag: 'LoginPage', isSuccess: true);

                  // Check if biometric login is enabled
                  final biometricEnabled = sharedPreferences.getBool('biometricEnabled') ?? false;

                  if (biometricEnabled) {
                    // Navigate to biometric check page
                    log('Biometric login enabled, navigating to biometric check', tag: 'LoginPage');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BiometricCheckPage(username: username),
                      ),
                    );
                  } else {
                    // Navigate directly to dashboard
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardPage(username: username),
                      ),
                    );
                  }
                }
              } else if (state is AuthTokenInvalid) {
                log('❌ Token validation failed, showing login screen', tag: 'LoginPage', isError: true);
                // Token is invalid, user needs to login again
                // State is already set to show login screen
              } else if (state is AuthError) {
                AppDialog.showError(
                  context: context,
                  title: 'Login Failed',
                  message: state.message,
                );
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // Theme Toggle Button
                    Align(
                      alignment: Alignment.topRight,
                      child: Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return IconButton(
                            icon: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              color: isDark ? AppTheme.white : AppTheme.black,
                            ),
                            onPressed: () => themeProvider.toggleTheme(),
                            tooltip: themeProvider.isDarkMode
                                ? 'Switch to Light Mode'
                                : 'Switch to Dark Mode',
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // App Logo/Icon
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_gas_station,
                          size: 60,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // App Name
                    Text(
                      'Shree Pro',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Sign in to your account',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Username Field
                    AppInputField(
                      controller: _usernameController,
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    AppInputField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      showPasswordToggle: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Login Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () => _handleLogin(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: AppTheme.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: AppTheme.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement sign up or contact admin
                          },
                          child: Text(
                            ' Contact Admin',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
