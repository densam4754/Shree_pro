import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'dashboard_shared_widgets.dart';

class DashboardSalesCard extends StatelessWidget {
  const DashboardSalesCard({
    super.key,
    required this.theme,
    required this.isDark,
    required this.selectedPeriod,
    required this.periodOptions,
    required this.totalLabel,
    required this.averageLabel,
    required this.averageDescription,
    required this.chartLabels,
    required this.chartData,
    required this.spots,
    required this.maxY,
    required this.compactFormatter,
    required this.onPeriodChanged,
  });

  final ThemeData theme;
  final bool isDark;
  final String selectedPeriod;
  final List<String> periodOptions;
  final String totalLabel;
  final String averageLabel;
  final String averageDescription;
  final List<String> chartLabels;
  final Map<int, double> chartData;
  final List<FlSpot> spots;
  final double maxY;
  final String Function(double value) compactFormatter;
  final ValueChanged<String> onPeriodChanged;

  double get _intervalBase {
    if (chartData.isEmpty) {
      return 10000;
    }
    final maxValue = chartData.values.reduce((a, b) => a > b ? a : b);
    return maxValue > 0 ? maxValue : 10000;
  }

  @override
  Widget build(BuildContext context) {
    final intervalBase = _intervalBase;
    final double horizontalInterval =
        intervalBase > 0 ? intervalBase / 5 : 1.0;
    final pointCount = chartData.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : AppTheme.white, // Dark grey for dark mode
        borderRadius: BorderRadius.circular(16),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sales',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.white : AppTheme.black,
                ),
              ),
              PopupMenuButton<String>(
                initialValue: selectedPeriod,
                onSelected: onPeriodChanged,
                itemBuilder: (context) => [
                  for (final period in periodOptions)
                    PopupMenuItem<String>(
                      value: period,
                      child: Text(period),
                    ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.grey700 : AppTheme.grey100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedPeriod,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              isDark ? AppTheme.white : AppTheme.grey700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: isDark ? AppTheme.white : AppTheme.grey700,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DashboardSalesStat(
                  title: 'Total Sales ($selectedPeriod)',
                  value: totalLabel,
                  theme: theme,
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: DashboardSalesStat(
                  title: averageDescription,
                  value: averageLabel,
                  theme: theme,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: horizontalInterval,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark ? AppTheme.grey700 : AppTheme.grey200,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: horizontalInterval,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return const SizedBox();
                        }
                        return Text(
                          compactFormatter(value),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? AppTheme.grey400
                                : AppTheme.grey600,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (value == value.toInt() &&
                            index >= 0 &&
                            index < chartLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              chartLabels[index],
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppTheme.grey400
                                    : AppTheme.grey600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: pointCount > 0 ? (pointCount - 1).toDouble() : 0.0,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF3B82F6),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF3B82F6),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.3),
                          const Color(0xFF3B82F6).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

