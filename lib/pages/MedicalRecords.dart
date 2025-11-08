import 'package:flutter/material.dart';
import 'package:gsc_project/colors/app_colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'CategoryRecordsPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MedicalRecords(),
    );
  }
}

class MedicalRecords extends StatefulWidget {
  //  final String firebaseUID;
  const MedicalRecords({super.key});

  @override
  MedicalRecordsState createState() => MedicalRecordsState();
}

class MedicalRecordsState extends State<MedicalRecords> {
  bool _isUploading = false;

  late String elderlyUID;
  bool isLoading = true;

@override
  void initState() {
    super.initState();
    // initializeUID();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && args['firebaseUID'] != null) {
      elderlyUID = args['firebaseUID'];
      print("📦 UID from arguments: $elderlyUID");
    } else {
      final user = FirebaseAuth.instance.currentUser;
      elderlyUID = user?.uid ?? '';
      print("🔐 Defaulting to current user's UID: $elderlyUID");
    }

    setState(() {
      isLoading = false;
    });
  });



  }

  Future<void> pickExtractAndUpload() async {
    try {
      setState(() => _isUploading = true);

      // Step 1: Pick Image
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80,);
      if (pickedFile == null) {
        setState(() => _isUploading = false);
        return;
      }
      final imageFile = File(pickedFile.path);
      print("Picked file: ${pickedFile.path}");  // 👈 See if it's really .png

      // Step 2: Extract Text using ML Kit
      final inputImage = InputImage.fromFilePath(pickedFile.path);
     final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      final extractedText = recognizedText.text;
      await textRecognizer.close();

      // Step 3: Upload to backend
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      // final firebaseUID = user?.uid ?? '';
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://zindagigo-1gr2.onrender.com/api/medical-records/upload"),
       
          //in the place of 10.10.226.179   give your ipconfig(run ipconfig in cmd and copy ipv4 ) if you want to run this on real device
        // 10.0.2.2  this is for emulator
        // also remember that your pc and device must be connected with same wifi
        // Use localhost for emulator
        // Replace with your server URL
      )
        ..headers['Authorization'] = 'Bearer $idToken'
        ..fields['firebaseUID'] = elderlyUID
        ..fields['title'] = "Uploaded Record"
        ..fields['processedText'] = extractedText
        ..fields['fileType'] = 'image'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      setState(() => _isUploading = false);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Upload successful")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Upload failed")));
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
  // Future<void> initializeUID() async {
  //   if (widget.firebaseUID.isNotEmpty) {
  //     // Coming from caretaker → use the passed firebaseUID
  //     elderlyUID = widget.firebaseUID;
  //     print("👴 Using elderlyUID passed from login: $elderlyUID");
  //   } else {
  //     // Coming from elderly → use FirebaseAuth to get their UID
  //     final user = FirebaseAuth.instance.currentUser;
  //     elderlyUID = user?.uid ?? '';
  //     print("🔐 Defaulting to current user's UID: $elderlyUID");
  //   }

  //   setState(() {
  //     isLoading = false;
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Center(
          child: Container(
            width: screenWidth * 0.9,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.navBarColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: Image.asset(
                          'lib/imagesOrlogo/Drawer.png',
                          width: 50,
                          height: 23,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: const Text(
                    "Medical Records",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: AppColors.drawerColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            DrawerHeader(
              //decoration: BoxDecoration(color: AppColors.drawerColor),
              decoration: BoxDecoration(
                color: AppColors.drawerColor, // Make sure it blends with the drawer background
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.favorite,
                      color: AppColors.pink,
                      size: 50,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "HELLO USER!!",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  // IconButton(
                  //   icon: const Icon(Icons.close),
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.searchBar, // Background color
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "search...",
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Menu Items
            ListTile(
              leading: Image.asset(
                'lib/imagesOrlogo/home2.png',
                width: 30,
                height: 27,
              ),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Image.asset(
                'lib/imagesOrlogo/settings.png',
                width: 27,
                height: 27,
              ),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pushNamed(context, '/settingspage');
              },
            ),
            ListTile(
              leading: Image.asset(
                'lib/imagesOrlogo/Notification.png',
                width: 31,
                height: 32,
              ),
              title: const Text("Notifications"),
              onTap: () {
                Navigator.pushNamed(context, '/notificationpage');
              },
            ),
            ListTile(
              leading: Image.asset(
                'lib/imagesOrlogo/phone.png',
                width: 31,
                height: 32,
              ),
              title: const Text("Help Numbers"),
              onTap: () {
                Navigator.pushNamed(context, '/helpNumbers');
              },
            ),            
            ListTile(
              leading: Image.asset(
                'lib/imagesOrlogo/profile.png',
                width: 25,
                height: 26,
              ),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pushNamed(context, '/profilepage');
              },
            ),
            ListTile(
              leading: Image.asset(
                'lib/imagesOrlogo/Logout.png',
                width: 35,
                height: 36,
              ),
              title: const Text("Logout"),
              onTap: () {
                // logout(context);
              },
            ),

            const Spacer(),

            // Light & Dark Mode Toggle
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Light mode action
                    },
                    icon: const Icon(Icons.light_mode, color: Colors.black),
                    label: const Text("Light"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.searchBar,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Dark mode action
                    },
                    icon: const Icon(Icons.dark_mode, color: Colors.white),
                    label: const Text("Dark"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 16),
          child: Column(
            children: [
              _buildUserCard(),
              const SizedBox(height: 16),
              _buildUploadButton(),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final List<Map<String, dynamic>> gridItems = [
                        {"title": "Allergies", "icon": Icons.medical_services},
                        {"title": "Prescriptions", "icon": Icons.receipt},
                        {"title": "Medical History", "icon": Icons.history},
                        {"title": "Hospitalization", "icon": Icons.local_hospital},
                        {"title": "Vaccinations", "icon": Icons.vaccines},
                        {"title": "Procedures", "icon": Icons.medical_services},
                        {"title": "Test Reports", "icon": Icons.report},
                        {"title": "Dr.'s Contacts", "icon": Icons.contact_phone},
                      ];
                      final item = gridItems[index];
                      return _buildGridButton(item["title"], item["icon"]);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.navBarColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 40, backgroundImage: AssetImage('lib/imagesOrlogo/CompleteProfile.png')),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("S. K. Dogra", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("Gender: Male    Age: 80", style: TextStyle(fontSize: 15)),
              Text("Weight: 72 Kg", style: TextStyle(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: _isUploading ? null : pickExtractAndUpload,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.Upload,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Upload", style: TextStyle(fontSize: 20, color: Colors.black)),
            const SizedBox(width: 10),
            Image.asset('lib/imagesOrlogo/Upload.png', height: 24, width: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGridButton(String title, IconData icon) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryRecordsPage(category: title,
                                                  firebaseUID:elderlyUID),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.pink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(16),
        elevation: 5,
        shadowColor: Colors.black12,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.black),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }
}
