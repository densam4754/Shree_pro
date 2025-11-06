import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;          // Which tab is selected
  final Function(int) onTap;       // Callback when a tab is tapped

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color.fromARGB(255, 238, 236, 236),
      elevation: 0,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Bootstrap.speedometer),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Bootstrap.search),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Icon(Bootstrap.person),
          label: "Profile",
        ),
      ],
    );
  }
}
