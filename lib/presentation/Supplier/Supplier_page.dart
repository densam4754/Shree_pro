import 'package:flutter/material.dart';
import 'package:shree_pro/constants/fonts.dart';
import 'package:shree_pro/services/Supplier_api.dart';
import 'package:shree_pro/models/Suppliers.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shree_pro/presentation/Supplier/Supplier_details.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final SupplierApi api = SupplierApi();
  List<SupplierDetail> suppliers = [];
  bool isLoading = true;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchSuppliers();
  }

  Future<void> fetchSuppliers() async {
    setState(() => isLoading = true);
    final data = await api.getAllSuppliers();
    setState(() {
      suppliers = data;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  // Reusable metric card
  Widget _buildCard(String label, String value, IconData icon) {
    return Expanded(
      child: AnimationConfiguration.staggeredList(
        position: 0,
        duration: const Duration(milliseconds: 800),
        child: SlideAnimation(
          verticalOffset: 40,
          child: FadeInAnimation(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey.shade100],
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
                          Text(label, style: AppFonts.body),
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
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Compute metrics
    final activeSuppliers = suppliers.where((s) => s.stsCode == 10001).length;
    final inactiveSuppliers = suppliers.where((s) => s.stsCode != 10001).length;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          "Suppliers",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 250, 251, 252), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchSuppliers,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : suppliers.isEmpty
              ? const Center(child: Text("No suppliers found"))
              : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Metric cards Row 1
                    Row(
                      children: [
                        _buildCard(
                          "Total Suppliers",
                          "${suppliers.length}",
                          Bootstrap.people,
                        ),
                        _buildCard(
                          "Active",
                          "$activeSuppliers",
                          Bootstrap.check_circle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Metric cards Row 2
                    Row(
                      children: [
                        _buildCard(
                          "Inactive",
                          "$inactiveSuppliers",
                          Bootstrap.x_circle,
                        ),
                        _buildCard(
                          "Last Updated",
                          suppliers.isEmpty
                              ? "-"
                              : suppliers.first.genDate.split("T").first,
                          Bootstrap.calendar_event,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // DataTable with scrolling
                    Expanded(
                      child: Scrollbar(
                        controller: _horizontalController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _horizontalController,
                          scrollDirection: Axis.horizontal,
                          child: Scrollbar(
                            controller: _verticalController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _verticalController,
                              scrollDirection: Axis.vertical,

                              child: AnimationConfiguration.staggeredList(
                                position: 0,
                                duration: const Duration(milliseconds: 1100),
                                child: SlideAnimation(
                                  verticalOffset: 40,
                                  child: FadeInAnimation(
                                    child: DataTable(
                                      showCheckboxColumn: false,
                                      headingRowColor:
                                          MaterialStateProperty.all(
                                            Colors.blue.shade100,
                                          ),
                                      dataRowColor:
                                          MaterialStateProperty.resolveWith(
                                            (states) =>
                                                states.contains(
                                                      MaterialState.hovered,
                                                    )
                                                    ? Colors.blue.shade50
                                                    : null,
                                          ),
                                      border: TableBorder.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      columns: const [
                                        DataColumn(label: Text("Name")),
                                        DataColumn(label: Text("Address")),
                                        // DataColumn(label: Text("Status")),
                                        DataColumn(
                                          label: Text("Action"),
                                        ), // 👈 New column
                                      ],
                                      rows:
                                          suppliers.map((s) {
                                            return DataRow(
                                              cells: [
                                                DataCell(Text(s.supplName)),
                                                DataCell(Text(s.supplAddress)),
                                                // DataCell(
                                                //   Container(
                                                //     padding:
                                                //         const EdgeInsets.symmetric(
                                                //           horizontal: 8,
                                                //           vertical: 4,
                                                //         ),
                                                //     decoration: BoxDecoration(
                                                //       color:
                                                //           s.stsCode == 10001
                                                //               ? Colors
                                                //                   .green
                                                //                   .shade300
                                                //               : Colors
                                                //                   .red
                                                //                   .shade300,
                                                //       borderRadius:
                                                //           BorderRadius.circular(
                                                //             12,
                                                //           ),
                                                //     ),
                                                //     child: Text(
                                                //       s.stsCode == 10001
                                                //           ? "Active"
                                                //           : "Inactive",
                                                //       style: const TextStyle(
                                                //         fontWeight:
                                                //             FontWeight.bold,
                                                //         color: Colors.white,
                                                //       ),
                                                //     ),
                                                //   ),
                                                // ),
                                                DataCell(
                                                  IconButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (_) => Dialog(
                                                              child: AnimationConfiguration.staggeredList(
                                                                position: 0,
                                                                duration:
                                                                    const Duration(
                                                                      milliseconds:
                                                                          450,
                                                                    ),
                                                                child: SlideAnimation(
                                                                  horizontalOffset:
                                                                      50,
                                                                  child: FadeInAnimation(
                                                                    child: SizedBox(
                                                                      width:
                                                                          400,
                                                                      height:
                                                                          700,
                                                                      child: SupplierDetailPage(
                                                                        supplier:
                                                                            s,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                      );
                                                    },

                                                    icon: const Icon(
                                                      Icons.visibility,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
