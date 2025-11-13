import 'package:flutter/material.dart';
import 'package:shree_pro/features/auth/data/services/user_api.dart';
import 'package:shree_pro/features/auth/domain/models/user.dart';


class UserDetailPage extends StatefulWidget {
  final String username;
  const UserDetailPage({super.key, required this.username});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Detail")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user != null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: ${user!.firstName} ${user!.lastName}"),
                      Text("Username: ${user!.username}"),
                      Text("Email: ${user!.email}"),
                      Text("Phone: ${user!.phone}"),
                      Text("Role: ${user!.roleName}"),
                      const SizedBox(height: 12),
                      const Text("Permissions:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...user!.permissions.map(
                        (perm) => Text("- ${perm.name} (${perm.description})"),
                      )
                    ],
                  ),
                )
              : const Center(child: Text("User not found")),
    );
  }
}
