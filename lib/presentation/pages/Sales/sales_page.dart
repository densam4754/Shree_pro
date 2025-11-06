import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shree_pro/presentation/pages/Sales/Sales_details.dart';
import 'package:shree_pro/services/sale_api.dart';
import 'package:shree_pro/models/sale.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage>
    with SingleTickerProviderStateMixin {
  final SaleApi api = SaleApi();
  List<SaleDetail> sales = [];
  bool isLoading = true;

  final ScrollController _verticalController = ScrollController();
  late final AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    fetchSales();
  }

  Future<void> fetchSales() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    _refreshController.repeat();

    final data = await api.getAllSales();

    if (!mounted) return;
    setState(() {
      sales = data;
      isLoading = false;
    });
    _refreshController.stop();
    _refreshController.reset();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _refreshController.dispose();
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
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
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
            flex: 3,
            child: Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Amount",
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Action",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(SaleDetail s, int index) {
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
                // description
                Expanded(
                  flex: 3,
                  child: Hero(
                    tag: "desc_${s.slId}",
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        s.slDesc,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),

                // amount
                Expanded(
                  flex: 1,
                  child: Text(
                    s.billAmt.toStringAsFixed(2),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                // action button
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blueGrey),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => Dialog(
                              child: SizedBox(
                                height: 600,
                                width: 500,
                                child: SalesDetailPage(sale: s),
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
    final totalAmount = sales.fold<double>(0, (sum, s) => sum + s.billAmt);
    final totalProfit =
        sales.isEmpty
            ? 0
            : sales.fold<double>(0, (sum, s) => sum + (s.billAmt * 0.1));
    final avgSale = sales.isEmpty ? 0 : totalAmount / sales.length;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          "Sales",
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
            turns: _refreshController,
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: fetchSales,
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : sales.isEmpty
              ? const Center(child: Text("No sales found"))
              : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildCard(
                          "Total Sales",
                          "${sales.length}",
                          Bootstrap.cart4,
                          0,
                        ),
                        _buildCard(
                          "Total Amount",
                          totalAmount.toStringAsFixed(2),
                          Bootstrap.currency_dollar,
                          1,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildCard(
                          "Total Profit",
                          totalProfit.toStringAsFixed(2),
                          Bootstrap.graph_up_arrow,
                          2,
                        ),
                        _buildCard(
                          "Avg Sale",
                          avgSale.toStringAsFixed(2),
                          Bootstrap.bar_chart,
                          3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _buildTableHeader(),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Scrollbar(
                              controller: _verticalController,
                              thumbVisibility: true,
                              child: AnimationLimiter(
                                child: ListView.separated(
                                  controller: _verticalController,
                                  itemCount: sales.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 6),
                                  itemBuilder: (context, index) {
                                    final s = sales[index];
                                    return _buildTableRow(s, index);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
