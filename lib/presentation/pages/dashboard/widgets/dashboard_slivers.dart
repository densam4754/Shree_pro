import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardLoadingSliver extends StatelessWidget {
  const DashboardLoadingSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class DashboardErrorSliver extends StatelessWidget {
  const DashboardErrorSliver({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 62,
              color: isDark ? AppTheme.grey400 : AppTheme.grey500,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load analytics data',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? AppTheme.white : AppTheme.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppTheme.grey400 : AppTheme.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

