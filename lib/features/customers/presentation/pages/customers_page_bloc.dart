import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/injection/injection_container.dart';
import '../../domain/entities/customer_entity.dart';
import '../widgets/customer_detail_dialog.dart';
import '../bloc/customers_bloc.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({Key? key}) : super(key: key);

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _verticalController = ScrollController();
  AnimationController? _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    context.read<CustomersBloc>().add(const LoadCustomers());
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _refreshController?.dispose();
    super.dispose();
  }

  Widget _buildCard(String label, String value, IconData icon, int pos) {
    return Expanded(
      child: AnimationConfiguration.staggeredList(
        position: pos,
        duration: const Duration(milliseconds: 600),
        child: SlideAnimation(
          verticalOffset: 40,
          child: FadeInAnimation(
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.blue[700], size: 28),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: const [
          Expanded(
            flex: 2,
            child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Text("Phone", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Action",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(CustomerEntity customer, int index) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 450),
      child: SlideAnimation(
        horizontalOffset: 50,
        child: FadeInAnimation(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: index % 2 == 0 ? Colors.white : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(customer.name)),
                Expanded(flex: 2, child: Text(customer.phone)),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blueGrey),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 450),
                            child: SlideAnimation(
                              horizontalOffset: 50,
                              child: FadeInAnimation(
                                child: SizedBox(
                                  height: 600,
                                  width: 500,
                                  child: CustomerDetailDialog(customer: customer),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => customersBloc..add(const LoadCustomers()),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          title: const Text(
            "Customers",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDFEFF), Color(0xFF64B5F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            BlocBuilder<CustomersBloc, CustomersState>(
              builder: (context, state) {
                final isRefreshing = state is CustomersRefreshing;
                if (isRefreshing) {
                  _refreshController?.repeat();
                } else {
                  _refreshController?.stop();
                  _refreshController?.reset();
                }
                return RotationTransition(
                  turns: _refreshController ?? AlwaysStoppedAnimation(0),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      context.read<CustomersBloc>().add(const RefreshCustomers());
                    },
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<CustomersBloc, CustomersState>(
          builder: (context, state) {
            if (state is CustomersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CustomersError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CustomersBloc>().add(const LoadCustomers());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is CustomersLoaded) {
              final customers = state.customers;
              if (customers.isEmpty) {
                return const Center(child: Text("No customers found"));
              }
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildCard(
                          "Total Customers",
                          "${customers.length}",
                          Icons.people,
                          0,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTableHeader(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Scrollbar(
                        controller: _verticalController,
                        thumbVisibility: true,
                        child: ListView.separated(
                          controller: _verticalController,
                          itemCount: customers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final customer = customers[index];
                            return _buildTableRow(customer, index);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text("Initializing..."));
          },
        ),
      ),
    );
  }
}

