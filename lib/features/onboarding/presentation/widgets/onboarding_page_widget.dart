import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/onboarding_entity.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingEntity page;
  final int pageIndex;

  const OnboardingPageWidget({
    super.key,
    required this.page,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        Image.asset(
          page.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback gradient if image not found
            return Container(
              decoration: BoxDecoration(
                gradient: _getGradientForPage(pageIndex),
              ),
            );
          },
        ),

        // Dark overlay for better text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.black.withOpacity(0.4),
                AppTheme.black.withOpacity(0.5),
                AppTheme.black.withOpacity(0.6),
              ],
            ),
          ),
        ),

        // Content - Centered White Text
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title - Large White Text (Smooth and Clean)
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        fontSize: 32,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: AppTheme.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                ),

                const SizedBox(height: 24),

                // Description - Medium White Text (Smooth and Clean)
                Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.white.withOpacity(0.95),
                        height: 1.6,
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: AppTheme.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LinearGradient _getGradientForPage(int index) {
    switch (index) {
      case 0:
        return const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 1:
        return const LinearGradient(
          colors: [AppTheme.halfDeepBlue, AppTheme.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 2:
        return const LinearGradient(
          colors: [AppTheme.lightBlue, AppTheme.mediumBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 3:
        return const LinearGradient(
          colors: [AppTheme.mediumBlue, AppTheme.halfDeepBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppTheme.blueGradient;
    }
  }
}
