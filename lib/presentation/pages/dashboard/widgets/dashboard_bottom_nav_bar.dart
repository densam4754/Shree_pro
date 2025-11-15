import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardBottomNavBar extends StatelessWidget {
  const DashboardBottomNavBar({
    super.key,
    required this.isDark,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final bool isDark;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  static const List<_DashboardNavItemData> _items = [
    _DashboardNavItemData(
      icon: Iconsax.home_2_outline,
      label: 'Home',
    ),
    _DashboardNavItemData(
      icon: Icons.local_gas_station_outlined,
      label: 'Stations',
    ),
    _DashboardNavItemData(
      icon: Iconsax.setting_2_outline,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : AppTheme.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                return Expanded(
                  child: _DashboardNavItem(
                    data: item,
                    isDark: isDark,
                    isSelected: selectedIndex == index,
                    onTap: () => onItemSelected(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardNavItem extends StatelessWidget {
  const _DashboardNavItem({
    required this.data,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  final _DashboardNavItemData data;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              data.icon,
              size: 22,
              color: isSelected
                  ? AppTheme.primaryBlue
                  : isDark
                      ? AppTheme.grey400
                      : AppTheme.grey600,
            ),
            const SizedBox(width: 8),
            Text(
              data.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryBlue
                    : isDark
                        ? AppTheme.grey300
                        : AppTheme.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardNavItemData {
  const _DashboardNavItemData({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

