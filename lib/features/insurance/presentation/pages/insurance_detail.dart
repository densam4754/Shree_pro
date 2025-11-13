import 'package:flutter/material.dart';
import '../../domain/models/insurance.dart';
import 'package:shree_pro/constants/fonts.dart';

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class InsuranceDetails extends StatelessWidget {
  final InsuranceDetail insurance;
  const InsuranceDetails({super.key, required this.insurance});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: AnimationConfiguration.staggeredGrid(
        position: 0,
        duration: const Duration(milliseconds: 600),
        columnCount: 1,
        child: ScaleAnimation(
          child: FadeInAnimation(
            child:Padding(padding: EdgeInsets.all(16),
              child: Column(
              children: [

                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.grey, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                ListTile(
                  title: Text('Ref no',style: AppFonts.subHeader,),
                  subtitle: Text(insurance.spRefNum,style: AppFonts.body,),
                ),
                ListTile(
                  title: Text("Insurence code",style: AppFonts.subHeader,),
                  subtitle: Text(insurance.insCompCode,style: AppFonts.body,),
                ),
                ListTile(
                  title: Text("Insurence name",style: AppFonts.subHeader,),
                  subtitle: Text(insurance.insCompNm,style: AppFonts.body,),
                ),
                ListTile(
                  title: Text("Rate",style: AppFonts.subHeader,),
                  subtitle: Text(insurance.insRate.toString(),style: AppFonts.body,),
                ),
                ListTile(
                  title: Text("Approved Date",style: AppFonts.subHeader,),
                  subtitle: Text(insurance.apvdDate.split("T").first,style: AppFonts.body,),
                ),
                ListTile(
                  title: Text("IStatus",style: AppFonts.subHeader,),
                  subtitle: Text(insurance.stsCode,style: AppFonts.body,),
                ),
              ],
            ), 
            )
          
          ),
        ),
      ),
    );
  }
}
