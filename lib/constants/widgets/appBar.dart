import 'package:flutter/material.dart';
import 'package:shree_pro/constants/fonts.dart';

class TAppBar {
  static AppBar myAppBar({String title = "Shree Pro"}) {
    return AppBar(
      title: Text(title,style: AppFonts.header,),
      backgroundColor: Colors.blue[200],
      elevation: 0,
    );
  }
}
