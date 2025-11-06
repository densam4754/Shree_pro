import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shree_pro/constants/widgets/customBottomNavigationBar.dart';
import 'package:shree_pro/constants/widgets/CustomTable.dart';
import 'package:shree_pro/constants/widgets/appBar.dart';
import 'package:shree_pro/constants/widgets/customCard.dart';
import 'package:shree_pro/constants/widgets/drawer.dart';

class StationsPage extends StatefulWidget {
  
  
  const StationsPage({super.key});
  

  @override
  State<StationsPage> createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar.myAppBar(),
      drawer: customDrawer(),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),

       body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Page title
            const Text(
              "Stations Management",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Manage fuel stations, locations, and assigned managers.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            /// Info Cards Row
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  children: const [
                    CustomCard(
                      title: 'Total stations',
                      subtitle: 1, 
                      icon: Bootstrap.ev_station, 
                      color: Colors.white),
                    SizedBox(width: 8),
                      CustomCard(
                      title: 'Total stations',
                      subtitle: 1, 
                      icon: Bootstrap.ev_station, 
                      color: Colors.white),
                    SizedBox(width: 8),
                 
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    // SizedBox(width: 8),
                      CustomCard(
                      title: 'Total stations',
                      subtitle: 1, 
                      icon: Bootstrap.ev_station, 
                      color: Colors.white),
                    SizedBox(width: 8),
                  
                      CustomCard(
                      title: 'Total stations',
                      subtitle: 1, 
                      icon: Bootstrap.ev_station, 
                      color: Colors.white),
                    SizedBox(width: 8),
                  ],
                ),
              ],
            ),

          

            /// Stations List Header
          
            const SizedBox(height: 12),
           MyTable(header1: 'Station', header2: 'Station Code', header3: 'Address', header5: 'Phone', header4: 'Energy Company')
            

            
          ],
        ),
      ),
    );
  }
}
