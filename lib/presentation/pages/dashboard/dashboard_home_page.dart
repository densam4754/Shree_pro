import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/injection/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../features/sales/domain/entities/sale_entity.dart';
import '../../../../features/sales/presentation/bloc/sales_bloc.dart';
import '../../../../features/devices/domain/entities/device_group_entity.dart';
import '../../../features/auth/presentation/pages/profile/profile_page.dart';
import 'widgets/dashboard_company_card.dart';
import 'widgets/dashboard_metrics_grid.dart';
import 'widgets/dashboard_sales_card.dart';
import 'widgets/dashboard_slivers.dart';

class DashboardHomeContent extends StatefulWidget {
  final String username;
  const DashboardHomeContent({super.key, required this.username});

  @override
  State<DashboardHomeContent> createState() => _DashboardHomeContentState();
}

class _DashboardHomeContentState extends State<DashboardHomeContent> {
  static const List<String> _periodOptions = [
    'Today',
    'This Week',
    'This Month',
    '6 Months',
    'This Year',
    '6 Years',
  ];

  String _selectedPeriod = 'This Week';
  String? _username;
  String? _firstName;
  String? _lastName;
  List<DeviceGroupEntity> _deviceGroups = const [];
  DeviceGroupEntity? _selectedGroup;
  bool _isLoadingDevices = false;
  String? _devicesError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDeviceGroups();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesBloc>().add(LoadSales());
    });
  }

  Future<void> _loadUserData() async {
    final username = sharedPreferences.getString(ApiConstants.usernameKey);
    final firstName = sharedPreferences.getString(
      ApiConstants.userFirstNameKey,
    );
    final lastName = sharedPreferences.getString(ApiConstants.userLastNameKey);

    if (mounted) {
      setState(() {
        _username = username ?? widget.username;
        _firstName = firstName;
        _lastName = lastName;
      });
    }
  }

  Future<void> _loadDeviceGroups() async {
    setState(() {
      _isLoadingDevices = true;
      _devicesError = null;
    });

    final result = await getDevicesForCurrentCompanyUseCase(const NoParams());
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoadingDevices = false;
          _deviceGroups = const [];
          _selectedGroup = null;
          _devicesError = failure.message;
        });
      },
      (groups) {
        setState(() {
          _isLoadingDevices = false;
          _deviceGroups = groups;
          _selectedGroup = groups.isNotEmpty ? groups.first : null;
        });
      },
    );
  }

  String _getUserInitials() {
    if (_firstName != null &&
        _firstName!.isNotEmpty &&
        _lastName != null &&
        _lastName!.isNotEmpty) {
      final firstInitial = _firstName![0].toUpperCase();
      final lastInitial = _lastName![0].toUpperCase();
      return '$firstInitial$lastInitial';
    }
    if (_username != null && _username!.isNotEmpty) {
      return _username![0].toUpperCase();
    }
    return '--';
  }

  List<SaleEntity> _filterSalesBySelectedStations(List<SaleEntity> sales) {
    if (_selectedGroup == null) return sales;
    final stationRefs =
        _selectedGroup!.stations.map((station) => station.subSpRefNum).toSet();
    if (stationRefs.isEmpty) return sales;
    return sales
        .where((sale) => stationRefs.contains(sale.subSpRefNum))
        .toList();
  }

  // Build AppBar widget content for Stack
  Widget _buildAppBarWidget(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    double statusBarHeight,
    double toolbarHeight,
    double gradientExtendHeight,
    double totalHeight,
  ) {
    return Stack(
      children: [
        // Gradient background - extends down
        Positioned.fill(
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
        // AppBar content - positioned at top only
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: statusBarHeight + toolbarHeight,
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
                      onPressed: () => Scaffold.of(context).openDrawer(),
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
                        _username ?? widget.username,
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfilePage(username: widget.username),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.25),
                      child: Text(
                        _getUserInitials(),
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
    );
  }

  String _periodAverageLabel(String period) {
    switch (period) {
      case 'Today':
        return 'Avg. Hourly Sales';
      case 'This Week':
      case 'This Month':
        return 'Avg. Daily Sales';
      case '6 Months':
      case 'This Year':
        return 'Avg. Monthly Sales';
      default:
        return 'Avg. Yearly Sales';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, state) {
        // Calculate heights for positioning
        final statusBarHeight = MediaQuery.of(context).padding.top;
        final toolbarHeight = 72.0;
        final contentHeight = statusBarHeight + toolbarHeight;
        final gradientExtendHeight = 80.0;
        final totalHeight = contentHeight + gradientExtendHeight;
        final cardHeight = 120.0; // Approximate card height for centering

        final slivers = <Widget>[
          // Stack with gradient background and floating company card
          SliverToBoxAdapter(
            child: SizedBox(
              height: totalHeight + (cardHeight / 2), // Space for floating card below gradient
              child: Stack(
                children: [
                  // AppBar gradient background - extends down
                  _buildAppBarWidget(
                    context,
                    theme,
                    isDark,
                    statusBarHeight,
                    toolbarHeight,
                    gradientExtendHeight,
                    totalHeight,
                  ),
                  // Company card floating outside gradient - gradient bottom line cuts through card center
                  Positioned(
                    top: totalHeight - (cardHeight / 2), // Gradient bottom line cuts through card center
                    left: 20,
                    right: 20,
                    child: Material(
                      color: Colors.transparent,
                      elevation: 8,
                      borderRadius: BorderRadius.circular(16),
                      shadowColor: Colors.black.withOpacity(0.1),
                      child: DashboardCompanyCard(
                        theme: theme,
                        isDark: isDark,
                        isLoading: _isLoadingDevices,
                        errorMessage: _devicesError,
                        selectedGroup: _selectedGroup,
                        deviceGroups: _deviceGroups,
                        onGroupSelected: (group) {
                          setState(() {
                            _selectedGroup = group;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];

        if (state is SalesLoading ||
            state is SalesInitial ||
            state is SalesRefreshing) {
          slivers.add(const DashboardLoadingSliver());
        } else if (state is SalesError) {
          slivers.add(DashboardErrorSliver(message: state.message));
        } else if (state is SalesLoaded) {
          final filteredSales = _filterSalesBySelectedStations(state.sales);
          final analytics = _calculateSalesAnalytics(filteredSales);
          final chartData = _getChartDataByPeriod(
            filteredSales,
            _selectedPeriod,
          );
          final total = chartData.values.fold<double>(
            0.0,
            (sum, value) => sum + value,
          );
          final average = chartData.isNotEmpty ? total / chartData.length : 0.0;
          final chartLabels = _getChartLabels(
            _selectedPeriod,
            chartData.length,
          );

          slivers
              ..add(
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: DashboardMetricsGrid(
                    isDark: isDark,
                    metrics: [
                      DashboardMetricTileData(
                        icon: Icons.today_outlined,
                        iconColor: const Color(0xFF6366F1),
                        iconBgColor: const Color(0xFF6366F1).withOpacity(0.1),
                        title: "Today's Sales",
                        value: _formatCurrency(analytics['today'] ?? 0.0),
                      ),
                      DashboardMetricTileData(
                        icon: Icons.calendar_view_week_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                        iconBgColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                        title: "This Week's Sales",
                        value: _formatCurrency(analytics['week'] ?? 0.0),
                      ),
                      DashboardMetricTileData(
                        icon: Icons.calendar_month_outlined,
                        iconColor: const Color(0xFF10B981),
                        iconBgColor: const Color(0xFF10B981).withOpacity(0.1),
                        title: "This Month's Sales",
                        value: _formatCurrency(analytics['month'] ?? 0.0),
                      ),
                      DashboardMetricTileData(
                        icon: Icons.local_gas_station_outlined,
                        iconColor: const Color(0xFFEC4899),
                        iconBgColor: const Color(0xFFEC4899).withOpacity(0.1),
                        title: 'Total Stations',
                        value:
                            '${_selectedGroup?.stations.length ?? analytics['stations'] ?? 0}',
                      ),
                    ],
                  ),
                ),
              ),
            )
            ..add(
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: DashboardSalesCard(
                    theme: theme,
                    isDark: isDark,
                    selectedPeriod: _selectedPeriod,
                    periodOptions: _periodOptions,
                    totalLabel: _formatCurrency(total),
                    averageLabel: _formatCurrency(average),
                    averageDescription: _periodAverageLabel(_selectedPeriod),
                    chartLabels: chartLabels,
                    chartData: chartData,
                    spots: _buildChartSpots(chartData),
                    maxY: _getMaxChartValue(chartData) * 1.2,
                    compactFormatter: _formatCurrencyCompact,
                    onPeriodChanged: (value) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                    },
                  ),
                ),
              ),
            )
            ..add(
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 24),
                sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
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
    );
  }

  Map<String, dynamic> _calculateSalesAnalytics(List<SaleEntity> sales) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday % 7));
    final monthStart = DateTime(now.year, now.month, 1);

    double todayTotal = 0.0;
    double weekTotal = 0.0;
    double monthTotal = 0.0;
    final Set<String> stations = {};

    for (var sale in sales) {
      try {
        final saleDate = _parseSaleDate(sale.slDt);
        if (saleDate == null) continue;

        if (sale.subSpRefNum.isNotEmpty) {
          stations.add(sale.subSpRefNum);
        }

        if (saleDate.isAfter(today.subtract(const Duration(days: 1))) &&
            saleDate.isBefore(today.add(const Duration(days: 1)))) {
          todayTotal += sale.billAmt;
        }

        if (saleDate.isAfter(weekStart.subtract(const Duration(days: 1)))) {
          weekTotal += sale.billAmt;
        }

        if (saleDate.isAfter(monthStart.subtract(const Duration(days: 1)))) {
          monthTotal += sale.billAmt;
        }
      } catch (e) {
        continue;
      }
    }

    return {
      'today': todayTotal,
      'week': weekTotal,
      'month': monthTotal,
      'stations': stations.length,
    };
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

  Map<int, double> _getChartDataByPeriod(
    List<SaleEntity> sales,
    String period,
  ) {
    final now = DateTime.now();
    final Map<int, double> periodData = {};

    if (period == 'Today') {
      for (int i = 0; i < 24; i++) {
        periodData[i] = 0.0;
      }
      for (var sale in sales) {
        try {
          final saleDate = _parseSaleDate(sale.slDt);
          if (saleDate == null) continue;
          final hoursDiff = now.difference(saleDate).inHours;
          if (hoursDiff >= 0 && hoursDiff < 24) {
            final hourIndex = 23 - hoursDiff.toInt();
            periodData[hourIndex] =
                (periodData[hourIndex] ?? 0.0) + sale.billAmt;
          }
        } catch (e) {
          continue;
        }
      }
    } else if (period == 'This Week') {
      for (int i = 0; i < 7; i++) {
        periodData[i] = 0.0;
      }
      for (var sale in sales) {
        try {
          final saleDate = _parseSaleDate(sale.slDt);
          if (saleDate == null) continue;
          final daysDiff = now.difference(saleDate).inDays;
          if (daysDiff >= 0 && daysDiff < 7) {
            final dayIndex = 6 - daysDiff;
            periodData[dayIndex] = (periodData[dayIndex] ?? 0.0) + sale.billAmt;
          }
        } catch (e) {
          continue;
        }
      }
    } else if (period == 'This Month') {
      for (int i = 0; i < 30; i++) {
        periodData[i] = 0.0;
      }
      for (var sale in sales) {
        try {
          final saleDate = _parseSaleDate(sale.slDt);
          if (saleDate == null) continue;
          final daysDiff = now.difference(saleDate).inDays;
          if (daysDiff >= 0 && daysDiff < 30) {
            final dayIndex = 29 - daysDiff;
            periodData[dayIndex] = (periodData[dayIndex] ?? 0.0) + sale.billAmt;
          }
        } catch (e) {
          continue;
        }
      }
    } else if (period == '6 Months') {
      for (int i = 0; i < 6; i++) {
        periodData[i] = 0.0;
      }
      for (var sale in sales) {
        try {
          final saleDate = _parseSaleDate(sale.slDt);
          if (saleDate == null) continue;
          final monthsDiff =
              (now.year - saleDate.year) * 12 + (now.month - saleDate.month);
          if (monthsDiff >= 0 && monthsDiff < 6) {
            final monthIndex = 5 - monthsDiff;
            periodData[monthIndex] =
                (periodData[monthIndex] ?? 0.0) + sale.billAmt;
          }
        } catch (e) {
          continue;
        }
      }
    } else if (period == 'This Year') {
      final currentMonth = now.month;
      for (int i = 0; i < currentMonth; i++) {
        periodData[i] = 0.0;
      }
      for (var sale in sales) {
        try {
          final saleDate = _parseSaleDate(sale.slDt);
          if (saleDate == null) continue;
          if (saleDate.year == now.year) {
            final monthIndex = saleDate.month - 1;
            if (monthIndex >= 0 && monthIndex < currentMonth) {
              periodData[monthIndex] =
                  (periodData[monthIndex] ?? 0.0) + sale.billAmt;
            }
          }
        } catch (e) {
          continue;
        }
      }
    } else if (period == '6 Years') {
      for (int i = 0; i < 6; i++) {
        periodData[i] = 0.0;
      }
      for (var sale in sales) {
        try {
          final saleDate = _parseSaleDate(sale.slDt);
          if (saleDate == null) continue;
          final yearsDiff = now.year - saleDate.year;
          if (yearsDiff >= 0 && yearsDiff < 6) {
            final yearIndex = 5 - yearsDiff;
            periodData[yearIndex] =
                (periodData[yearIndex] ?? 0.0) + sale.billAmt;
          }
        } catch (e) {
          continue;
        }
      }
    }

    return periodData;
  }

  List<String> _getChartLabels(String period, int dataLength) {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (period == 'Today') {
      return List.generate(dataLength, (i) {
        if (i % 3 == 0) {
          return '$i:00';
        }
        return '';
      });
    } else if (period == 'This Week') {
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      final todayIndex = now.weekday % 7;
      return List.generate(dataLength, (i) {
        final dayIndex = (todayIndex - (6 - i)) % 7;
        final adjustedIndex = dayIndex < 0 ? dayIndex + 7 : dayIndex;
        return days[adjustedIndex];
      });
    } else if (period == 'This Month') {
      return List.generate(dataLength, (i) {
        if ((i + 1) % 5 == 0 || i == 0 || i == 29) {
          return 'D${i + 1}';
        }
        return '';
      });
    } else if (period == '6 Months') {
      return List.generate(dataLength, (i) {
        final month = now.month - (5 - i);
        final adjustedMonth = month <= 0 ? month + 12 : month;
        return months[adjustedMonth - 1];
      });
    } else if (period == 'This Year') {
      return List.generate(dataLength, (i) {
        return months[i];
      });
    } else if (period == '6 Years') {
      return List.generate(dataLength, (i) {
        final year = now.year - (5 - i);
        return year.toString();
      });
    }
    return [];
  }

  List<FlSpot> _buildChartSpots(Map<int, double> periodData) {
    final spots = <FlSpot>[];
    final length = periodData.length;
    for (int i = 0; i < length; i++) {
      spots.add(FlSpot(i.toDouble(), periodData[i] ?? 0.0));
    }
    return spots;
  }

  double _getMaxChartValue(Map<int, double> data) {
    if (data.isEmpty) return 10000.0;
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    return maxValue > 0 ? maxValue : 10000.0;
  }

  String _formatCurrency(double amount) {
    return NumberFormatter.formatCurrency(amount);
  }

  String _formatCurrencyCompact(double amount) {
    return NumberFormatter.formatCurrencyCompact(amount);
  }
}
