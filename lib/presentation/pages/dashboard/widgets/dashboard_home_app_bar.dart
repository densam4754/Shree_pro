import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardHomeAppBar extends StatelessWidget {
  const DashboardHomeAppBar({
    super.key,
    required this.theme,
    required this.isDark,
    required this.displayName,
    required this.initials,
    required this.onMenuPressed,
    required this.onProfilePressed,
  });

  final ThemeData theme;
  final bool isDark;
  final String displayName;
  final String initials;
  final VoidCallback onMenuPressed;
  final VoidCallback onProfilePressed;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final toolbarHeight = 72.0;
    final contentHeight = statusBarHeight + toolbarHeight;
    // Extend gradient container down to go behind company card
    final gradientExtendHeight = 80.0;
    final totalHeight = contentHeight + gradientExtendHeight;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          children: [
            // Extended gradient background - positioned at top, extends down
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: totalHeight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            AppTheme.primaryBlue.withOpacity(0.28),
                            AppTheme.primaryBlue.withOpacity(0.26),
                            AppTheme.primaryBlue.withOpacity(0.24),
                            AppTheme.primaryBlue.withOpacity(0.22),
                            AppTheme.primaryBlue.withOpacity(0.20),
                            AppTheme.primaryBlue.withOpacity(0.18),
                            AppTheme.primaryBlue.withOpacity(0.15),
                            AppTheme.primaryBlue.withOpacity(0.12),
                          ]
                        : [
                            AppTheme.primaryBlue.withOpacity(0.20),
                            AppTheme.primaryBlue.withOpacity(0.19),
                            AppTheme.primaryBlue.withOpacity(0.18),
                            AppTheme.primaryBlue.withOpacity(0.16),
                            AppTheme.primaryBlue.withOpacity(0.14),
                            AppTheme.primaryBlue.withOpacity(0.12),
                            AppTheme.primaryBlue.withOpacity(0.10),
                            AppTheme.primaryBlue.withOpacity(0.08),
                          ],
                    stops: const [0.0, 0.15, 0.3, 0.45, 0.6, 0.75, 0.9, 1.0],
                  ),
                ),
              ),
            ),
            
            // Content layer - positioned at top, not affected by gradient extension
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: contentHeight,
              child: Padding(
                padding: EdgeInsets.only(top: statusBarHeight),
                child: Row(
            children: [
              SizedBox(
                width: 56,
                child: Builder(
                  builder: (context) => IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: isDark ? AppTheme.white : AppTheme.black,
                    ),
                    onPressed: onMenuPressed,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppTheme.grey300 : AppTheme.grey600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: onProfilePressed,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.25),
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

