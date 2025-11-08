import 'package:gsc_project/colors/app_colors.dart';
import 'package:gsc_project/pages/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  final countryCodeController = TextEditingController();
  final emailController = TextEditingController();
  final emergencyContactController = TextEditingController();
  final caretakerEmail = TextEditingController();
  String? selectedGender;

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    phoneController.dispose();
    countryCodeController.dispose();
    emailController.dispose();
    emergencyContactController.dispose();
    caretakerEmail.dispose();
    super.dispose();
  }

  Future<void> saveUserData(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final url = Uri.parse(
      "https://zindagigo-1gr2.onrender.com/api/users/saveUser",
    );

    final token = await user.getIdToken(); // Get Firebase token

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "name": nameController.text,
          "dob": dobController.text,
          "gender": selectedGender,
          "phone": phoneController.text,
          "email": emailController.text,
          "emergencyContact": emergencyContactController.text,
          "caretakerEmail": caretakerEmail.text,
        }),
      );
 print("Status Code: ${response.statusCode}");
print("Response Body: ${response.body}");
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User info saved successfully")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) =>  HomePage()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: \${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save user info: \$e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.HomePageColor,
      appBar: AppBar(
        title: const Text("UserInfo"),
        backgroundColor: AppColors.pink,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Tell us about yourself",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.drawerColor,
                  border: Border.all(
                    color: AppColors.lineColor,
                    width: 1.0,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'lib/imagesOrlogo/CompleteProfile.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
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
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextFormField(
                  controller: dobController,
                  decoration: InputDecoration(
                    labelText: "D.O.B (dd/mm/yyyy)",
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
                      return 'Please enter your date of birth';
                    }
                    final dobRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
                    if (!dobRegex.hasMatch(value)) {
                      return 'Please enter a valid date of birth (dd/mm/yyyy)';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: InputDecoration(
                    labelText: "Gender",
                    labelStyle: TextStyle(color: AppColors.InputInfo),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.lineColor, width: 3.0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                    ),
                  ),
                  items:
                      <String>['Male', 'Female', 'Other'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGender = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: countryCodeController,
                        decoration: InputDecoration(
                          labelText: "Country Code",
                          labelStyle: TextStyle(color: AppColors.InputInfo),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.lineColor, width: 3.0),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.pink, width: 3.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your country code';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          labelStyle: TextStyle(color: AppColors.InputInfo),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.lineColor, width: 3.0),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length != 10) {
                            return 'Phone number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
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
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextFormField(
                  controller: emergencyContactController,
                  decoration: InputDecoration(
                    labelText: "Emergency Contact",
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
                      return 'Please enter an emergency contact';
                    }
                    if (value.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextFormField(
                  controller: caretakerEmail,
                  decoration: InputDecoration(
                    labelText: "Email Of Caretaker",
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
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    saveUserData(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lineColor,
                  iconColor: AppColors.pink,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 150, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Verify",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// =======
// import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
// import 'package:gsc_project/colors/app_colors.dart';
// import 'package:gsc_project/pages/home_page.dart';
// import 'package:http/http.dart' as http;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:convert';

// class UserInfoPage extends StatefulWidget {
//   const UserInfoPage({super.key});

//   @override
//   State<UserInfoPage> createState() => _UserInfoPageState();
// }

// class _UserInfoPageState extends State<UserInfoPage> {
//   final formKey = GlobalKey<FormState>();
//   final nameController = TextEditingController();
//   final dobController = TextEditingController();
//   final phoneController = TextEditingController();
//   final countryCodeController = TextEditingController();
//   final emailController = TextEditingController();
//   final emergencyContactController = TextEditingController();
//   final caretakerEmail = TextEditingController();
//   String? selectedGender;

//   @override
//   void dispose() {
//     nameController.dispose();
//     dobController.dispose();
//     phoneController.dispose();
//     countryCodeController.dispose();
//     emailController.dispose();
//     emergencyContactController.dispose();
//     caretakerEmail.dispose();
//     super.dispose();
//   }

//   Future<void> saveUserData(BuildContext context) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("User not logged in")),
//       );
//       return;
//     }

//     final url = Uri.parse(
//       "https://zindagigo.onrender.com/api/users/saveUser",
//     );

//     final token = await user.getIdToken(); // Get Firebase token

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "token": token,
//           "name": nameController.text,
//           "dob": dobController.text,
//           "gender": selectedGender,
//           "phone": phoneController.text,
//           "email": emailController.text,
//           "emergencyContact": emergencyContactController.text,
//           "caretakerEmail": caretakerEmail.text,
//         }),
//       );

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("User info saved successfully")),
//         );
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const HomePage()),
//           (Route<dynamic> route) => false,
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error: ${response.body}")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to save user info: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.HomePageColor,
//       appBar: AppBar(
//         title: const Text("UserInfo"),
//         backgroundColor: AppColors.pink,
//       ),
//       body: SingleChildScrollView(
//         child: Form(
//           key: formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),
//               const Text(
//                 "Tell us about yourself",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: AppColors.drawerColor,
//                   border: Border.all(
//                     color: AppColors.lineColor,
//                     width: 1.0,
//                   ),
//                 ),
//                 child: ClipOval(
//                   child: Image.asset(
//                     'lib/imagesOrlogo/CompleteProfile.png',
//                     width: 50,
//                     height: 50,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                 child: TextFormField(
//                   controller: nameController,
//                   decoration: InputDecoration(
//                     labelText: "Name",
//                     labelStyle: TextStyle(color: AppColors.InputInfo),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide:
//                           BorderSide(color: AppColors.lineColor, width: 3.0),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: AppColors.pink, width: 3.0),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your name';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                 child: TextFormField(
//                   controller: dobController,
//                   decoration: InputDecoration(
//                     labelText: "D.O.B (dd/mm/yyyy)",
//                     labelStyle: TextStyle(color: AppColors.InputInfo),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide:
//                           BorderSide(color: AppColors.lineColor, width: 3.0),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: AppColors.pink, width: 3.0),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your date of birth';
//                     }
//                     final dobRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
//                     if (!dobRegex.hasMatch(value)) {
//                       return 'Please enter a valid date of birth (dd/mm/yyyy)';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                 child: DropdownButtonFormField<String>(
//                   value: selectedGender,
//                   decoration: InputDecoration(
//                     labelText: "Gender",
//                     labelStyle: TextStyle(color: AppColors.InputInfo),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide:
//                           BorderSide(color: AppColors.lineColor, width: 3.0),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: AppColors.pink, width: 3.0),
//                     ),
//                   ),
//                   items:
//                       <String>['Male', 'Female', 'Other'].map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       selectedGender = newValue;
//                     });
//                   },
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select your gender';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       flex: 2,
//                       child: TextFormField(
//                         controller: countryCodeController,
//                         decoration: InputDecoration(
//                           labelText: "Country Code",
//                           labelStyle: TextStyle(color: AppColors.InputInfo),
//                           enabledBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(
//                                 color: AppColors.lineColor, width: 3.0),
//                           ),
//                           focusedBorder: UnderlineInputBorder(
//                             borderSide:
//                                 BorderSide(color: AppColors.pink, width: 3.0),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your country code';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       flex: 5,
//                       child: TextFormField(
//                         controller: phoneController,
//                         decoration: InputDecoration(
//                           labelText: "Phone Number",
//                           labelStyle: TextStyle(color: AppColors.InputInfo),
//                           enabledBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(
//                                 color: AppColors.lineColor, width: 3.0),
//                           ),
//                           focusedBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: AppColors.pink, width: 3.0),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your phone number';
//                           }
//                           if (value.length != 10) {
//                             return 'Phone number must be 10 digits';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                 child: TextFormField(
//                   controller: emailController,
//                   decoration: InputDecoration(
//                     labelText: "Email",
//                     labelStyle: TextStyle(color: AppColors.InputInfo),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide:
//                       BorderSide(color: AppColors.lineColor, width: 3.0),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: AppColors.pink, width: 3.0),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//                     if (!emailRegex.hasMatch(value)) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                 child: TextFormField(
//                   controller: emergencyContactController,
//                   decoration: InputDecoration(
//                     labelText: "Emergency Contact",
//                     labelStyle: TextStyle(color: AppColors.InputInfo),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide:
//                           BorderSide(color: AppColors.lineColor, width: 3.0),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: AppColors.pink, width: 3.0),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter an emergency contact';
//                     }
//                     if (value.length != 10) {
//                       return 'Phone number must be 10 digits';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               const SizedBox(height: 40),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                 child: TextFormField(
//                   controller: caretakerEmail,
//                   decoration: InputDecoration(
//                     labelText: "Email Of Caretaker",
//                     labelStyle: TextStyle(color: AppColors.InputInfo),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide:
//                       BorderSide(color: AppColors.lineColor, width: 3.0),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: AppColors.pink, width: 3.0),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//                     if (!emailRegex.hasMatch(value)) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               const SizedBox(height: 40),
//               ElevatedButton(
//                 onPressed: () {
//                   if (formKey.currentState!.validate()) {
//                     saveUserData(context);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.lineColor,
//                   iconColor: AppColors.pink,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 150, vertical: 10),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 child: const Text(
//                   "Verify",
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
