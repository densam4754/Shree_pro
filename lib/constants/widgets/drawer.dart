import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shree_pro/presentation/pages/Customers/CustomersPage.dart';
import 'package:shree_pro/presentation/pages/dashboard/stations/dashboard.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shree_pro/presentation/pages/Sales/sales_page.dart';
import 'package:shree_pro/presentation/pages/users/user_detail_page.dart';
import 'package:shree_pro/presentation/Purchases/Purchases_page.dart';
import 'package:shree_pro/presentation/Supplier/Supplier_page.dart';
import 'package:shree_pro/presentation/pages/Taxpayer/Taxpayer_page.dart';
import 'package:shree_pro/presentation/pages/Insurance/Insurance_page.dart';
import 'package:shree_pro/api/user_api.dart';

class customDrawer extends StatelessWidget {
  const customDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 100,
        child: FadeInAnimation(
          child: Drawer(
            child: Column(
              children: [
                // Drawer Header with Gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 16,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 250, 251, 252),
                        Color(0xFF64B5F6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          "assets/images/shree2.png",
                          height: 30,
                          width: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Shree Pro",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Drawer Menu List
                Expanded(
                  child: AnimationConfiguration.staggeredList(
                    position: 0,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 500,
                      child: FadeInAnimation(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          children: [
                            _buildDrawerItem(
                              icon: Bootstrap.speedometer2,
                              label: "Dashboard",
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DashboardPage(username: ""),
                                  ),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              icon: Bootstrap.people_fill,
                              label: "Customers",
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CustomersPage(),
                                  ),
                                );
                              },
                            ),
                            // _buildDrawerItem(
                            //   icon: Icons.people,
                            //   label: "Users",
                            //   onTap: () {
                            //     Navigator.pop(context);
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder:
                            //             (_) => const UserDetailPage(
                            //               username: "festo.taxpayer",
                            //             ),
                            //       ),
                            //     );
                            //   },
                            // ),
                            _buildDrawerItem(
                              icon: Bootstrap.bar_chart,
                              label: "Sales",
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SalesPage(),
                                  ),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              icon: Bootstrap.graph_up,
                              label: "Purchases",
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PurchasesPage(),
                                  ),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              icon: Bootstrap.droplet,
                              label: "Suppliers",
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SuppliersPage(),
                                  ),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              icon: Bootstrap.currency_dollar,
                              label: "Taxpayers",
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TaxpayersPage(),
                                  ),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              icon: Bootstrap.graph_down_arrow,
                              label: "Insurance",
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const InsurancePage(),
                                  ),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              icon: Bootstrap.file_earmark,
                              label: "Daily Summary Report",
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SuppliersPage(),
                                  ),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              icon: Bootstrap.file_earmark_medical,
                              label: "Report",
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SuppliersPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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

  // Reusable drawer tile
  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.grey.shade100,
      hoverColor: Colors.blue.shade50,
      dense: true,
    );
  }
}
