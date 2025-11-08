import 'dart:convert';
// import 'package:gsc_project/pages/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gsc_project/main.dart';
import 'package:gsc_project/pages/homePageCareTaker.dart';
import 'package:gsc_project/colors/app_colors.dart';
import 'package:gsc_project/pages/login_by_phoneno.dart';
// import '../services/mongo_service.dart';
// import '../services/auth_service.dart';
// import 'userInfo.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class LoginPageCaretaker extends StatefulWidget {
  const LoginPageCaretaker({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPageCaretaker> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  Future<void> loginWithEmail() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String? token = await userCredential.user!.getIdToken();
        print("Token from Firebase: $token");
      final response = await http.post(
        Uri.parse("https://zindagigo-1gr2.onrender.com/api/users/login"),
        body: jsonEncode({
          "token": token,
        }),
        headers: {'Content-Type': 'application/json'},
      );
   print("Login API status code: ${response.statusCode}");
    print("Login API body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        try {
  
  print("Login response: $data");
} catch (e) {
  print("Error decoding login response: $e");
  print("Raw body: ${response.body}");
}
        String role = data['role'];
        // String userId = data['userId'];

        if (role == 'caretaker') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => HomepageCaretaker(
                      firebaseUID: data['elderlyUID'],
                      token: token?.toString() ?? '',
                    )),
            (route) => false,
          );
        }
        // } else if (role == 'elderly') {
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => HomePage(userId: userId),
        //     ),
        //   );
        // }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unknown user role')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed')),
        );
      }
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => const HomepageCaretaker()),
      //   (Route<dynamic> route) => false,
      // );
    } catch (e) {
      print("Login Error: $e");
    }
  }

  // void loginWithGoogle(BuildContext context) async {
  //   var usern = await AuthService().signInWithGoogle();
  //   if (usern?.user != null) {
  //     String email = usern!.user!.email!;
  //     bool exists = await MongoService().checkIfEmailExists(email);
  //     if (exists) {
  //       Navigator.pushReplacement(context,
  //           MaterialPageRoute(builder: (_) => const HomepageCaretaker()));
  //     } else {
  //       Navigator.pushReplacement(
  //           context, MaterialPageRoute(builder: (_) => const UserInfoPage()));
  //     }
  //   }
  // }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: AppColors.pink,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),
              Image.asset(
                'lib/imagesOrlogo/ZindagiGo_logo.png',
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
              ),
              SizedBox(height: screenHeight * 0.01),
              const Text(
                "Login",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFBDC8),
                  border: Border.all(color: const Color(0xFFD485A0), width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'CareTaker',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              const Text(
                'Please use the temporary password sent to your email(provided during the user\'s registration) to log in for the first time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  icon: Icon(Icons.email, color: AppColors.lineColor),
                  labelText: "Enter Email",
                  labelStyle: TextStyle(color: AppColors.InputInfo),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.lineColor, width: 3.0),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock, color: AppColors.lineColor),
                  labelText: "Enter Password",
                  labelStyle: TextStyle(color: AppColors.InputInfo),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.lineColor, width: 3.0),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.lineColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.03),
              ElevatedButton(
                onPressed: loginWithEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lineColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Welcome!",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              const Text(
                "Or login using...",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset("lib/imagesOrlogo/Google.png"),
                    iconSize: screenWidth * 0.03,
                    onPressed: () {
                      // loginWithGoogle(context);
                    },
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  IconButton(
                    icon: Image.asset("lib/imagesOrlogo/Gmail.png"),
                    iconSize: screenWidth * 0.03,
                    onPressed: () {},
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  IconButton(
                    icon: Image.asset("lib/imagesOrlogo/PhoneNo.png"),
                    iconSize: screenWidth * 0.03,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginByPhoneno()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
