import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/onboarding_bloc.dart';
import 'onboarding_screen.dart';
import '../../../auth/presentation/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _patternController;
  late Animation<double> _fadeAnimation;
  late List<Animation<double>> _patternAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _patternController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Create staggered animations for pattern lines with sequential appearance
    _patternAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _patternController,
          curve: Interval(
            index * 0.15, // Sequential start times: 0, 0.15, 0.3
            0.7 + (index * 0.15), // Sequential end times
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _controller.forward();
    _checkOnboardingAndNavigate();
  }

  Future<void> _checkOnboardingAndNavigate() async {
    // Wait for 5 seconds total
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    // Check if onboarding is completed
    final result = await checkOnboardingStatusUseCase();

    result.fold(
      (failure) {
        // On error, go to onboarding
        _navigateToOnboarding();
      },
      (isCompleted) {
        if (isCompleted) {
          // User has completed onboarding, go directly to login
          _navigateToLogin();
        } else {
          // First time user, show onboarding
          _navigateToOnboarding();
        }
      },
    );
  }

  void _navigateToOnboarding() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BlocProvider.value(
          value: onboardingBloc..add(const LoadOnboardingPages()),
          child: const OnboardingScreen(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _patternController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated Pattern Lines Background (45-degree diagonal)
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _patternAnimations[index],
              builder: (context, child) {
                // Sequential opacity fade-in
                final baseOpacity = 0.15;
                final fadeOpacity = (_patternAnimations[index].value * 0.25).clamp(0.0, 0.25);
                final opacity = (baseOpacity + fadeOpacity).clamp(0.15, 0.4);
                
                // Calculate diagonal movement (45-degree angle)
                // Line moves diagonally from top-left to bottom-right
                final diagonalLength = screenSize.width * 1.5;
                final startOffset = -diagonalLength * 0.5;
                final movementRange = diagonalLength * 1.5;
                final translateX = startOffset + (_patternAnimations[index].value * movementRange);
                final translateY = startOffset + (_patternAnimations[index].value * movementRange);
                
                return Positioned(
                  left: translateX,
                  top: screenSize.height * 0.1 + (index * screenSize.height * 0.3) + translateY * 0.3,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: 0.785398, // 45 degrees in radians (π/4)
                      child: CustomPaint(
                        size: Size(diagonalLength, 2),
                        painter: PatternLinePainter(
                          color: isDark 
                              ? AppTheme.primaryBlue.withOpacity(0.4)
                              : AppTheme.primaryBlue.withOpacity(0.3),
                          lineWidth: 1.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Name Only - Centered
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Text(
                        'Shree Pro',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                          fontSize: 30,
                          color: isDark ? AppTheme.white : AppTheme.black,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Loading Indicator at bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Pattern Lines
class PatternLinePainter extends CustomPainter {
  final Color color;
  final double lineWidth;

  PatternLinePainter({
    required this.color,
    this.lineWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    // Draw diagonal line at 45-degree angle
    // Line goes from top-left to bottom-right
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, size.height);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PatternLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.lineWidth != lineWidth;
  }
}
