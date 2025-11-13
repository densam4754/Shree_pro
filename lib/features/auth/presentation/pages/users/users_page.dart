import 'package:flutter/material.dart';
import 'package:shree_pro/constants/widgets/CustomTable.dart';
import 'package:shree_pro/constants/widgets/appBar.dart';
import 'package:shree_pro/constants/widgets/customBottomNavigationBar.dart';
import 'package:shree_pro/constants/widgets/customCard.dart';
import 'package:shree_pro/constants/widgets/drawer.dart';
import 'package:icons_plus/icons_plus.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _DashboardState();
}

class _DashboardState extends State<UsersPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar.myAppBar(),
      drawer: customDrawer(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Page title
            const Text(
              "Users Management",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Manage system users, roles, and permissions",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            /// Info Cards Row
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(child: CustomCard(
                      title: 'Total users',
                      subtitle: 4, 
                      icon: Bootstrap.people, 
                      color: Colors.white)),
                    SizedBox(width: 8),
                     Expanded(child: CustomCard(
                      title: 'Active Users',
                      subtitle: 4, 
                      icon: Bootstrap.people, 
                      color: Colors.green)),
                    SizedBox(width: 8),
                 
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    // SizedBox(width: 8),
                     Expanded(child: CustomCard(
                      title: 'Unique Roles',
                      subtitle: 2, 
                      icon: Bootstrap.shield, 
                      color: Colors.white)),
                    SizedBox(width: 8),
                  
                     Expanded(child: CustomCard(
                      title: 'Companies',
                      subtitle: 0, 
                      icon: Bootstrap.ev_station, 
                      color: Colors.blue)),
                    SizedBox(width: 8),
                  ],
                ),
              ],
            ),

          

            /// Stations List Header
          
            const SizedBox(height: 12),
            MyTable(
              header1: 'User',
              header2: 'Contact', 
              header3: 'Role', 
              header5: 'Status',
              header4: 'Last Login'
                )
            

            
          ],
        ),
      ),

      /// Bottom Navigation
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
