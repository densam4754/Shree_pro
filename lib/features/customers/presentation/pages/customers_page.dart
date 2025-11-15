import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../../core/injection/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../features/sales/domain/entities/sale_entity.dart';
import '../../../../features/sales/presentation/bloc/sales_bloc.dart';
import '../../domain/entities/customer_entity.dart';
import '../../../../features/devices/domain/entities/device_group_entity.dart';
import '../../../../core/usecases/usecase.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage>
    with SingleTickerProviderStateMixin {
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
  List<CustomerEntity> _customers = [];
  List<DeviceGroupEntity> _deviceGroups = const [];
  bool _isLoadingCustomers = true;
  bool _isLoadingDevices = true;
  String? _customersError;
  String? _devicesError;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadDeviceGroups();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  // Load sales after the BlocProvider is available in the widget tree
  void _loadSales(BuildContext context) {
    try {
      final bloc = context.read<SalesBloc>();
      bloc.add(LoadSales());
    } catch (e) {
      // SalesBloc not available yet - will be handled when widget rebuilds
      debugPrint('SalesBloc not available yet: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoadingCustomers = true;
      _customersError = null;
    });

    final result = await getAllCustomersUseCase();

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _customers = [];
          _customersError = failure.message;
          _isLoadingCustomers = false;
        });
      },
      (customers) {
        setState(() {
          _customers = customers;
          _isLoadingCustomers = false;
        });
      },
    );
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

  String _resolveStationName(String subSpRefNum) {
    for (final group in _deviceGroups) {
      for (final station in group.stations) {
        if (station.subSpRefNum == subSpRefNum) {
          return group.spName.isNotEmpty ? group.spName : subSpRefNum;
        }
      }
    }
    return subSpRefNum;
  }

  // Parse sale date from string (simplified version matching reports page)
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

  // Extract customer visit information from sales data
  List<CustomerVisitInfo> _extractCustomerVisits(List<SaleEntity> sales) {
    final Map<String, CustomerVisitInfo> customerVisits = {};

    for (final sale in sales) {
      // Try to find customer by reference or use a default grouping
      final customerId =
          sale.slDesc.isNotEmpty
              ? sale.slDesc
              : sale.slTxIdNum; // Use transaction ID as fallback

      if (customerId.isEmpty) continue;

      // Find matching customer entity
      CustomerEntity? customer;
      for (final cust in _customers) {
        if (cust.id == customerId ||
            cust.reference == sale.subSpRefNum ||
            cust.phone.contains(customerId)) {
          customer = cust;
          break;
        }
      }

      // Create or update customer visit info
      if (customer != null) {
        if (!customerVisits.containsKey(customer.id)) {
          customerVisits[customer.id] = CustomerVisitInfo(
            customer: customer,
            visits: [],
            lastVisit: sale.slDt,
            lastVisitAmount: sale.billAmt,
            lastVisitVolume:
                sale.items.isNotEmpty ? sale.items.first.quantity : 0.0,
            lastFuelType:
                sale.items.isNotEmpty ? sale.items.first.name : 'Regular 91',
            lastStationName: _resolveStationName(sale.subSpRefNum),
          );
        }

        final visitInfo = customerVisits[customer.id]!;
        visitInfo.visits.add(sale);
        visitInfo.totalVisits += 1;

        // Update last visit if this sale is more recent
        if (sale.slDt.compareTo(visitInfo.lastVisit) > 0) {
          visitInfo.lastVisit = sale.slDt;
          visitInfo.lastVisitAmount = sale.billAmt;
          visitInfo.lastVisitVolume =
              sale.items.isNotEmpty ? sale.items.first.quantity : 0.0;
          visitInfo.lastFuelType =
              sale.items.isNotEmpty ? sale.items.first.name : 'Regular 91';
          visitInfo.lastStationName = _resolveStationName(sale.subSpRefNum);
        }
      }
    }

    return customerVisits.values.toList()
      ..sort((a, b) => b.totalVisits.compareTo(a.totalVisits));
  }

  // Generate fake customer visit data for demonstration
  List<CustomerVisitInfo> _generateFakeData() {
    final fakeCustomers = [
      CustomerEntity(
        name: 'Jessica Williams',
        id: 'JW001',
        email: 'jessica.williams@email.com',
        phone: '+1 (555) 678-9012',
        address: '123 Main St',
        reference: 'ST001',
        created: '2024-01-15',
        status: '1',
      ),
      CustomerEntity(
        name: 'Robert Anderson',
        id: 'RA002',
        email: 'robert.anderson@email.com',
        phone: '+1 (555) 789-0123',
        address: '456 Oak Ave',
        reference: 'ST001',
        created: '2024-02-20',
        status: '1',
      ),
      CustomerEntity(
        name: 'Lisa Martinez',
        id: 'LM003',
        email: 'lisa.martinez@email.com',
        phone: '+1 (555) 890-1234',
        address: '789 Pine Rd',
        reference: 'ST002',
        created: '2024-03-10',
        status: '1',
      ),
      CustomerEntity(
        name: 'Michael Johnson',
        id: 'MJ004',
        email: 'michael.johnson@email.com',
        phone: '+1 (555) 901-2345',
        address: '321 Elm St',
        reference: 'ST001',
        created: '2024-04-05',
        status: '1',
      ),
      CustomerEntity(
        name: 'Sarah Davis',
        id: 'SD005',
        email: 'sarah.davis@email.com',
        phone: '+1 (555) 012-3456',
        address: '654 Maple Dr',
        reference: 'ST002',
        created: '2024-05-12',
        status: '1',
      ),
      CustomerEntity(
        name: 'David Wilson',
        id: 'DW006',
        email: 'david.wilson@email.com',
        phone: '+1 (555) 123-4567',
        address: '987 Cedar Ln',
        reference: 'ST001',
        created: '2024-06-18',
        status: '1',
      ),
      CustomerEntity(
        name: 'Emily Brown',
        id: 'EB007',
        email: 'emily.brown@email.com',
        phone: '+1 (555) 234-5678',
        address: '147 Birch Way',
        reference: 'ST002',
        created: '2024-07-22',
        status: '1',
      ),
      CustomerEntity(
        name: 'James Taylor',
        id: 'JT008',
        email: 'james.taylor@email.com',
        phone: '+1 (555) 345-6789',
        address: '258 Spruce Ct',
        reference: 'ST001',
        created: '2024-08-30',
        status: '1',
      ),
    ];

    final fakeFuelTypes = ['Regular 91', 'Premium 95', 'Diesel', 'Super 98'];
    final fakeStations = ['North Station', 'Downtown Station', 'Highway Station', 'East Station'];
    final visitCounts = [28, 37, 12, 45, 19, 33, 8, 51];
    final amounts = [66.00, 108.23, 53.63, 89.45, 72.10, 95.30, 44.20, 125.50];
    final volumes = [40.0, 58.5, 32.5, 52.0, 45.0, 61.0, 28.0, 75.0];

    final fakeVisits = <CustomerVisitInfo>[];

    for (int i = 0; i < fakeCustomers.length; i++) {
      final customer = fakeCustomers[i];
      final now = DateTime.now();
      final lastVisitDate = now.subtract(Duration(days: i % 7));
      final formattedDate = '${lastVisitDate.year}-${lastVisitDate.month.toString().padLeft(2, '0')}-${lastVisitDate.day.toString().padLeft(2, '0')}';
      final hour24 = (14 + i % 10);
      final minute = (30 + i * 5) % 60;
      final period = hour24 >= 12 ? 'PM' : 'AM';
      final displayHour = hour24 > 12 ? hour24 - 12 : (hour24 == 0 ? 12 : hour24);
      final dateTime = '$formattedDate $displayHour:${minute.toString().padLeft(2, '0')} $period';

      fakeVisits.add(CustomerVisitInfo(
        customer: customer,
        visits: [],
        totalVisits: visitCounts[i],
        lastVisit: dateTime,
        lastVisitAmount: amounts[i],
        lastVisitVolume: volumes[i],
        lastFuelType: fakeFuelTypes[i % fakeFuelTypes.length],
        lastStationName: fakeStations[i % fakeStations.length],
      ));
    }

    return fakeVisits..sort((a, b) => b.totalVisits.compareTo(a.totalVisits));
  }

  List<CustomerVisitInfo> _getFilteredCustomers(List<SaleEntity> sales) {
    List<CustomerVisitInfo> visits;
    
    // Always use fake data for now - uncomment below to use real data when available
    visits = _generateFakeData();
    
    // Use real data when available (commented out for now)
    // if (_customers.isNotEmpty && sales.isNotEmpty) {
    //   final extractedVisits = _extractCustomerVisits(sales);
    //   if (extractedVisits.isNotEmpty) {
    //     visits = extractedVisits;
    //   } else {
    //     visits = _generateFakeData();
    //   }
    // } else {
    //   visits = _generateFakeData();
    // }

    if (_searchQuery.isEmpty) {
      return visits;
    }

    return visits.where((visit) {
      final customer = visit.customer;
      return customer.name.toLowerCase().contains(_searchQuery) ||
          customer.phone.toLowerCase().contains(_searchQuery) ||
          _searchQuery.contains('vehicle') ||
          _searchQuery.contains('car'); // Simple vehicle search match
    }).toList();
  }

  String _formatDate(String dateStr) {
    try {
      // Assume date format is YYYY-MM-DD HH:mm:ss or similar
      final parts = dateStr.split(' ');
      if (parts.isNotEmpty) {
        return parts[0]; // Return date part
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String dateStr) {
    try {
      final parts = dateStr.split(' ');
      if (parts.length > 1) {
        // Try to format time (assuming HH:mm:ss or HH:mm format)
        final timePart = parts[1];
        final timeParts = timePart.split(':');
        if (timeParts.length >= 2) {
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = timeParts[1];
          final period = hour >= 12 ? 'PM' : 'AM';
          final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return '$displayHour:$minute $period';
        }
        return timePart;
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormatter.formatCurrencyFull(amount);
  }

  String _formatVolume(double volume) {
    return NumberFormatter.formatVolume(volume);
  }

  // Generate vehicle plate (mock for now - would come from actual data)
  String _getVehiclePlate(CustomerEntity customer) {
    // Use customer ID or phone to generate a mock plate
    final id =
        customer.id.isNotEmpty
            ? customer.id
                .substring(0, math.min(3, customer.id.length))
                .toUpperCase()
            : 'ABC';
    final num =
        customer.id.length > 3
            ? customer.id.substring(3, math.min(6, customer.id.length))
            : '1234';
    return '$id-$num';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Provide SalesBloc if not already provided (for cases where page is navigated to directly)
    return BlocProvider.value(
      value: salesBloc,
      child: Builder(
        builder: (context) {
          // Load sales after BlocProvider is in the tree
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _loadSales(context);
            }
          });

          return Scaffold(
            backgroundColor: isDark ? AppTheme.grey900 : AppTheme.grey100,
            body: BlocBuilder<SalesBloc, SalesState>(
              builder: (context, state) {
                final allSales =
                    state is SalesLoaded ? state.sales : <SaleEntity>[];
                final filteredSales = _filterSalesByPeriod(allSales, _selectedPeriod);
                final filteredVisits = _getFilteredCustomers(filteredSales);
                final statusBarHeight = MediaQuery.of(context).padding.top;

                final slivers = <Widget>[
                  // Custom Header - extends to top: 0
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0076D6),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          statusBarHeight + 12,
                          16,
                          20,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Bootstrap.chevron_left,
                                color: AppTheme.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Station Customers',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.white,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${filteredVisits.length} customers found',
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

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      color: const Color(0xFF0076D6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : AppTheme.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by name or vehicle...',
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

                  // Content - Always show fake data (remove loading states for now)
                  if (filteredVisits.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: isDark ? AppTheme.grey600 : AppTheme.grey400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No customers found'
                                : 'No customers match your search',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color:
                                  isDark ? AppTheme.grey400 : AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final visit = filteredVisits[index];
                          return _buildCustomerCard(
                            context: context,
                            visit: visit,
                            isDark: isDark,
                            index: index,
                            filteredSales: filteredSales,
                          );
                        }, childCount: filteredVisits.length),
                      ),
                    ),
                ];

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: slivers,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomerCard({
    required BuildContext context,
    required CustomerVisitInfo visit,
    required bool isDark,
    required int index,
    required List<SaleEntity> filteredSales,
  }) {
    final theme = Theme.of(context);
    final vehiclePlate = _getVehiclePlate(visit.customer);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            onTap: () {
              _showCustomerDetailBottomSheet(
                context,
                visit,
                isDark,
                filteredSales,
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Name, Visits Badge, Arrow
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          visit.customer.name,
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
                          '${visit.totalVisits} visits',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Phone Number
                  Text(
                    visit.customer.phone,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Info Row: Vehicle, Fuel, Station
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      // Vehicle
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_car,
                            size: 16,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vehiclePlate,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppTheme.white : AppTheme.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Fuel Type
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_gas_station,
                            size: 16,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            visit.lastFuelType,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppTheme.white : AppTheme.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Station Location
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            visit.lastStationName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppTheme.white : AppTheme.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Footer Row: Date/Time, Amount, Volume
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_formatDate(visit.lastVisit)} • ${_formatTime(visit.lastVisit)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(visit.lastVisitAmount),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          Text(
                            _formatVolume(visit.lastVisitVolume),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  isDark ? AppTheme.grey400 : AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomerDetailBottomSheet(
    BuildContext context,
    CustomerVisitInfo visit,
    bool isDark,
    List<SaleEntity> filteredSales,
  ) {
    final theme = Theme.of(context);
    final vehiclePlate = _getVehiclePlate(visit.customer);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
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

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Details',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.white : AppTheme.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          visit.customer.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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
                      final newFilteredSales = _filterSalesByPeriod(
                        filteredSales,
                        _selectedPeriod,
                      );
                      _showCustomerDetailBottomSheet(
                        context,
                        visit,
                        isDark,
                        newFilteredSales,
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
                    // Visit Statistics Card
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            'Total Visits',
                            '${visit.totalVisits}',
                            Icons.receipt_long,
                            theme,
                            isDark,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            context,
                            'Last Visit Amount',
                            _formatCurrency(visit.lastVisitAmount),
                            Icons.attach_money,
                            theme,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Personal Information Section
                    _buildSectionTitle(theme, isDark, 'Personal Information'),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      'Full Name',
                      visit.customer.name,
                      Icons.person_outline,
                      theme,
                      isDark,
                    ),
                    _buildInfoRow(
                      context,
                      'Phone Number',
                      visit.customer.phone,
                      Icons.phone_outlined,
                      theme,
                      isDark,
                    ),
                    _buildInfoRow(
                      context,
                      'Email Address',
                      visit.customer.email.isNotEmpty
                          ? visit.customer.email
                          : 'Not provided',
                      Icons.email_outlined,
                      theme,
                      isDark,
                    ),
                    _buildInfoRow(
                      context,
                      'Address',
                      visit.customer.address.isNotEmpty
                          ? visit.customer.address
                          : 'Not provided',
                      Icons.location_on_outlined,
                      theme,
                      isDark,
                    ),
                    _buildInfoRow(
                      context,
                      'Customer ID',
                      visit.customer.id,
                      Icons.badge_outlined,
                      theme,
                      isDark,
                    ),
                    const SizedBox(height: 24),

                    // Last Visit Details Section
                    _buildSectionTitle(theme, isDark, 'Last Visit Details'),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      'Date & Time',
                      '${_formatDate(visit.lastVisit)} • ${_formatTime(visit.lastVisit)}',
                      Icons.calendar_today_outlined,
                      theme,
                      isDark,
                    ),
                    _buildInfoRow(
                      context,
                      'Station',
                      visit.lastStationName,
                      Icons.local_gas_station_outlined,
                      theme,
                      isDark,
                    ),
                    _buildInfoRow(
                      context,
                      'Fuel Type',
                      visit.lastFuelType,
                      Icons.local_fire_department_outlined,
                      theme,
                      isDark,
                    ),
                    _buildInfoRow(
                      context,
                      'Volume',
                      _formatVolume(visit.lastVisitVolume),
                      Icons.water_drop_outlined,
                      theme,
                      isDark,
                    ),
                    _buildInfoRow(
                      context,
                      'Amount Paid',
                      _formatCurrency(visit.lastVisitAmount),
                      Icons.payment_outlined,
                      theme,
                      isDark,
                    ),
                    const SizedBox(height: 24),

                    // Vehicle Information Section
                    _buildSectionTitle(theme, isDark, 'Vehicle Information'),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      'Vehicle Plate',
                      vehiclePlate,
                      Icons.directions_car_outlined,
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

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryBlue,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AppTheme.grey400 : AppTheme.grey600,
          ),
        ),
      ],
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

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
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
          color: isDark
              ? AppTheme.grey700
              : AppTheme.grey300.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
}

// Helper class to aggregate customer and visit information
class CustomerVisitInfo {
  final CustomerEntity customer;
  final List<SaleEntity> visits;
  int totalVisits;
  String lastVisit;
  double lastVisitAmount;
  double lastVisitVolume;
  String lastFuelType;
  String lastStationName;

  CustomerVisitInfo({
    required this.customer,
    required this.visits,
    this.totalVisits = 0,
    required this.lastVisit,
    required this.lastVisitAmount,
    required this.lastVisitVolume,
    required this.lastFuelType,
    required this.lastStationName,
  });
}
