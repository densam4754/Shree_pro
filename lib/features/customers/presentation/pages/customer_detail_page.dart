// pages/customer_detail_page.dart
import 'package:flutter/material.dart';
import 'package:shree_pro/constants/fonts.dart';
import '../../domain/models/customerss.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import 'dart:ui';

class CustomerDetailPage extends StatelessWidget {
  final Customerss customer;

  const CustomerDetailPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: AnimationConfiguration.staggeredGrid(
        position: 0,
        duration: const Duration(milliseconds: 600),
        columnCount: 1,
        child: ScaleAnimation(
          child: FadeInAnimation(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.cancel,
                        color: Colors.grey,
                        size: 28,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  ListTile(
                    title: Text('Name', style: AppFonts.subHeader),
                    subtitle: Text(' ${customer.name}', style: AppFonts.body),
                  ),

                  ListTile(
                    title: Text('ID', style: AppFonts.subHeader),
                    subtitle: Text(' ${customer.id}', style: AppFonts.body),
                  ),

                  ListTile(
                    title: Text('Email', style: AppFonts.subHeader),
                    subtitle: Text(' ${customer.email}', style: AppFonts.body),
                  ),

                  ListTile(
                    title: Text('Phone', style: AppFonts.subHeader),
                    subtitle: Text(' ${customer.phone}', style: AppFonts.body),
                  ),

                  ListTile(
                    title: Text('Address', style: AppFonts.subHeader),
                    subtitle: Text(
                      ' ${customer.address}',
                      style: AppFonts.body,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
