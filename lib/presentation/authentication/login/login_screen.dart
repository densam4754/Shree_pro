import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shree_pro/presentation/pages/dashboard/stations/dashboard.dart';
// import 'package:shree_pro/presentation/pages/home_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:shree_pro/constants/fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AuthApi extends StatefulWidget {
  const AuthApi({super.key});

  @override
  State<AuthApi> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<AuthApi>
    with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late AnimationController _controller;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => errorMessage = "Username and password required");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final String basicAuth = 'Basic bW9iaWxlLWRldmljZTptYXV6b0BTZXJ2aWNl';

      final tokenUrl = Uri.parse("http://38.242.196.127:1816/api/oauth/token");
      final tokenResponse = await http.post(
        tokenUrl,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': basicAuth,
        },
        body: {
          "grant_type": "password",
          "username": username,
          "password": password,
        },
      );

      print("Login Status: ${tokenResponse.statusCode}");
      print("Login Body: ${tokenResponse.body}");

      if (tokenResponse.statusCode == 200) {
        final tokenData = jsonDecode(tokenResponse.body);
        final accessToken = tokenData["access_token"];

        if (accessToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("access_token", accessToken);
          await prefs.setString("username", username);

          // Navigate to HomeScreen with the logged-in username
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(username: username),
            ),
          );
        } else {
          setState(() => errorMessage = "Token not found in response");
        }
      } else {
        setState(() => errorMessage = "Invalid username or password");
      }
    } catch (e) {
      setState(() => errorMessage = "Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- Animated Gradient Background ---
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.6),
                      Colors.black.withOpacity(0.6),
                      Colors.grey.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      0.2 + 0.2 * sin(_controller.value * 2 * pi),
                      0.5,
                      0.8 + 0.2 * cos(_controller.value * 2 * pi),
                    ],
                  ),
                ),
              );
            },
          ),

          // --- Floating circles ---
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(painter: CirclePainter(_controller.value));
              },
            ),
          ),

          // --- Login UI ---

          AnimationConfiguration.staggeredList(
            position: 0,
            duration: const Duration(milliseconds: 700),
            child: SlideAnimation(
              verticalOffset: 100,
              child: FadeInAnimation(
                child:   Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Shree Pro",
                        style: AppFonts.header,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Card(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        
                           
                             const Text(
                            
                            "Welcome Back",
                            style: AppFonts.subHeaderw
                          ), 
                          
                        
                          const SizedBox(height: 5),
                          const Text(
                            "Sign in to your account to continue",
                            textAlign: TextAlign.center,
                            style:AppFonts.bodyb
                          ),
                          const SizedBox(height: 20),

                          // Username
                          TextFormField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person,color: Colors.white,),
                              hintText: "Username",
                              labelText: "Enter your username",labelStyle: AppFonts.bodyw,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Password
                          TextFormField(
                            controller: passwordController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock,color: Colors.white,),
                              labelText: "Password",labelStyle:  AppFonts.bodyw,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            obscureText: true,
                           
                          ),
                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text("Forgot Password?", style: AppFonts.bodyw,),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Sign In Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: isLoading ? null : _login,
                              child:
                                  isLoading
                                      ? Center(
                                        child: Lottie.asset(
                                          'assets/Animations/loading.json',

                                          width: 150,
                                          height: 50,
                                          repeat: true,
                                        ),
                                      )
                                      : const Text(
                                        "Sign in",
                                        style: AppFonts.subHeaderw
                                      ),
                            ),
                          ),
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          const SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don’t have an account?",style: AppFonts.body,),
                              TextButton(
                                onPressed: () {},
                                child: const Text(" contact admin",style:AppFonts.bodyb,),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
              ),
            ),
          )
        
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double value;
  CirclePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.2);

    for (int i = 0; i < 5; i++) {
      double dx = size.width * (0.2 * i + 0.2 * sin(value * 2 * pi + i));
      double dy = size.height * (0.2 * i + 0.2 * cos(value * 2 * pi + i));
      canvas.drawCircle(Offset(dx, dy), 40, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CirclePainter oldDelegate) => true;
}
