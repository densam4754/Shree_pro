import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shree_pro/models/customerss.dart';
import 'package:shree_pro/services/customer_api.dart';
import 'package:shree_pro/presentation/pages/Customers/customer_detail_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({Key? key}) : super(key: key);

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _verticalController = ScrollController();
  AnimationController? _refreshController;

  List<Customerss> customers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    fetchCustomers();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _refreshController?.dispose();
    super.dispose();
  }

  Future<void> fetchCustomers() async {
    setState(() => isLoading = true);
    _refreshController?.repeat();

    try {
      final data = await CustomerApi().getAllCustomers();
      if (!mounted) return;
      setState(() {
        customers = data;
      });
    } catch (e) {
      debugPrint("Error fetching customers: $e");
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
      _refreshController?.stop();
      _refreshController?.reset();
    }
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
          // Expanded(flex: 2, child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
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

  Widget _buildTableRow(Customerss c, int index) {
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
                Expanded(flex: 2, child: Text(c.name)),
                // Expanded(flex: 2, child: Text(c.email)),
                Expanded(flex: 2, child: Text(c.phone)),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blueGrey),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => Dialog(
                              child: AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 450),
                                child: SlideAnimation(
                                  horizontalOffset: 50,
                                  child: FadeInAnimation(
                                    child: SizedBox(
                                      height: 600,
                                      width: 500,
                                      child: CustomerDetailPage(customer: c),
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
    return Scaffold(
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
          RotationTransition(
            turns: _refreshController ?? AlwaysStoppedAnimation(0),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: fetchCustomers,
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : customers.isEmpty
              ? const Center(child: Text("No customers found"))
              : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Metric card
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
                    // Table
                    _buildTableHeader(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Scrollbar(
                        controller: _verticalController,
                        thumbVisibility: true,
                        child: ListView.separated(
                          controller: _verticalController,
                          itemCount: customers.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final c = customers[index];
                            return _buildTableRow(c, index);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
