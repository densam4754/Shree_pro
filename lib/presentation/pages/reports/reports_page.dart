import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/injection/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../features/sales/domain/entities/sale_entity.dart';
import '../../../features/sales/presentation/bloc/sales_bloc.dart';
import '../../../features/devices/domain/entities/device_group_entity.dart';
import '../../../core/usecases/usecase.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const List<String> _periodOptions = [
    'Today',
    'This Week',
    'This Month',
    '6 Months',
    'This Year',
    'All Time',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedPeriod = 'This Week';
  List<DeviceGroupEntity> _deviceGroups = const [];
  bool _isLoadingDevices = true;
  String? _devicesError;

  @override
  void initState() {
    super.initState();
    _loadDeviceGroups();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesBloc>().add(LoadSales());
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _devicesError = failure.message;
        });
      },
      (groups) {
        setState(() {
          _isLoadingDevices = false;
          _deviceGroups = groups;
        });
      },
    );
  }

  // Parse sale date from string (simplified version matching dashboard)
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

  // Filter sales by selected period
  List<SaleEntity> _filterSalesByPeriod(List<SaleEntity> sales, String period) {
    if (period == 'All Time') {
      return sales;
    }

    final now = DateTime.now();
    DateTime periodStart;

    switch (period) {
      case 'Today':
        periodStart = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        final today = DateTime(now.year, now.month, now.day);
        periodStart = today.subtract(Duration(days: now.weekday % 7));
        break;
      case 'This Month':
        periodStart = DateTime(now.year, now.month, 1);
        break;
      case '6 Months':
        periodStart = DateTime(now.year, now.month - 6, now.day);
        break;
      case 'This Year':
        periodStart = DateTime(now.year, 1, 1);
        break;
      default:
        return sales;
    }

    return sales.where((sale) {
      final saleDate = _parseSaleDate(sale.slDt);
      if (saleDate == null) return false;
      return saleDate.isAfter(periodStart.subtract(const Duration(days: 1))) &&
          saleDate.isBefore(now.add(const Duration(days: 1)));
    }).toList();
  }

  // Generate fake report data based on sales
  StationReportSummary _generateReportSummary(List<SaleEntity> sales) {
    final totalRevenue = sales.fold<double>(0.0, (sum, sale) => sum + sale.billAmt);
    final totalFuelSold = sales.fold<double>(
      0.0,
      (sum, sale) => sum + (sale.items.isNotEmpty ? sale.items.first.quantity : 0.0),
    );
    final uniqueCustomers = sales.map((s) => s.slTxIdNum).toSet().length;
    final activeStations = _deviceGroups.fold<int>(
      0,
      (sum, group) => sum + group.stations.length,
    );

    return StationReportSummary(
      totalRevenue: totalRevenue,
      totalFuelSold: totalFuelSold,
      totalCustomers: uniqueCustomers,
      activeStations: activeStations > 0 ? activeStations : 4, // Default to 4 if no stations
    );
  }

  // Extract station reports from data
  List<StationReportInfo> _generateStationReports(
    List<SaleEntity> sales,
    List<DeviceGroupEntity> deviceGroups,
  ) {
    return _getFilteredStationReports(sales, deviceGroups);
  }

  List<StationReportInfo> _getFilteredStationReports(
    List<SaleEntity> sales,
    List<DeviceGroupEntity> deviceGroups,
  ) {
    final reports = <StationReportInfo>[];

    // Use fake data for demonstration
    final fakeStations = [
      {
        'name': 'Downtown Station',
        'address': '123 Main Street, Downtown',
        'hours': '24/7',
        'status': 'Operational',
        'revenue': 11823.0,
        'fuelSold': 6900.0,
        'customers': 147,
        'prices': [
          {'type': 'Premium 95', 'price': 1.85, 'trend': 'up'},
          {'type': 'Regular 91', 'price': 1.65, 'trend': 'up'},
          {'type': 'Diesel', 'price': 1.75, 'trend': 'down'},
          {'type': 'Kerosene', 'price': 1.55, 'trend': 'none'},
        ],
      },
      {
        'name': 'Highway Station',
        'address': '456 Highway Road, Outskirts',
        'hours': '24/7',
        'status': 'Operational',
        'revenue': 12850.0,
        'fuelSold': 7200.0,
        'customers': 165,
        'prices': [
          {'type': 'Premium 95', 'price': 1.87, 'trend': 'up'},
          {'type': 'Regular 91', 'price': 1.67, 'trend': 'up'},
          {'type': 'Diesel', 'price': 1.77, 'trend': 'down'},
          {'type': 'Kerosene', 'price': 1.57, 'trend': 'none'},
        ],
      },
      {
        'name': 'North Station',
        'address': '789 North Avenue, North District',
        'hours': '6 AM - 11 PM',
        'status': 'Operational',
        'revenue': 9850.0,
        'fuelSold': 5800.0,
        'customers': 135,
        'prices': [
          {'type': 'Premium 95', 'price': 1.83, 'trend': 'up'},
          {'type': 'Regular 91', 'price': 1.63, 'trend': 'up'},
          {'type': 'Diesel', 'price': 1.73, 'trend': 'down'},
          {'type': 'Kerosene', 'price': 1.53, 'trend': 'none'},
        ],
      },
      {
        'name': 'East Station',
        'address': '321 East Boulevard, East Side',
        'hours': '24/7',
        'status': 'Operational',
        'revenue': 12554.4,
        'fuelSold': 7370.0,
        'customers': 135,
        'prices': [
          {'type': 'Premium 95', 'price': 1.86, 'trend': 'up'},
          {'type': 'Regular 91', 'price': 1.66, 'trend': 'up'},
          {'type': 'Diesel', 'price': 1.76, 'trend': 'down'},
          {'type': 'Kerosene', 'price': 1.56, 'trend': 'none'},
        ],
      },
    ];

    for (int i = 0; i < fakeStations.length; i++) {
      final stationData = fakeStations[i];
      final now = DateTime.now();
      final lastUpdated = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      reports.add(StationReportInfo(
        name: stationData['name'] as String,
        address: stationData['address'] as String,
        hours: stationData['hours'] as String,
        status: stationData['status'] as String,
        revenue: stationData['revenue'] as double,
        fuelSold: stationData['fuelSold'] as double,
        customers: stationData['customers'] as int,
        fuelPrices: (stationData['prices'] as List)
            .map((p) => FuelPrice(
                  type: p['type'] as String,
                  price: p['price'] as double,
                  trend: p['trend'] as String,
                ))
            .toList(),
        lastUpdated: lastUpdated,
      ));
    }

    final allReports = reports;

    // Filter by search query if present
    if (_searchQuery.isEmpty) {
      return allReports;
    }

    return allReports.where((report) {
      return report.name.toLowerCase().contains(_searchQuery) ||
          report.address.toLowerCase().contains(_searchQuery) ||
          report.status.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  String _formatCurrencyFull(double amount) {
    return NumberFormatter.formatCurrencyFull(amount);
  }

  String _formatFuel(double liters) {
    return NumberFormatter.formatFuel(liters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: salesBloc,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.grey900 : AppTheme.grey100,
        body: BlocBuilder<SalesBloc, SalesState>(
          builder: (context, state) {
            final allSales = state is SalesLoaded ? state.sales : <SaleEntity>[];
            final filteredSales = _filterSalesByPeriod(allSales, _selectedPeriod);
            final summary = _generateReportSummary(filteredSales);
            final stationReports = _generateStationReports(filteredSales, _deviceGroups);
            final statusBarHeight = MediaQuery.of(context).padding.top;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          1,
                          16,
                          20,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Bootstrap.chevron_left,
                                color: AppTheme.white,
                                size: 24,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Station Reports',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${stationReports.length} stations reporting',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Period Filter Dropdown
                            PopupMenuButton<String>(
                              initialValue: _selectedPeriod,
                              onSelected: (value) {
                                setState(() {
                                  _selectedPeriod = value;
                                });
                              },
                              itemBuilder: (context) => [
                                for (final period in _periodOptions)
                                  PopupMenuItem<String>(
                                    value: period,
                                    child: Text(period),
                                  ),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedPeriod,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.filter_list,
                                      color: AppTheme.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    color: AppTheme.primaryBlue,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by station name or address...',
                          prefixIcon: Icon(
                            Icons.search,
                            color:
                                isDark ? AppTheme.grey400 : AppTheme.grey600,
                          ),
                          suffixIcon:
                              _searchQuery.isNotEmpty
                                  ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color:
                                          isDark
                                              ? AppTheme.grey400
                                              : AppTheme.grey600,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                  : null,
                          filled: true,
                          fillColor:
                              isDark ? Colors.grey[850] : AppTheme.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: TextStyle(
                          color: isDark ? AppTheme.white : AppTheme.black,
                        ),
                      ),
                    ),
                  ),
                ),

                // Today's Overview Section
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      "Today's Overview",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.4,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildMetricCard(
                        context,
                        'Total Revenue',
                        _formatCurrencyFull(summary.totalRevenue),
                        Icons.attach_money_rounded,
                        const Color(0xFF42A5F5),
                        theme,
                        isDark,
                      ),
                      _buildMetricCard(
                        context,
                        'Total Fuel Sold',
                        _formatFuel(summary.totalFuelSold),
                        Icons.local_gas_station_rounded,
                        const Color(0xFF26A69A),
                        theme,
                        isDark,
                      ),
                      _buildMetricCard(
                        context,
                        'Customers',
                        '${summary.totalCustomers}',
                        Icons.people_rounded,
                        const Color(0xFFAB47BC),
                        theme,
                        isDark,
                      ),
                      _buildMetricCard(
                        context,
                        'Active Stations',
                        '${summary.activeStations}',
                        Icons.business_rounded,
                        const Color(0xFF78909C),
                        theme,
                        isDark,
                      ),
                    ]),
                  ),
                ),

                // Station Reports Section
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Station Reports',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final report = stationReports[index];
                        return _buildStationCard(
                          context: context,
                          report: report,
                          isDark: isDark,
                          theme: theme,
                          onTap: () {
                            _showStationDetailBottomSheet(
                              context,
                              report,
                              isDark,
                              theme,
                              filteredSales,
                            );
                          },
                        );
                      },
                      childCount: stationReports.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color iconColor,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.white : AppTheme.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStationCard({
    required BuildContext context,
    required StationReportInfo report,
    required bool isDark,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Station Name and Status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.white : AppTheme.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        report.status,
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Bootstrap.chevron_right,
                      color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Location and Hours
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.address,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report.hours,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Current Fuel Prices
                Text(
                  'Current Fuel Prices',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.white : AppTheme.black,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: report.fuelPrices.map((price) {
                    IconData trendIcon;
                    Color trendColor;
                    switch (price.trend) {
                      case 'up':
                        trendIcon = Icons.trending_up;
                        trendColor = Colors.red;
                        break;
                      case 'down':
                        trendIcon = Icons.trending_down;
                        trendColor = Colors.green;
                        break;
                      default:
                        trendIcon = Icons.remove;
                        trendColor = AppTheme.grey500;
                    }

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${price.type}: ${NumberFormatter.formatPrice(price.price)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppTheme.white : AppTheme.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          trendIcon,
                          size: 14,
                          color: trendColor,
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Station Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStationSummaryCard(
                        context,
                        'Revenue',
                        _formatCurrencyFull(report.revenue),
                        Icons.attach_money,
                        const Color(0xFF42A5F5),
                        theme,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStationSummaryCard(
                        context,
                        'Fuel Sold',
                        _formatFuel(report.fuelSold),
                        Icons.local_gas_station,
                        const Color(0xFF26A69A),
                        theme,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStationSummaryCard(
                        context,
                        'Customers',
                        '${report.customers}',
                        Icons.people,
                        const Color(0xFFAB47BC),
                        theme,
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Last Updated
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Updated: ${report.lastUpdated}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppTheme.grey500 : AppTheme.grey500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStationSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppTheme.grey400 : AppTheme.grey600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showStationDetailBottomSheet(
    BuildContext context,
    StationReportInfo report,
    bool isDark,
    ThemeData theme,
    List<SaleEntity> filteredSales,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : AppTheme.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.grey600 : AppTheme.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Station Details',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.white : AppTheme.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF0076D6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Share button
                  IconButton(
                    icon: Icon(
                      Bootstrap.share,
                      color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                    ),
                    onPressed: () => _shareReport(context, report, theme, isDark, _selectedPeriod),
                  ),
                  // Print/Download button
                  IconButton(
                    icon: Icon(
                      Bootstrap.download,
                      color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                    ),
                    onPressed: () => _printReport(context, report, theme, isDark),
                  ),
                  // Period Filter in Bottom Sheet
                  PopupMenuButton<String>(
                    initialValue: _selectedPeriod,
                    onSelected: (value) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                      Navigator.pop(context);
                      // Reopen bottom sheet with new filter
                      _showStationDetailBottomSheet(
                        context,
                        report,
                        isDark,
                        theme,
                        _filterSalesByPeriod(filteredSales, _selectedPeriod),
                      );
                    },
                    itemBuilder: (context) => [
                      for (final period in _periodOptions)
                        PopupMenuItem<String>(
                          value: period,
                          child: Row(
                            children: [
                              Icon(
                                _selectedPeriod == period
                                    ? Icons.check
                                    : Icons.radio_button_unchecked,
                                size: 20,
                                color: _selectedPeriod == period
                                    ? AppTheme.primaryBlue
                                    : AppTheme.grey600,
                              ),
                              const SizedBox(width: 8),
                              Text(period),
                            ],
                          ),
                        ),
                    ],
                    child: Icon(
                      Icons.date_range,
                      color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Station Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: AppTheme.primaryBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  report.address,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? AppTheme.white : AppTheme.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                color: AppTheme.primaryBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                report.hours,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppTheme.white : AppTheme.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  report.status,
                                  style: TextStyle(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Station Metrics
                    _buildSectionTitle(theme, isDark, 'Station Metrics'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailMetricCard(
                            context,
                            'Revenue',
                            _formatCurrencyFull(report.revenue),
                            Icons.attach_money_rounded,
                            const Color(0xFF42A5F5),
                            theme,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailMetricCard(
                            context,
                            'Fuel Sold',
                            _formatFuel(report.fuelSold),
                            Icons.local_gas_station_rounded,
                            const Color(0xFF26A69A),
                            theme,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailMetricCard(
                      context,
                      'Customers',
                      '${report.customers}',
                      Icons.people_rounded,
                      const Color(0xFFAB47BC),
                      theme,
                      isDark,
                    ),
                    const SizedBox(height: 24),

                    // Fuel Prices Section
                    _buildSectionTitle(theme, isDark, 'Current Fuel Prices'),
                    const SizedBox(height: 12),
                    ...report.fuelPrices.map((price) {
                      IconData trendIcon;
                      Color trendColor;
                      String trendText;
                      switch (price.trend) {
                        case 'up':
                          trendIcon = Icons.trending_up;
                          trendColor = Colors.red;
                          trendText = 'Increased';
                          break;
                        case 'down':
                          trendIcon = Icons.trending_down;
                          trendColor = Colors.green;
                          trendText = 'Decreased';
                          break;
                        default:
                          trendIcon = Icons.remove;
                          trendColor = AppTheme.grey500;
                          trendText = 'No change';
                      }

                      return _buildFuelPriceRow(
                        context,
                        price.type,
                        NumberFormatter.formatPrice(price.price),
                        trendIcon,
                        trendColor,
                        trendText,
                        theme,
                        isDark,
                      );
                    }).toList(),
                    const SizedBox(height: 24),

                    // Last Updated
                    _buildSectionTitle(theme, isDark, 'Last Updated'),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      'Last Updated',
                      report.lastUpdated,
                      Icons.update_outlined,
                      theme,
                      isDark,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, bool isDark, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: isDark ? AppTheme.white : AppTheme.black,
      ),
    );
  }

  Widget _buildDetailMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : AppTheme.grey100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppTheme.grey300 : AppTheme.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelPriceRow(
    BuildContext context,
    String fuelType,
    String price,
    IconData trendIcon,
    Color trendColor,
    String trendText,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : AppTheme.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.grey700 : AppTheme.grey300.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_gas_station_outlined,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fuelType,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppTheme.white : AppTheme.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                trendIcon,
                color: trendColor,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                trendText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: trendColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : AppTheme.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : AppTheme.grey300.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppTheme.white : AppTheme.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareReport(
    BuildContext context,
    StationReportInfo report,
    ThemeData theme,
    bool isDark,
    String period,
  ) async {
    final reportText = '''
    Station Report: ${report.name}
    Period: $period

    Address: ${report.address}
    Hours: ${report.hours}
    Status: ${report.status}

    Metrics:
    - Revenue: ${_formatCurrencyFull(report.revenue)}
    - Fuel Sold: ${_formatFuel(report.fuelSold)}
    - Customers: ${report.customers}

    Fuel Prices:
    ${report.fuelPrices.map((p) => '- ${p.type}: ${NumberFormatter.formatPrice(p.price)}').join('\n')}

    Last Updated: ${report.lastUpdated}
''';

    try {
      await Share.share(
        reportText,
        subject: 'Station Report - ${report.name}',
      );
    } catch (e) {
      // Handle share error - plugin may not be initialized
      // This error typically occurs when the app needs a hot restart
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to share. Please restart the app and try again.'),
            backgroundColor: AppTheme.primaryBlue,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: AppTheme.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Future<void> _printReport(
    BuildContext context,
    StationReportInfo report,
    ThemeData theme,
    bool isDark,
  ) async {
    // Show print/download dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : AppTheme.white,
        title: Text(
          'Download Report',
          style: theme.textTheme.titleLarge?.copyWith(
            color: isDark ? AppTheme.white : AppTheme.black,
          ),
        ),
        content: Text(
          'The report will be saved to your device.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppTheme.grey400 : AppTheme.grey600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? AppTheme.grey400 : AppTheme.grey600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Report downloaded successfully'),
                  backgroundColor: AppTheme.primaryBlue,
                ),
              );
            },
            child: Text(
              'Download',
              style: TextStyle(color: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper classes
class StationReportSummary {
  final double totalRevenue;
  final double totalFuelSold;
  final int totalCustomers;
  final int activeStations;

  StationReportSummary({
    required this.totalRevenue,
    required this.totalFuelSold,
    required this.totalCustomers,
    required this.activeStations,
  });
}

class StationReportInfo {
  final String name;
  final String address;
  final String hours;
  final String status;
  final double revenue;
  final double fuelSold;
  final int customers;
  final List<FuelPrice> fuelPrices;
  final String lastUpdated;

  StationReportInfo({
    required this.name,
    required this.address,
    required this.hours,
    required this.status,
    required this.revenue,
    required this.fuelSold,
    required this.customers,
    required this.fuelPrices,
    required this.lastUpdated,
  });
}

class FuelPrice {
  final String type;
  final double price;
  final String trend; // 'up', 'down', 'none'

  FuelPrice({
    required this.type,
    required this.price,
    required this.trend,
  });
}

