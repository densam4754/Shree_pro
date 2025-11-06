import 'package:flutter/material.dart';

class MyTable extends StatefulWidget {
  final String header1;
  final String header2;
  final String header3;
  final String header4;
  final String header5;

  const MyTable({super.key,
  required this.header1,
  required this.header2,
  required this.header3,
  required this.header5,
  required this.header4,


  });

  @override
  State<MyTable> createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Table header row
          TableRow(
            decoration: BoxDecoration(color: Colors.blue),
            children:  [
              Padding(
                padding: EdgeInsets.all(8.0),
                 child:  Text(
                  widget.header1,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  widget.header2,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  widget.header3,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  widget.header4,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  widget.header5,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          // Table data rows
          const TableRow(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  ' msongola fuel station',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('STN002', style: TextStyle(fontSize: 12)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('123 Main Street', style: TextStyle(fontSize: 12)),
              ),

              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('+255700000000', style: TextStyle(fontSize: 12)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Shree Oil Company',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
