import 'package:flutter/material.dart';
import 'package:shree_pro/constants/widgets/appBar.dart';
import 'package:shree_pro/constants/widgets/drawer.dart';


class Customappbar extends StatelessWidget {
  const Customappbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar.myAppBar(),
      drawer: customDrawer(),
    );
  }
}