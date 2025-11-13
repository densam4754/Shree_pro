import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../core/injection/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/sales/domain/entities/sale_entity.dart';
import '../../../features/sales/presentation/bloc/sales_bloc.dart';

class StationDetailsPage extends StatefulWidget {
  final String stationId;
  final String stationName;

  const StationDetailsPage({
    super.key,
    required this.stationId,
    required this.stationName,
  });

  @override
  State<StationDetailsPage> createState() => _StationDetailsPageState();
}

class _StationDetailsPageState extends State<StationDetailsPage> {
  String _selectedOilCategory = 'All';
  String _selectedDuration = 'This Week';

  // Filter sales by station and duration
  List<SaleEntity> _getStationSales(List<SaleEntity> allSales) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedDuration) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case '6 Months':
        startDate = DateTime(now.year, now.month - 6, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case '6 Years':
        startDate = DateTime(now.year - 6, 1, 1);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    return allSales.where((sale) {
      if (sale.subSpRefNum != widget.stationId) return false;

      try {
        final saleDate = _parseSaleDate(sale.slDt);
        if (saleDate == null) return false;
        if (saleDate.isBefore(startDate)) return false;
      } catch (e) {
        return false;
      }

      return true;
    }).toList();
  }

  // Apply category filter to station sales
  List<SaleEntity> _applyCategoryFilter(List<SaleEntity> stationSales) {
    if (_selectedOilCategory == 'All') return stationSales;
    final selectedCategory = _selectedOilCategory.toLowerCase();

    return stationSales.where((sale) {
      return sale.items.any((item) {
        final itemName = item.name.toLowerCase();
        return itemName == selectedCategory ||
            itemName.contains(selectedCategory) ||
            selectedCategory.contains(itemName);
      });
    }).toList();
  }

  // Extract categories from station sales
  List<String> _getOilCategories(List<SaleEntity> stationSales) {
    final categories = <String>{};
    for (var sale in stationSales) {
      for (var item in sale.items) {
        final name = item.name.trim();
        if (name.isNotEmpty) {
          categories.add(name);
        }
      }
    }
    final sorted = categories.toList()..sort();
    return ['All', ...sorted];
  }

  DateTime? _parseSaleDate(String dateStr) {
    try {
      if (dateStr.contains('T')) {
        return DateTime.parse(dateStr.split('T')[0]);
      }
      return DateTime.parse(dateStr.split(' ')[0]);
    } catch (e) {
      return null;
    }
  }

  // Calculate analytics
  Map<String, dynamic> _calculateAnalytics(List<SaleEntity> sales) {
    double totalSales = 0.0;
    int totalTransactions = 0;
    double totalProfit = 0.0;
    final Map<String, double> categorySales = {};

    for (var sale in sales) {
      totalSales += sale.billAmt;
      totalTransactions += 1;

      for (var item in sale.items) {
        totalProfit += item.profit;
        categorySales[item.name] =
            (categorySales[item.name] ?? 0.0) + item.amount;
      }
    }

    return {
      'totalSales': totalSales,
      'totalTransactions': totalTransactions,
      'totalProfit': totalProfit,
      'categorySales': categorySales,
      'averageSale': totalTransactions > 0 ? totalSales / totalTransactions : 0.0,
    };
  }

  // Get chart data
  Map<int, double> _getChartData(List<SaleEntity> sales) {
    final Map<int, double> data = {};
    final now = DateTime.now();
    int dataPoints;

    switch (_selectedDuration) {
      case 'Today':
        dataPoints = 24; // Hours
        break;
      case 'This Week':
        dataPoints = 7; // Days
        break;
      case 'This Month':
        dataPoints = 30; // Days
        break;
      case '6 Months':
        dataPoints = 6; // Months
        break;
      case 'This Year':
        dataPoints = now.month; // Months from Jan to current
        break;
      case '6 Years':
        dataPoints = 6; // Years
        break;
      default:
        dataPoints = 7;
    }

    for (int i = 0; i < dataPoints; i++) {
      data[i] = 0.0;
    }

    for (var sale in sales) {
      try {
        final saleDate = _parseSaleDate(sale.slDt);
        if (saleDate == null) continue;

        int index;
        if (_selectedDuration == 'Today') {
          // Group by hours
          final hoursDiff = now.difference(saleDate).inHours;
          if (hoursDiff >= 0 && hoursDiff < 24) {
            index = 23 - hoursDiff;
            if (index >= 0 && index < 24) {
              data[index] = (data[index] ?? 0.0) + sale.billAmt;
            }
          }
        } else if (_selectedDuration == 'This Year') {
          // Group by months from January to current month
          if (saleDate.year == now.year) {
            index = saleDate.month - 1;
            if (index >= 0 && index < now.month) {
              data[index] = (data[index] ?? 0.0) + sale.billAmt;
            }
          }
        } else if (_selectedDuration == '6 Months') {
          // Group by months for last 6 months
          final monthsDiff = (now.year - saleDate.year) * 12 + (now.month - saleDate.month);
          if (monthsDiff >= 0 && monthsDiff < 6) {
            index = 5 - monthsDiff;
            if (index >= 0 && index < 6) {
              data[index] = (data[index] ?? 0.0) + sale.billAmt;
            }
          }
        } else if (_selectedDuration == '6 Years') {
          // Group by years for last 6 years
          final yearsDiff = now.year - saleDate.year;
          if (yearsDiff >= 0 && yearsDiff < 6) {
            index = 5 - yearsDiff;
            if (index >= 0 && index < 6) {
              data[index] = (data[index] ?? 0.0) + sale.billAmt;
            }
          }
        } else {
          // This Week and This Month - group by days
          final daysDiff = now.difference(saleDate).inDays;
          if (daysDiff >= 0 && daysDiff < dataPoints) {
            index = dataPoints - 1 - daysDiff;
            if (index >= 0 && index < dataPoints) {
              data[index] = (data[index] ?? 0.0) + sale.billAmt;
            }
          }
        }
      } catch (e) {
        continue;
      }
    }

    return data;
  }

  List<String> _getChartLabels() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    switch (_selectedDuration) {
      case 'Today':
        // Show hours every 3 hours: 0:00, 3:00, 6:00, 9:00, 12:00, 15:00, 18:00, 21:00
        return List.generate(24, (i) {
          // Only show labels for every 3 hours
          if (i % 3 == 0) {
            return '$i:00';
          }
          return '';
        });
        
      case 'This Week':
        // Show days of the week
        const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        final now = DateTime.now();
        final todayIndex = now.weekday % 7; // Sunday = 0, Monday = 1, etc.
        return List.generate(7, (i) {
          // Calculate which day of the week this index represents
          final dayIndex = (todayIndex - (6 - i)) % 7;
          final adjustedIndex = dayIndex < 0 ? dayIndex + 7 : dayIndex;
          return days[adjustedIndex];
        });

      case 'This Month':
        // Show day numbers: D1, D5, D10, D15, D20, D25, D30
        return List.generate(30, (i) {
          if ((i + 1) % 5 == 0 || i == 0 || i == 29) {
            return 'D${i + 1}';
          }
          return '';
        });

      case '6 Months':
        // Show last 6 months
        return List.generate(6, (i) {
          final month = now.month - (5 - i);
          final adjustedMonth = month <= 0 ? month + 12 : month;
          return months[adjustedMonth - 1];
        });

      case 'This Year':
        // Show months from January to current month
        return List.generate(now.month, (i) {
          return months[i];
        });

      case '6 Years':
        // Show last 6 years: 2020, 2021, ..., 2025
        return List.generate(6, (i) {
          final year = now.year - (5 - i);
          return year.toString();
        });
        
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: salesBloc,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.grey900 : AppTheme.grey100,
        body: SafeArea(
          child: BlocBuilder<SalesBloc, SalesState>(
            builder: (context, state) {
              final slivers = <Widget>[
                SliverAppBar(
                  backgroundColor: isDark ? AppTheme.grey800 : AppTheme.white,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  leading: IconButton(
                    icon: Icon(
                      Bootstrap.chevron_left,
                      color: isDark ? AppTheme.white : AppTheme.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    widget.stationName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.white : AppTheme.black,
                    ),
                  ),
                ),
              ];

              if (state is SalesLoading || state is SalesInitial || state is SalesRefreshing) {
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
              } else if (state is SalesError) {
                slivers.add(
                  SliverFillRemaining(
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
                            'Unable to load station analytics',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark ? AppTheme.white : AppTheme.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                final allSales = state is SalesLoaded ? state.sales : <SaleEntity>[];
                final stationSales = _getStationSales(allSales);
                final oilCategories = _getOilCategories(stationSales);

                if (_selectedOilCategory != 'All' &&
                    !oilCategories.contains(_selectedOilCategory)) {
                  _selectedOilCategory = 'All';
                }

                final filteredSales = _applyCategoryFilter(stationSales);
                final analytics = _calculateAnalytics(filteredSales);
                final chartData = _getChartData(filteredSales);
                final chartLabels = _getChartLabels();

                slivers.add(
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildFilterDropdown(
                                  context: context,
                                  value: _selectedOilCategory,
                                  items: oilCategories,
                                  label: 'Oil Category',
                                  isDark: isDark,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOilCategory = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFilterDropdown(
                                  context: context,
                                  value: _selectedDuration,
                                  items: const [
                                    'Today',
                                    'This Week',
                                    'This Month',
                                    '6 Months',
                                    'This Year',
                                    '6 Years'
                                  ],
                                  label: 'Duration',
                                  isDark: isDark,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDuration = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGradientAnalyticsCard(
                                  context: context,
                                  title: 'Total Sales',
                                  value: _formatCurrency(
                                      analytics['totalSales'] as double),
                                  icon: Icons.attach_money,
                                  gradientColors: const [
                                    Color(0xFF6366F1),
                                    Color(0xFF8B5CF6)
                                  ],
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildGradientAnalyticsCard(
                                  context: context,
                                  title: 'Transactions',
                                  value:
                                      '${analytics['totalTransactions'] as int}',
                                  icon: Icons.receipt_long,
                                  gradientColors: const [
                                    Color(0xFF10B981),
                                    Color(0xFF059669)
                                  ],
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGradientAnalyticsCard(
                                  context: context,
                                  title: 'Total Profit',
                                  value: _formatCurrency(
                                      analytics['totalProfit'] as double),
                                  icon: Icons.trending_up,
                                  gradientColors: const [
                                    Color(0xFFF59E0B),
                                    Color(0xFFEF4444)
                                  ],
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildGradientAnalyticsCard(
                                  context: context,
                                  title: 'Avg. Sale',
                                  value: _formatCurrency(
                                      analytics['averageSale'] as double),
                                  icon: Icons.calculate,
                                  gradientColors: const [
                                    Color(0xFFEC4899),
                                    Color(0xFFDB2777)
                                  ],
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        AppTheme.grey800,
                                        AppTheme.grey800.withOpacity(0.95)
                                      ]
                                    : [Colors.white, const Color(0xFFF8FAFC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.grey700.withOpacity(0.5)
                                    : const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sales Trend',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppTheme.white
                                        : AppTheme.black,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 250,
                                  child: LineChart(
                                    LineChartData(
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval:
                                            _getMaxChartValue(chartData) / 5,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: isDark
                                                ? AppTheme.grey700
                                                : AppTheme.grey200,
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            interval:
                                                _getMaxChartValue(chartData) /
                                                    5,
                                            getTitlesWidget: (value, meta) {
                                              if (value == 0) {
                                                return const SizedBox();
                                              }
                                              return Text(
                                                _formatCurrencyCompact(value),
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8),
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
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      minX: 0,
                                      maxX: (chartData.length - 1).toDouble(),
                                      minY: 0,
                                      maxY:
                                          _getMaxChartValue(chartData) * 1.2,
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: _buildChartSpots(chartData),
                                          isCurved: true,
                                          color: AppTheme.primaryBlue,
                                          barWidth: 3,
                                          dotData: FlDotData(
                                            show: true,
                                            getDotPainter: (spot, percent,
                                                barData, index) {
                                              return FlDotCirclePainter(
                                                radius: 4,
                                                color: Colors.white,
                                                strokeWidth: 2,
                                                strokeColor:
                                                    AppTheme.primaryBlue,
                                              );
                                            },
                                          ),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            gradient: LinearGradient(
                                              colors: [
                                                AppTheme.primaryBlue
                                                    .withOpacity(0.3),
                                                AppTheme.primaryBlue
                                                    .withOpacity(0.0),
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
                          ),
                          const SizedBox(height: 24),
                          if ((analytics['categorySales']
                                  as Map<String, double>)
                              .isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          AppTheme.grey800,
                                          AppTheme.grey800.withOpacity(0.95)
                                        ]
                                      : [Colors.white, const Color(0xFFF8FAFC)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.grey700.withOpacity(0.5)
                                      : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color(0xFF10B981).withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sales by Category',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppTheme.white
                                          : AppTheme.black,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...(analytics['categorySales']
                                          as Map<String, double>)
                                      .entries
                                      .map(
                                        (entry) => _buildCategoryItem(
                                          context: context,
                                          category: entry.key,
                                          amount: entry.value,
                                          total: analytics['totalSales']
                                              as double,
                                          isDark: isDark,
                                        ),
                                      )
                                      .toList(),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: slivers,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required BuildContext context,
    required String value,
    required List<String> items,
    required String label,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.grey700 : AppTheme.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.grey600 : AppTheme.grey300,
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: isDark ? AppTheme.grey800 : AppTheme.white,
        style: TextStyle(
          color: isDark ? AppTheme.white : AppTheme.black,
          fontSize: 14,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildGradientAnalyticsCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
    required bool isDark,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradientColors[0].withOpacity(0.6),
                gradientColors[1].withOpacity(0.25),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.6),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.85),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required String category,
    required double amount,
    required double total,
    required bool isDark,
  }) {
    final percentage = total > 0 ? (amount / total * 100) : 0.0;
    
    // Different gradient colors for different categories
    final gradientColors = _getCategoryGradient(category);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.grey700.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: gradientColors[0].withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.white : AppTheme.black,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors.map((c) => c.withOpacity(0.15)).toList(),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_formatCurrency(amount)} (${percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: gradientColors[0],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.grey600 : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Color> _getCategoryGradient(String category) {
    final categoryLower = category.toLowerCase();
    if (categoryLower.contains('petroleum') || categoryLower.contains('petrol')) {
      return [const Color(0xFF3B82F6), const Color(0xFF2563EB)];
    } else if (categoryLower.contains('diesel')) {
      return [const Color(0xFF10B981), const Color(0xFF059669)];
    } else if (categoryLower.contains('kerosene')) {
      return [const Color(0xFFF59E0B), const Color(0xFFEF4444)];
    } else {
      return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
    }
  }

  List<FlSpot> _buildChartSpots(Map<int, double> data) {
    final spots = <FlSpot>[];
    final length = data.length;
    for (int i = 0; i < length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i] ?? 0.0));
    }
    return spots;
  }

  double _getMaxChartValue(Map<int, double> data) {
    if (data.isEmpty) return 10000.0;
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    return maxValue > 0 ? maxValue : 10000.0;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${amount.toStringAsFixed(0)}';
    }
  }

  String _formatCurrencyCompact(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return '\$${amount.toStringAsFixed(0)}';
    }
  }
}

