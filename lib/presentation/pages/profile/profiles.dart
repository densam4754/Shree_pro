import 'package:flutter/material.dart';
import 'package:shree_pro/api/user_api.dart';
import 'package:shree_pro/models/user.dart';
import 'package:shree_pro/constants/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserApi userApi = UserApi();
  User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    final data = await userApi.getUserDetail(widget.username);
    setState(() {
      user = data;
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : user != null
              ? SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Container(
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text("Profile", style: AppFonts.header),
                    //       const SizedBox(height: 20),
                    //     ],
                    //   ),
                    // ),

                    // Profile Header
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color.fromARGB(255, 211, 207, 207)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            // blurRadius: 10,
                            // offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,

                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Color.fromARGB(255, 112, 119, 124),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "${user!.firstName} ${user!.lastName}",
                            style: AppFonts.subHeader,
                          ),
                          Text("@${user!.username}", style: AppFonts.body),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // User Info
                    _buildInfoCard(Icons.email, "Email", user!.email),
                    _buildInfoCard(Icons.phone, "Phone", user!.phone),
                    _buildInfoCard(Icons.verified_user, "Role", user!.roleName),

                    const SizedBox(height: 30),

                    // Logout Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text(
                                  "Logout",
                                  style: AppFonts.body,
                                ),
                                content: const Text(
                                  "Are you sure you want to logout?",
                                  style: AppFonts.body,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text("Logout"),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          _logout();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          240,
                          237,
                          237,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 30,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout, color: Colors.black),
                      label: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              )
              : const Center(child: Text("User not found")),
    );
  }

  // Reusable info card with icon
  Widget _buildInfoCard(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: AppFonts.subHeader),
      subtitle: Text(value, style: AppFonts.body),
    );
  }
}
