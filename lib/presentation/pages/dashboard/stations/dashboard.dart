import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../../constants/widgets/drawer.dart';
import '../../../../core/injection/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/components/network_check_widget.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../features/sales/domain/entities/sale_entity.dart';
import '../../../../features/sales/presentation/bloc/sales_bloc.dart';
import '../../../../features/devices/domain/entities/device_group_entity.dart';
import '../../../../../features/auth/presentation/pages/profile/profile_page.dart';
import '../../../pages/settings/settings_page.dart';
import '../../../pages/stations/stations_list_page.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  const DashboardPage({super.key, required this.username});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BlocProvider.value(
        value: salesBloc,
        child: DashboardHomeContent(username: widget.username),
      ),
      BlocProvider.value(
        value: salesBloc,
        child: const StationsListPage(),
      ),
      SettingsPage(username: widget.username),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NetworkCheckWidget(
      child: _DashboardShell(
        isDark: isDark,
        drawer: const customDrawer(),
        body: _pages[_selectedIndex],
        selectedIndex: _selectedIndex,
        onTabSelected: _onItemTapped,
      ),
    );
  }
}

class _DashboardShell extends StatelessWidget {
  const _DashboardShell({
    required this.isDark,
    required this.drawer,
    required this.body,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final bool isDark;
  final Widget drawer;
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppTheme.grey900 : AppTheme.grey100,
      drawer: drawer,
      body: body,
      bottomNavigationBar: DashboardBottomNavBar(
        isDark: isDark,
        selectedIndex: selectedIndex,
        onItemSelected: onTabSelected,
      ),
    );
  }
}

class DashboardBottomNavBar extends StatelessWidget {
  const DashboardBottomNavBar({
    super.key,
    required this.isDark,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final bool isDark;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  static const List<_DashboardNavItemData> _items = [
    _DashboardNavItemData(
      icon: Iconsax.home_2_outline,
      label: 'Home',
    ),
    _DashboardNavItemData(
      icon: Icons.local_gas_station_outlined,
      label: 'Stations',
    ),
    _DashboardNavItemData(
      icon: Iconsax.setting_2_outline,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : AppTheme.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                return Expanded(
                  child: _DashboardNavItem(
                    data: item,
                    isDark: isDark,
                    isSelected: selectedIndex == index,
                    onTap: () => onItemSelected(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardNavItem extends StatelessWidget {
  const _DashboardNavItem({
    required this.data,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  final _DashboardNavItemData data;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              data.icon,
              size: 22,
              color: isSelected
                  ? AppTheme.primaryBlue
                  : isDark
                      ? AppTheme.grey400
                      : AppTheme.grey600,
            ),
            const SizedBox(width: 8),
            Text(
              data.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryBlue
                    : isDark
                        ? AppTheme.grey300
                        : AppTheme.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardNavItemData {
  const _DashboardNavItemData({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

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

  String _selectedPeriod = 'This Week'; // Default period
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
    // Fetch sales data when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesBloc>().add(LoadSales());
    });
  }

  Future<void> _loadUserData() async {
    final username = sharedPreferences.getString(ApiConstants.usernameKey);
    final firstName = sharedPreferences.getString(ApiConstants.userFirstNameKey);
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

    final result =
        await getDevicesForCurrentCompanyUseCase(const NoParams());
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
    if (_firstName != null && _firstName!.isNotEmpty &&
        _lastName != null && _lastName!.isNotEmpty) {
      final firstInitial = _firstName![0].toUpperCase();
      final lastInitial = _lastName![0].toUpperCase();
      return '$firstInitial$lastInitial';
    }
    // Fallback to username first letter if names not available
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

    return SafeArea(
      child: BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          final slivers = <Widget>[
            DashboardHomeAppBar(
              theme: theme,
              isDark: isDark,
              displayName: _username ?? widget.username,
              initials: _getUserInitials(),
              onMenuPressed: () => Scaffold.of(context).openDrawer(),
              onProfilePressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(username: widget.username),
                  ),
                );
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
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
            final chartData =
                _getChartDataByPeriod(filteredSales, _selectedPeriod);
            final total = chartData.values.fold<double>(
              0.0,
              (sum, value) => sum + value,
            );
            final average =
                chartData.isNotEmpty ? total / chartData.length : 0.0;
            final chartLabels =
                _getChartLabels(_selectedPeriod, chartData.length);

            slivers
              ..add(
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                  sliver: SliverToBoxAdapter(
                    child: SizedBox.shrink(),
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
    );
  }

  // Calculate sales analytics
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
        // Parse sale date (assuming format like "2025-01-15T10:30:00" or similar)
        final saleDate = _parseSaleDate(sale.slDt);
        if (saleDate == null) continue;

        // Count unique stations based on subSpRefNum
        if (sale.subSpRefNum.isNotEmpty) {
          stations.add(sale.subSpRefNum);
        }

        // Calculate totals
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
        // Skip invalid dates
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

  // Parse sale date string
  DateTime? _parseSaleDate(String dateStr) {
    try {
      // Try ISO format first
      if (dateStr.contains('T')) {
        return DateTime.parse(dateStr.split('T')[0]);
      }
      // Try simple date format
      return DateTime.parse(dateStr.split(' ')[0]);
    } catch (e) {
      return null;
    }
  }

  // Get chart data based on selected period
  Map<int, double> _getChartDataByPeriod(List<SaleEntity> sales, String period) {
    final now = DateTime.now();
    final Map<int, double> periodData = {};

    if (period == 'Today') {
      // Last 24 hours (grouped by hour)
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
            periodData[hourIndex] = (periodData[hourIndex] ?? 0.0) + sale.billAmt;
          }
        } catch (e) {
          continue;
        }
      }
    } else if (period == 'This Week') {
      // Last 7 days
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
      // Last 30 days
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
      // Last 6 months
      for (int i = 0; i < 6; i++) {
        periodData[i] = 0.0;
      }
      for (var sale in sales) {
        try {
          final saleDate = _parseSaleDate(sale.slDt);
          if (saleDate == null) continue;
          final monthsDiff = (now.year - saleDate.year) * 12 + (now.month - saleDate.month);
          if (monthsDiff >= 0 && monthsDiff < 6) {
            final monthIndex = 5 - monthsDiff;
            periodData[monthIndex] = (periodData[monthIndex] ?? 0.0) + sale.billAmt;
          }
        } catch (e) {
          continue;
        }
      }
    } else if (period == 'This Year') {
      // Current year months (Jan to current month)
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
              periodData[monthIndex] = (periodData[monthIndex] ?? 0.0) + sale.billAmt;
            }
          }
        } catch (e) {
          continue;
        }
      }
    } else if (period == '6 Years') {
      // Last 6 years
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
            periodData[yearIndex] = (periodData[yearIndex] ?? 0.0) + sale.billAmt;
          }
        } catch (e) {
          continue;
        }
      }
    }

    return periodData;
  }

  // Get chart labels based on period
  List<String> _getChartLabels(String period, int dataLength) {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    if (period == 'Today') {
      // Hours: Show every 3 hours for cleaner display
      return List.generate(dataLength, (i) {
        // Only show labels for every 3 hours
        if (i % 3 == 0) {
          return '$i:00';
        }
        return '';
      });
    } else if (period == 'This Week') {
      // Days of week
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      final todayIndex = now.weekday % 7;
      return List.generate(dataLength, (i) {
        final dayIndex = (todayIndex - (6 - i)) % 7;
        final adjustedIndex = dayIndex < 0 ? dayIndex + 7 : dayIndex;
        return days[adjustedIndex];
      });
    } else if (period == 'This Month') {
      // Show day numbers: D1, D5, D10, D15, D20, D25, D30
      return List.generate(dataLength, (i) {
        if ((i + 1) % 5 == 0 || i == 0 || i == 29) {
          return 'D${i + 1}';
        }
        return '';
      });
    } else if (period == '6 Months') {
      // Show last 6 months
      return List.generate(dataLength, (i) {
        final month = now.month - (5 - i);
        final adjustedMonth = month <= 0 ? month + 12 : month;
        return months[adjustedMonth - 1];
      });
    } else if (period == 'This Year') {
      // Show months from January to current month
      return List.generate(dataLength, (i) {
        return months[i];
      });
    } else if (period == '6 Years') {
      // Show last 6 years: 2020, 2021, ..., 2025
      return List.generate(dataLength, (i) {
        final year = now.year - (5 - i);
        return year.toString();
      });
    }
    return [];
  }

  // Build chart spots from period data
  List<FlSpot> _buildChartSpots(Map<int, double> periodData) {
    final spots = <FlSpot>[];
    final length = periodData.length;
    for (int i = 0; i < length; i++) {
      spots.add(FlSpot(i.toDouble(), periodData[i] ?? 0.0));
    }
    return spots;
  }

  // Get max value for chart scaling
  double _getMaxChartValue(Map<int, double> data) {
    if (data.isEmpty) return 10000.0;
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    return maxValue > 0 ? maxValue : 10000.0;
  }

  // Format currency
  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${amount.toStringAsFixed(0)}';
    }
  }

  // Format currency compact for chart
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
    return SliverAppBar(
      backgroundColor: isDark ? AppTheme.grey900 : AppTheme.grey100,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      floating: true,
      pinned: false,
      snap: true,
      toolbarHeight: 72,
      leadingWidth: 56,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Icons.menu,
            color: isDark ? AppTheme.white : AppTheme.black,
          ),
          onPressed: onMenuPressed,
        ),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.grey400 : AppTheme.grey600,
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
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: onProfilePressed,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DashboardCompanyCard extends StatelessWidget {
  const DashboardCompanyCard({
    super.key,
    required this.theme,
    required this.isDark,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedGroup,
    required this.deviceGroups,
    required this.onGroupSelected,
  });

  final ThemeData theme;
  final bool isDark;
  final bool isLoading;
  final String? errorMessage;
  final DeviceGroupEntity? selectedGroup;
  final List<DeviceGroupEntity> deviceGroups;
  final ValueChanged<DeviceGroupEntity> onGroupSelected;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _DashboardStatusCard(
        theme: theme,
        isDark: isDark,
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: 'Loading company info...',
      );
    }

    if (errorMessage != null) {
      return _DashboardStatusCard(
        theme: theme,
        isDark: isDark,
        title: 'Company information unavailable',
        subtitle: errorMessage ?? 'Unable to load data. Please try again later.',
      );
    }

    if (selectedGroup == null) {
      return _DashboardStatusCard(
        theme: theme,
        isDark: isDark,
        title: 'No company data found',
        subtitle: 'Make sure your account is linked to a company.',
      );
    }

    final group = selectedGroup!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.grey800 : AppTheme.white,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.spName.isNotEmpty ? group.spName : 'Company',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.white : AppTheme.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (deviceGroups.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: PopupMenuButton<DeviceGroupEntity>(
                              onSelected: onGroupSelected,
                              itemBuilder: (context) {
                                return deviceGroups.map((group) {
                                  return PopupMenuItem<DeviceGroupEntity>(
                                    value: group,
                                    child: Text(
                                      group.spName.isNotEmpty
                                          ? group.spName
                                          : group.spRefNum,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  );
                                }).toList();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.grey700
                                      : AppTheme.grey100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      group.spName.isNotEmpty
                                          ? group.spName
                                          : group.spRefNum,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppTheme.white
                                            : AppTheme.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: isDark
                                          ? AppTheme.white
                                          : AppTheme.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _DashboardInfoRow(
                      theme: theme,
                      isDark: isDark,
                      icon: Icons.local_gas_station_outlined,
                      label: 'Reference',
                      value: group.spRefNum,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
            color: isDark ? AppTheme.grey800 : AppTheme.white,
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
        color: isDark ? AppTheme.grey800 : AppTheme.white,
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
                child: _DashboardSalesStat(
                  title: 'Total Sales ($selectedPeriod)',
                  value: totalLabel,
                  theme: theme,
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _DashboardSalesStat(
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

class _DashboardSalesStat extends StatelessWidget {
  const _DashboardSalesStat({
    required this.title,
    required this.value,
    required this.theme,
    required this.isDark,
  });

  final String title;
  final String value;
  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.white : AppTheme.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppTheme.grey400 : AppTheme.grey600,
          ),
        ),
      ],
    );
  }
}

class _DashboardStatusCard extends StatelessWidget {
  const _DashboardStatusCard({
    required this.theme,
    required this.isDark,
    required this.title,
    this.subtitle,
    this.leading,
  });

  final ThemeData theme;
  final bool isDark;
  final String title;
  final String? subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.grey800 : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.white : AppTheme.black,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppTheme.grey300 : AppTheme.grey600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardInfoRow extends StatelessWidget {
  const _DashboardInfoRow({
    required this.theme,
    required this.isDark,
    required this.icon,
    required this.label,
    required this.value,
  });

  final ThemeData theme;
  final bool isDark;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppTheme.grey300 : AppTheme.grey500,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppTheme.grey300 : AppTheme.grey600,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
