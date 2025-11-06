import 'package:flutter/material.dart';
// import 'package:shree_pro/constants/fonts.dart';
import 'package:shree_pro/presentation/authentication/login/login_screen.dart';
// import 'package:shree_pro/presentation/authentication/login/login_screen.dart';?

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   const MyApp({super.key});
    // int _currentIndex = 0;

  // final List<Widget> _pages = [
  //   DashboardPage(),
  //   SearchPage(),
  //   ProfilePage(),
  // ];


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        routes: {
        "/login": (context) => const AuthApi(),
        // "/home": (context) => const HomePage(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 248, 242, 242),
        fontFamily: "Inter",
         
      ),
      home: AuthApi(),
    );
  }
}
