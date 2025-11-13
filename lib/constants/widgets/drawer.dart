import 'package:flutter/material.dart';
import 'package:shree_pro/features/customers/presentation/pages/customers_page.dart';
import 'package:shree_pro/presentation/pages/dashboard/stations/dashboard.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shree_pro/features/sales/presentation/pages/sales_page.dart';
import 'package:shree_pro/features/purchases/presentation/pages/purchases_page.dart';
import 'package:shree_pro/features/suppliers/presentation/pages/supplier_page.dart';
import 'package:shree_pro/features/taxpayers/presentation/pages/taxpayer_page.dart';
import 'package:shree_pro/features/insurance/presentation/pages/insurance_page.dart';
import 'package:shree_pro/core/theme/app_theme.dart';

class customDrawer extends StatelessWidget {
  const customDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppTheme.grey900 : AppTheme.white,
      child: Column(
        children: [
          // Drawer Header with Gradient
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 30,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppTheme.grey800,
                        AppTheme.grey700,
                      ]
                    : [
                        AppTheme.primaryBlue,
                        AppTheme.halfDeepBlue,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'SP',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Shree Pro",
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Fuel Station Management",
                            style: TextStyle(
                              color: AppTheme.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Drawer Menu List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Bootstrap.speedometer2,
                  label: "Dashboard",
                  isDark: isDark,
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
                  context: context,
                  icon: Bootstrap.people_fill,
                  label: "Customers",
                  isDark: isDark,
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
                _buildDrawerItem(
                  context: context,
                  icon: Bootstrap.bar_chart,
                  label: "Sales",
                  isDark: isDark,
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
                  context: context,
                  icon: Bootstrap.graph_up,
                  label: "Purchases",
                  isDark: isDark,
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
                  context: context,
                  icon: Bootstrap.droplet,
                  label: "Suppliers",
                  isDark: isDark,
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
                  context: context,
                  icon: Bootstrap.currency_dollar,
                  label: "Taxpayers",
                  isDark: isDark,
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
                  context: context,
                  icon: Bootstrap.graph_down_arrow,
                  label: "Insurance",
                  isDark: isDark,
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
                  context: context,
                  icon: Bootstrap.file_earmark,
                  label: "Daily Summary Report",
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Daily Summary Report
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Bootstrap.file_earmark_medical,
                  label: "Report",
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Report
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reusable drawer tile
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? AppTheme.grey800 : AppTheme.grey100,
      ),
      child: ListTile(
        leading: Container(
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
        title: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? AppTheme.white : AppTheme.black,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: AppTheme.primaryBlue.withOpacity(0.1),
        dense: true,
      ),
    );
  }
}

