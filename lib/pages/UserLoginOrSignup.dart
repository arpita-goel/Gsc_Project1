import 'package:flutter/material.dart';
import 'package:gsc_project/main.dart';
import 'package:gsc_project/pages/login_page.dart';
import 'package:gsc_project/pages/new_Account.dart';

void main() {
  runApp(const MyApp());
}

class UserLoginOrSignup extends StatefulWidget {
  const UserLoginOrSignup({super.key});

  @override
  _UserLoginOrSignupState createState() => _UserLoginOrSignupState();
}

class _UserLoginOrSignupState extends State<UserLoginOrSignup> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double cardWidth = size.width * 0.9; // Responsive width
    final double cardHeight = size.height * 0.3; // Responsive height

    return Scaffold(
      backgroundColor: const Color(0xFFD4859E),
      body: Center(
        child: Container(
          width: cardWidth,
          height: cardHeight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F5),
            borderRadius: BorderRadius.circular(40),
            border: const Border(
              bottom: BorderSide(
                color: Color(0xFF594087),
                width: 5,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton("Login"),
              const SizedBox(height: 20),
              _buildButton("Sign up"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return SizedBox(
      width: 180,
      height: 45,
      child: ElevatedButton(
        onPressed: () {
          if (text == "Login") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          } else if (text == "Sign up") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewAccountPage()),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF594087),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 4,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
