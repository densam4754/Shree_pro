import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/injection/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/sales/domain/entities/sale_entity.dart';
import '../../../features/sales/presentation/bloc/sales_bloc.dart';
import 'station_details_page.dart';
import '../../../features/devices/domain/entities/device_group_entity.dart';
import '../../../core/usecases/usecase.dart';

class StationsListPage extends StatefulWidget {
  const StationsListPage({super.key});

  @override
  State<StationsListPage> createState() => _StationsListPageState();
}

class _StationsListPageState extends State<StationsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<DeviceGroupEntity> _deviceGroups = const [];
  bool _isLoadingDevices = true;
  String? _devicesError;

  @override
  void initState() {
    super.initState();
    _loadDeviceGroups();
    // Fetch sales data when page loads
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

    final result =
        await getDevicesForCurrentCompanyUseCase(const NoParams());

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _deviceGroups = const [];
          _devicesError = failure.message;
          _isLoadingDevices = false;
        });
      },
      (groups) {
        setState(() {
          _deviceGroups = groups;
          _isLoadingDevices = false;
        });
      },
    );
  }

  // Extract unique stations from sales data
  Map<String, StationInfo> _extractStations(List<SaleEntity> sales) {
    final Map<String, StationInfo> stations = {};
    final allowedStations = _deviceGroups
        .expand((group) => group.stations)
        .map((station) => station.subSpRefNum)
        .toSet();

    // Seed stations from device list so they appear even without sales
    for (final group in _deviceGroups) {
      for (final station in group.stations) {
        stations.putIfAbsent(
          station.subSpRefNum,
          () => StationInfo(
            id: station.subSpRefNum,
            name: _resolveStationName(station.subSpRefNum),
            totalSales: 0.0,
            totalTransactions: 0,
          ),
        );
      }
    }

    for (var sale in sales) {
      final stationRef = sale.subSpRefNum.isNotEmpty
          ? sale.subSpRefNum
          : sale.slTxIdNum;
      if (stationRef.isEmpty) continue;
      if (allowedStations.isNotEmpty && !allowedStations.contains(sale.subSpRefNum)) {
        continue;
      }

      stations.putIfAbsent(
        stationRef,
        () => StationInfo(
          id: stationRef,
          name: _resolveStationName(stationRef),
          totalSales: 0.0,
          totalTransactions: 0,
        ),
      );

      final station = stations[stationRef]!;
      station.totalSales += sale.billAmt;
      station.totalTransactions += 1;
    }

    return stations;
  }

  String _resolveStationName(String subSpRefNum) {
    for (final group in _deviceGroups) {
      for (final station in group.stations) {
        if (station.subSpRefNum == subSpRefNum) {
          return group.spName.isNotEmpty
              ? '${group.spName} · $subSpRefNum'
              : subSpRefNum;
        }
      }
    }
    return 'Station $subSpRefNum';
  }

  List<StationInfo> _getFilteredStations(Map<String, StationInfo> stations) {
    if (_searchQuery.isEmpty) {
      return stations.values.toList()
        ..sort((a, b) => b.totalSales.compareTo(a.totalSales));
    }

    return stations.values
        .where((station) =>
            station.id.toLowerCase().contains(_searchQuery) ||
            station.name.toLowerCase().contains(_searchQuery))
        .toList()
      ..sort((a, b) => b.totalSales.compareTo(a.totalSales));
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
                  backgroundColor: isDark ? AppTheme.grey900 : AppTheme.white,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  pinned: false,
                  floating: true,
                  snap: true,
                  automaticallyImplyLeading: false,
                  title: Text(
                    'Stations',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.white : AppTheme.black,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
                    color: isDark ? AppTheme.grey900 : AppTheme.white,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search stations...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: isDark
                                      ? AppTheme.grey400
                                      : AppTheme.grey600,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? AppTheme.grey800 : AppTheme.grey100,
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
              ];

              if (_isLoadingDevices) {
                slivers.add(
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              } else if (_devicesError != null) {
                slivers.add(
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 48,
                            color: isDark ? AppTheme.grey500 : AppTheme.grey400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Unable to load station information.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color:
                                  isDark ? AppTheme.grey300 : AppTheme.grey600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _devicesError!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppTheme.grey500 : AppTheme.grey500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (state is SalesLoading || state is SalesInitial || state is SalesRefreshing) {
                slivers.add(
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              } else {
                final sales = state is SalesLoaded ? state.sales : <SaleEntity>[];
                final stations = _extractStations(sales);
                final filteredStations = _getFilteredStations(stations);

                if (filteredStations.isEmpty) {
                  slivers.add(
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_gas_station_outlined,
                            size: 64,
                            color: isDark ? AppTheme.grey600 : AppTheme.grey400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No stations found'
                                : 'No stations match your search',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color:
                                  isDark ? AppTheme.grey400 : AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  slivers.add(
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final station = filteredStations[index];
                            return _buildStationCard(
                              context: context,
                              station: station,
                              isDark: isDark,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StationDetailsPage(
                                      stationId: station.id,
                                      stationName: station.name,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: filteredStations.length,
                        ),
                      ),
                    ),
                  );
                }
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

  Widget _buildStationCard({
    required BuildContext context,
    required StationInfo station,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.grey800 : AppTheme.white,
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Station Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_gas_station,
                    color: AppTheme.primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Station Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.white : AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${station.id}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 14,
                            color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${station.totalTransactions} transactions',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Sales Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(station.totalSales),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Sales',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 8),

                // Arrow Icon
                Icon(
                  Icons.chevron_right,
                  color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}

class StationInfo {
  final String id;
  final String name;
  double totalSales;
  int totalTransactions;

  StationInfo({
    required this.id,
    required this.name,
    required this.totalSales,
    required this.totalTransactions,
  });
}

