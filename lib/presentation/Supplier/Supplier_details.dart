import 'package:flutter/material.dart';
import 'package:shree_pro/constants/fonts.dart';
import 'package:shree_pro/models/Suppliers.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SupplierDetailPage extends StatelessWidget {
  final SupplierDetail supplier;

  const SupplierDetailPage({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child:AnimationConfiguration.staggeredList(
            position: 0,
            duration: const Duration(milliseconds: 800),
            child: SlideAnimation(
              verticalOffset: 40,
              child: FadeInAnimation(
                child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                 Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.cancel,
                            color: Colors.grey, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),

                ListTile(
                  title: Text(
                    'Supplier ID',
                    style: AppFonts.subHeader,
                  ),
                  subtitle: Text(
                    ' ${supplier.supplId}',
                    style: AppFonts.body,
                  ),
                ),
                ListTile(
                  title: Text(
                    ' Name',
                    style: AppFonts.subHeader,
                  ),
                  subtitle: Text(
                    ' ${supplier.supplName}',
                    style: AppFonts.body,
                  ),
                ),
                ListTile(
                  title: Text(
                    'Email',
                    style: AppFonts.subHeader,
                  ),
                  subtitle: Text(
                    ' ${supplier.supplEmail}',
                    style: AppFonts.body,
                  ),
                ),
                ListTile(
                  title: Text(
                    'Phone',
                    style: AppFonts.subHeader,
                  ),
                  subtitle: Text(
                    ' ${supplier.supplPhone}',
                    style: AppFonts.body,
                  ),
                ),

                 ListTile(
                  title: Text(
                    'Address',
                    style: AppFonts.subHeader,
                  ),
                  subtitle: Text(
                    ' ${supplier.supplAddress}',
                    style: AppFonts.body,
                  ),
                ),
                

                //  ListTile(
                //   title: Text(
                //     'Genereted date',
                //     style: AppFonts.subHeader,
                //   ),
                //   subtitle: Text(
                //     ' ${supplier.genDate}',
                //     style: AppFonts.subHeader,
                //   ),
                // ),
                // ListTile(
                //   title: Text(
                //     'Status',
                //     style: AppFonts.subHeader,
                //   ),
                //   subtitle: Text(
                //     ' ${supplier.stsCode}',
                //     style: AppFonts.subHeader,
                //   ),
                // ),
                
                
                

              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

                
            