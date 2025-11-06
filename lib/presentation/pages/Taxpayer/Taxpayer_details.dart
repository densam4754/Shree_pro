import 'package:flutter/material.dart';
// import 'package:icons_plus/icons_plus.dart';
import 'package:shree_pro/constants/fonts.dart';
import 'package:shree_pro/models/Taxpayer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class TaxpayerDetails extends StatelessWidget {
  final TaxpayerDetail taxpayer;
  const TaxpayerDetails({super.key, required this.taxpayer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: AnimationConfiguration.staggeredGrid(
        position: 0,
        duration: const Duration(milliseconds: 600),
        columnCount: 1,
        child: ScaleAnimation(
          child: FadeInAnimation(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Align(

                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.grey, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                ),
                ListTile(
                  title: Text('Name',style: AppFonts.subHeader,),
                  subtitle: Text(taxpayer.spName,style: AppFonts.body,),
                ),
                ListTile(
                  title: Text('Description',style: AppFonts.subHeader),
                  subtitle: Text(taxpayer.spDesc,style: AppFonts.body,),
                ),
                ListTile(
                  title: Text('Approved by',style: AppFonts.subHeader),
                  subtitle: Text(taxpayer.apvdBy,style: AppFonts.body,),
                ),
                ListTile(
                  title: Text('Status',style: AppFonts.subHeader),
                  subtitle: Text(taxpayer.stsCode.toString(),style: AppFonts.body,),
                ),
               
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
