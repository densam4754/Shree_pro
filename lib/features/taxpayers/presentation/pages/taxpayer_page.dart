import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../data/services/taxpayer_api.dart';
import '../../domain/models/taxpayer.dart';
import 'taxpayer_details.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class TaxpayersPage extends StatefulWidget {
  const TaxpayersPage({super.key});

  @override
  State<TaxpayersPage> createState() => _TaxpayersPageState();
}

class _TaxpayersPageState extends State<TaxpayersPage> {
  final TaxpayerApi api = TaxpayerApi();
  List<TaxpayerDetail> taxpayers = [];
  bool isLoading = true;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchTaxpayers();
  }

 Future<void> fetchTaxpayers() async {
  if (!mounted) return; // optional, just to avoid calling too early
  setState(() => isLoading = true);

  final data = await api.getAllTaxpayers();

  if (!mounted) return; // <-- check if widget is still in the tree
  setState(() {
    taxpayers = data;
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTaxpayers =
        taxpayers.where((t) => t.stsCode == "10001").length;
    final inactiveTaxpayers =
        taxpayers.where((t) => t.stsCode != "10001").length;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          "Taxpayers",
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
            onPressed: fetchTaxpayers,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : taxpayers.isEmpty
              ? const Center(child: Text("No taxpayers found"))
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Metric cards Row 1
                      Row(
                        children: [
                          _buildCard(
                            "Total Taxpayers",
                            "${taxpayers.length}",
                            Bootstrap.people,
                          ),
                          _buildCard(
                            "Active",
                            "$activeTaxpayers",
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
                            "$inactiveTaxpayers",
                            Bootstrap.x_circle,
                          ),
                          _buildCard(
                            "Last Updated",
                            taxpayers.isEmpty
                                ? "-"
                                : taxpayers.first.genDate.split("T").first,
                            Bootstrap.calendar_event,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // DataTable with scrolling
                      Expanded(
                        // width: 410,
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
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                    Colors.blue.shade100,
                                  ),
                                  dataRowColor:
                                      MaterialStateProperty.resolveWith(
                                    (states) =>
                                        states.contains(MaterialState.hovered)
                                            ? Colors.blue.shade50
                                            : null,
                                  ),
                                  border: TableBorder.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  columns: const [
                                    // DataColumn(label: Text("Ref No.")),
                                    DataColumn(label: Text("Name")),
                                    // DataColumn(label: Text("Description")),
                                    // DataColumn(label: Text("Generated Date")),
                                    // DataColumn(label: Text("Generated By")),
                                    // DataColumn(label: Text("Approved Date")),
                                    // DataColumn(label: Text("Approved By")),
                                    // DataColumn(label: Text("Status")),
                                    DataColumn(label: Text("In detail")),
                                  ],
                                  rows: taxpayers.map((t) {
                                    return DataRow(
                                      cells: [
                                        // DataCell(Text(t.spRefNum)),
                                        DataCell(Text(t.spName)),
                                        // DataCell(Text(t.spDesc)),
                                        // DataCell(Text(t.genDate)),
                                        // DataCell(Text(t.genBy)),
                                        // DataCell(Text(t.apvdDate)),
                                        // DataCell(Text(t.apvdBy)),
                                        // DataCell(
                                        //   Container(
                                        //     padding: const EdgeInsets.symmetric(
                                        //       horizontal: 8,
                                        //       vertical: 4,
                                        //     ),
                                        //     decoration: BoxDecoration(
                                        //       color: t.stsCode == "10001"
                                        //           ? Colors.green.shade300
                                        //           : Colors.red.shade300,
                                        //       borderRadius:
                                        //           BorderRadius.circular(12),
                                        //     ),
                                        //     child: Text(
                                        //       t.stsCode == "10001"
                                        //           ? "Active"
                                        //           : "Inactive",
                                        //       style: const TextStyle(
                                        //         fontWeight: FontWeight.bold,
                                        //         color: Colors.white,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(
                                              Bootstrap.eye,
                                              color: Colors.black,
                                            ),
                                            onPressed: () {
                                             showDialog(
                                              context: context,
                                               builder: (_)=>
                                               Dialog(
                                                child:SizedBox(
                                                  width: 400, // fixed width for the card
                                                  height: 600,
                                                  child: TaxpayerDetails(taxpayer: t,)
                                                )
                                              
                                               )
                                               ,
                                             );
                                            },
                                          ),
                                        )
                                      ],
                                    );
                                  }).toList(),
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
