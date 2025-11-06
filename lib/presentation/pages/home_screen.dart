// import 'package:flutter/material.dart';
// import 'package:shree_pro/presentation/pages/dashboard/stations/dashboard.dart';
// import 'package:shree_pro/presentation/pages/profile/profiles.dart';
// import 'package:shree_pro/presentation/pages/search/search.dart';
// // import 'package:shree_pro/presentation/pages/profile/profiles.dart';
// // import 'package:shree_pro/constants/widgets/customBottomNavigationBar.dart';

// class HomeScreen extends StatefulWidget {
//   final String username;

//   const HomeScreen({super.key, required this.username});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;

//   late final List<Widget> _pages;

//   @override
//   void initState() {
//     super.initState();
//     _pages = [
//       const DashboardPage(),
//       const SearchPage(),
//       ProfilePage(username: widget.username),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: _pages[_currentIndex]);
//   }
// }
