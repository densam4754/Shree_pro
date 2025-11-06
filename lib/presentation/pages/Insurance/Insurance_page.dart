import 'package:flutter/material.dart';
import 'package:shree_pro/services/Insurance_api.dart';
import 'package:shree_pro/models/Insurance.dart';
import 'package:shree_pro/presentation/pages/Insurance/insurance_detail.dart';
import 'package:icons_plus/icons_plus.dart';

class InsurancePage extends StatefulWidget {
  const InsurancePage({super.key});

  @override
  State<InsurancePage> createState() => _InsurancePageState();
}

class _InsurancePageState extends State<InsurancePage> {
  final InsuranceApi api = InsuranceApi();
  List<InsuranceDetail> insurances = [];
  bool isLoading = true;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchInsurances();
  }

  Future<void> fetchInsurances() async {
    setState(() => isLoading = true);
    final data = await api.getAllInsurance();
    if (!mounted) return; // Prevent setState after dispose
    setState(() {
      insurances = data;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  // Metric Card
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
    final activeCount = insurances.where((i) => i.stsCode == "10001").length;
    final inactiveCount = insurances.length - activeCount;
    final lastUpdated =
        insurances.isEmpty ? "-" : insurances.first.genDate.split("T").first;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          "Insurance",
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
            onPressed: fetchInsurances,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : insurances.isEmpty
              ? const Center(child: Text("No insurances found"))
              : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Metric Cards Row 1
                    Row(
                      children: [
                        _buildCard(
                          "Total Insurances",
                          "${insurances.length}",
                          Bootstrap.clipboard2_check,
                        ),
                        _buildCard(
                          "Active",
                          "$activeCount",
                          Bootstrap.check_circle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Metric Cards Row 2
                    Row(
                      children: [
                        _buildCard(
                          "Inactive",
                          "$inactiveCount",
                          Bootstrap.x_circle,
                        ),
                        _buildCard(
                          "Last Updated",
                          lastUpdated,
                          Bootstrap.calendar_event,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // DataTable with scrollbars
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
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  Colors.blue.shade100,
                                ),
                                dataRowColor: MaterialStateProperty.resolveWith(
                                  (states) =>
                                      states.contains(MaterialState.hovered)
                                          ? Colors.blue.shade50
                                          : null,
                                ),
                                border: TableBorder.all(
                                  color: Colors.grey.shade300,
                                ),
                                columns: const [
                                  DataColumn(label: Text("Insurance Name")),
                                  DataColumn(label: Text("Rate")),

                                  // DataColumn(label: Text("Status")),
                                  DataColumn(label: Text("Actions")),
                                ],
                                rows:
                                    insurances.map((i) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(i.insCompNm)),
                                          DataCell(Text(i.insRate.toString())),

                                         
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(Bootstrap.eye),
                                              color: Colors.blue,
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (_) => Dialog(
                                                        child: SizedBox(
                                                          width: 400,
                                                          height: 600,
                                                          child:
                                                              InsuranceDetails(
                                                                insurance: i,
                                                              ),
                                                        ),
                                                      ),
                                                );
                                              },
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
                  ],
                ),
              ),
    );
  }
}
