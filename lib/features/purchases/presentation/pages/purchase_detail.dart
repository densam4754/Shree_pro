import 'package:flutter/material.dart';
import '../../domain/models/purchase.dart';
import 'package:shree_pro/constants/fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class PurchaseDetails extends StatelessWidget {
  final PurchaseDetail purchase;

  const PurchaseDetails({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Card(
     child:AnimationConfiguration.staggeredGrid(
       position: 0,
       duration: const Duration(milliseconds: 600),
       columnCount: 1,
       child: ScaleAnimation(
         child: FadeInAnimation(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.grey, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            ListTile(
              title: Text(
                'ID',
                style: AppFonts.subHeader,
              ),
              subtitle: Text(
                ' ${purchase.purchaseId}',
                style: AppFonts.body,
              ),
            ),
            ListTile(
              title: Text(
                'Amount',
                style: AppFonts.subHeader,
              ),
              subtitle: Text(
                ' ${purchase.billAmount}',
                style: AppFonts.body,
              ),
            ),
            ListTile(
              title: Text(
                'Purchase Amount',
                style: AppFonts.subHeader,
              ),
              subtitle: Text(
                ' ${purchase.purchaseAmout}',
                style: AppFonts.body,
              ),
            ),
            ListTile(
              title: Text(
                'Purchase Quantity',
                style: AppFonts.subHeader,
              ),
              subtitle: Text(
                ' ${purchase.purchaseQuantity}',
                style: AppFonts.body,
              ),
            ),
            ListTile(
              title: Text(
                'Supppler email',
                style: AppFonts.subHeader,
              ),
              subtitle: Text(
                ' ${purchase.supplierEmail}',
                style: AppFonts.body,
              ),
            ),
          ],
        ),
         ),
       ),
     ),
    );
  }
              

}
