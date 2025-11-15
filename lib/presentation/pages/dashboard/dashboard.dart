import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/widgets/drawer.dart';
import '../../../core/injection/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/components/network_check_widget.dart';
import '../settings/settings_page.dart';
import '../stations/stations_list_page.dart';
import 'dashboard_home_page.dart';
import 'widgets/dashboard_bottom_nav_bar.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  const DashboardPage({super.key, required this.username});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BlocProvider.value(
        value: salesBloc,
        child: DashboardHomeContent(username: widget.username),
      ),
      BlocProvider.value(
        value: salesBloc,
        child: const StationsListPage(),
      ),
      SettingsPage(username: widget.username),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NetworkCheckWidget(
      child: _DashboardShell(
        isDark: isDark,
        drawer: const customDrawer(),
        body: _pages[_selectedIndex],
        selectedIndex: _selectedIndex,
        onTabSelected: _onItemTapped,
      ),
    );
  }
}

class _DashboardShell extends StatelessWidget {
  const _DashboardShell({
    required this.isDark,
    required this.drawer,
    required this.body,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final bool isDark;
  final Widget drawer;
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppTheme.grey900 : AppTheme.grey100,
      drawer: drawer,
      body: body,
      bottomNavigationBar: DashboardBottomNavBar(
        isDark: isDark,
        selectedIndex: selectedIndex,
        onItemSelected: onTabSelected,
      ),
    );
  }
}
