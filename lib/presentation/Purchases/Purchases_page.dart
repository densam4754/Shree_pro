import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:shree_pro/models/Purchase.dart';
import 'package:shree_pro/services/purchases_api.dart';
import 'package:shree_pro/presentation/Purchases/purchase_detail.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage>
    with SingleTickerProviderStateMixin {
  final PurchasesApi api = PurchasesApi();
  List<PurchaseDetail> purchases = [];
  bool isLoading = true;

  late final AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    fetchPurchases();
  }

  Future<void> fetchPurchases() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    _refreshController.repeat();

    final data = await api.getAllPurchases();

    if (!mounted) return;
    setState(() {
      purchases = data;
      isLoading = false;
    });

    _refreshController.stop();
    _refreshController.reset();
  }

  @override
  void dispose() {
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
                      Text(label,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(value,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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
              flex: 2,
              child: Text("Purchase ID",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Text("Amount",
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Text("Action",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTableRow(PurchaseDetail p, int index) {
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
                Expanded(flex: 2, child: Text(p.purchaseId)),
                Expanded(
                    flex: 1,
                    child: Text(p.billAmount, textAlign: TextAlign.right)),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.blue),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: SizedBox(
                              width: 400,
                              height: 600,
                              child: PurchaseDetails(purchase: p),
                            ),
                          ),
                        );
                      },
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

  @override
  Widget build(BuildContext context) {
    final totalAmount = purchases.fold<double>(
        0, (sum, p) => sum + (double.tryParse(p.billAmount) ?? 0));
    final avgPurchase =
        purchases.isEmpty ? 0 : totalAmount / purchases.length;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text("Purchases",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
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
              onPressed: fetchPurchases,
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Lottie.asset('assets/Animations/loading.json',
                  width: 150, height: 150, repeat: true),
            )
          : purchases.isEmpty
              ? const Center(child: Text("No purchases found"))
              : Column(
                  children: [
                    // Metric cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          _buildCard("Total Purchases",
                              "${purchases.length}", Bootstrap.cart4, 0),
                          _buildCard("Total Amount",
                              totalAmount.toStringAsFixed(2),
                              Bootstrap.currency_dollar, 1),
                          _buildCard("Avg Purchase",
                              avgPurchase.toStringAsFixed(2), Bootstrap.bar_chart, 2),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Table header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _buildTableHeader(),
                    ),
                    const SizedBox(height: 8),

                    // Table rows
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: AnimationLimiter(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: purchases.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 6),
                            itemBuilder: (context, index) =>
                                _buildTableRow(purchases[index], index),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
