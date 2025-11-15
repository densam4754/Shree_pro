import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardMetricsGrid extends StatelessWidget {
  const DashboardMetricsGrid({
    super.key,
    required this.isDark,
    required this.metrics,
  });

  final bool isDark;
  final List<DashboardMetricTileData> metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final tile = metrics[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : AppTheme.white, // Dark grey for dark mode
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tile.iconColor.withOpacity(0.6), // Border: icon color with reduced opacity
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: tile.iconBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      tile.icon,
                      color: tile.iconColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tile.value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.white : AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tile.title,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardMetricTileData {
  const DashboardMetricTileData({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String value;
}

