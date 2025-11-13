import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../domain/models/sale.dart';
import 'package:shree_pro/constants/fonts.dart';

class SalesDetailPage extends StatelessWidget {
  final SaleDetail sale;

  const SalesDetailPage({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      
      child: AnimationConfiguration.staggeredGrid(
        position: 0,
        duration: const Duration(milliseconds: 600),
        columnCount: 1,
        child: ScaleAnimation(
          child: FadeInAnimation(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cancel button
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.cancel,
                            color: Colors.grey, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),

                    ListTile(
                      title: Text('Sale ID', style: AppFonts.subHeader),
                      subtitle: Text(' ${sale.slId}', style: AppFonts.body),
                    ),
                    ListTile(
                      title:
                          Text('Transaction ID', style: AppFonts.subHeader),
                      subtitle:
                          Text(' ${sale.slTxIdNum}', style: AppFonts.body),
                    ),
                    ListTile(
                      title: Text('Total Amount', style: AppFonts.subHeader),
                      subtitle: Text(' ${sale.billAmt.toStringAsFixed(2)}',
                          style: AppFonts.body),
                    ),
                    ListTile(
                      title: Text('Description', style: AppFonts.subHeader),
                      subtitle: Text(' ${sale.slDesc}', style: AppFonts.body),
                    ),
                    ListTile(
                      title: Text('Date', style: AppFonts.subHeader),
                      subtitle: Text(' ${sale.slDt}', style: AppFonts.body),
                    ),

                    const SizedBox(height: 16),

                    // Text("Items",
                    //     style: AppFonts.header
                    //         .copyWith(color: Colors.blueGrey)),
                    // const Divider(),

                    // Items DataTable
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: DataTable(
                    //     headingRowColor: MaterialStateProperty.all(
                    //         Colors.blueGrey.shade50),
                    //     columns: const [
                    //       DataColumn(
                    //           label: Text("Code",
                    //               style:
                    //                   TextStyle(fontWeight: FontWeight.bold))),
                    //       DataColumn(
                    //           label: Text("Name",
                    //               style:
                    //                   TextStyle(fontWeight: FontWeight.bold))),
                    //       DataColumn(
                    //           label: Text("Amount",
                    //               style:
                    //                   TextStyle(fontWeight: FontWeight.bold))),
                    //       DataColumn(
                    //           label: Text("Cost",
                    //               style:
                    //                   TextStyle(fontWeight: FontWeight.bold))),
                    //       DataColumn(
                    //           label: Text("Profit",
                    //               style:
                    //                   TextStyle(fontWeight: FontWeight.bold))),
                    //     ],
                    //     rows: sale.items.map((item) {
                    //       return DataRow(
                    //         cells: [
                    //           DataCell(Text(item.code)),
                    //           DataCell(Text(item.name)),
                    //           DataCell(
                    //               Text(item.amount.toStringAsFixed(2))),
                    //           DataCell(Text(item.cost.toStringAsFixed(2))),
                    //           DataCell(Text(item.profit.toStringAsFixed(2))),
                    //         ],
                    //       );
                    //     }).toList(),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
