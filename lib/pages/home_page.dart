import 'package:flutter/material.dart';
import 'package:gsc_project/colors/app_colors.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gsc_project/pages/Banking.dart';
import 'package:gsc_project/pages/GroupsPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gsc_project/pages/notifications.dart';
import 'package:gsc_project/pages/Reminder.dart';
import 'package:gsc_project/pages/Zoom_page.dart';
import '../services/auth_service.dart';
import 'package:gsc_project/pages/chat_page.dart';
import 'welcome_page.dart';
import 'package:torch_light/torch_light.dart';
import 'package:gsc_project/pages/Entertainment.dart';
import 'package:gsc_project/pages/fitness.dart';
import 'package:gsc_project/pages/MedicalRecords.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:sensors_plus/sensors_plus.dart';
// import 'package:flutter_sensors/flutter_sensors.dart' as flutter_sensors;
import 'dart:async';
import 'dart:math';

class HomePage extends StatefulWidget {
  static final GlobalKey<_HomePageState> globalKey =
      GlobalKey<_HomePageState>();

  final String? payload;
  final Function(String)? onCompleteReminder;
  HomePage({Key? key, this.payload, this.onCompleteReminder})
      : super(key: globalKey);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String title = "Medicine time";
  String description = "take your medicines";
  bool _isCompleted = false;
  double threshold = 15.0; // G-force threshold for fall detection
  int inactivityTime = 5; // Time of inactivity after fall
  bool hasFallen = false;
  Timer? inactivityTimer;
  String emergencyNumber = "+91"; //your emergency number
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final MethodChannel platform = MethodChannel('com.example.gsc_project/call');
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      _startListening();
    } else if (index == 2) {
      Navigator.pushNamed(context, '/settingspage');
    } 
    else if (index == 0) {
      Navigator.pushNamed(context, '/profilepage');
    }
    
    else{
      Navigator.pushNamed(context, '/locationpage');
}
  }

  @override
  void initState() {
    super.initState();
    if (widget.payload != null) {
      updateFromPayload(widget.payload!);
    }
    _requestPermissions();
    _startFallDetection();
  }

  // Request permissions
  void _requestPermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.activityRecognition,
        Permission.sensors,
        Permission.phone,
        Permission.microphone,
        Permission.camera,
        Permission.photos,
        Permission.location,
        Permission.locationWhenInUse,
      ].request();

      if (statuses[Permission.phone]!.isDenied) {
        print("Phone call permission denied. Please enable it manually.");
      }
      if (statuses[Permission.microphone]!.isDenied) {
        print("Microphone permission denied. Voice SOS may not work.");
      }
      if (statuses[Permission.location]!.isDenied) {
        print("Location permission denied. Cannot share live location.");
      }
    } catch (e) {
      print("Permission request error: $e");
    }
  }

  void updateFromPayload(String payload) {
    final parts = payload.split('|');
    if (parts.length == 2) {
      setState(() {
        title = parts[0];
        description = parts[1];
      });
    }
  }

  // Start fall detection using accelerometer
  void _startFallDetection() async {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      double acceleration =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (acceleration < 2.0) {
        hasFallen = true;
        print("Possible fall detected!");

        // Start inactivity timer to confirm fall
        inactivityTimer = Timer(Duration(seconds: inactivityTime), () {
          if (hasFallen) {
            print("Fall confirmed! Triggering SOS...");
            _makeCall();
            hasFallen = false;
          }
        });
      } else if (acceleration > threshold) {
        hasFallen = false;
        inactivityTimer?.cancel();
      }
    });
  }

  void _startBackgroundService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onBackgroundServiceStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(),
    );

    service.startService();
  }

  // Background service function
  static void _onBackgroundServiceStart(ServiceInstance service) async {
    accelerometerEventStream().listen((event) {
      double acceleration =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (acceleration < 2.0) {
        service.invoke('fallDetected', {"message": "Fall detected!"});
      }
    });
  }

// Start listening for voice commands
  void _startListening() async {
    try {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          String command = result.recognizedWords.toLowerCase();
          print("Recognized: $command"); // Debugging

          if (command.contains("help")) {
            _speech.stop(); // Stop listening after detecting the keyword
            _makeCall();
          }
        });
      } else {
        print("Speech recognition not available");
      }
    } catch (e) {
      print("Speech recognition error: $e");
    }
  }

  void _makeCall() async {
    try {
      print("Starting phone call...");
      await platform.invokeMethod('makeCall', {'phoneNumber': '+91'});
      print("Phone call initiated.");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("Location permission denied.");
        String fallbackMessage =
            "⚠️ Emergency! Possible fall detected.\n📍 Location unavailable (permission denied).";
        final fallbackUrl = Uri.parse(
            "https://wa.me/91?text=${Uri.encodeComponent(fallbackMessage)}");
        if (await canLaunchUrl(fallbackUrl)) {
          print("Launching fallback WhatsApp message without location...");
          bool launched = await launchUrl(fallbackUrl,
              mode: LaunchMode.externalApplication);
          print("Fallback WhatsApp launch result: \$launched");
        } else {
          print("Could not open WhatsApp.");
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double lat = position.latitude;
      double lng = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark place = placemarks[0];
      String address =
          "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      String mapUrl =
          "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
      String message =
          "⚠️ Emergency! Possible fall detected.\n📍 Location: $address\n🗺️ Map: $mapUrl";
      final whatsappUrl = Uri.parse(
          "https://wa.me/91?text=${Uri.encodeComponent(message)}");

      if (await canLaunchUrl(whatsappUrl)) {
        print("Launching WhatsApp message with location...");
        bool launched =
            await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        print("WhatsApp launch result: \$launched");
      } else {
        print("Could not open WhatsApp.");
      }
    } on PlatformException {
      print("Failed to make call: '\${e.message}'.");
    }
  }

  @override
  void dispose() {
    inactivityTimer?.cancel();
    _accelerometerSubscription?.cancel();
    if (_isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  void logout(BuildContext context) async {
    await AuthService().signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => WelcomePage()));
  }

  bool isTorchOn = false;

  Future<void> toggleTorch() async {
    try {
      if (isTorchOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        isTorchOn = !isTorchOn;
      });
    } catch (e) {
      print("Torch Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.HomePageColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Center(
          child: Container(
            width: 370,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
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
                  IconButton(
                    icon: Image.asset(
                      'lib/imagesOrlogo/Home.png',
                      width: 54,
                      height: 53,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset(
                      'lib/imagesOrlogo/Notification.png',
                      width: 49,
                      height: 55,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
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
                color: AppColors
                    .drawerColor, // Make sure it blends with the drawer background
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
                // Navigator.pushNamed(context, '/home');
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
                logout(context);
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Container(
                    width: 350,
                    height: 145,
                    decoration: BoxDecoration(
                      color: AppColors.ReminderBox,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Main Column for Text and Icons
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 180,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF5F5),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              //mainAxisSize: MainAxisSize.min, // Ensures Row doesn't take full width
                              children: [
                                // Circular pill icon container
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E0F0),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFFF5F5),
                                      width: 6,
                                    ),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'lib/imagesOrlogo/pill.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                ),

                                // Medicine name container (Attached to the pill icon)
                                Container(
                                  width: 180,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF5F5),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      description,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                    width:
                                        10), // Space between name box & check button

                                // Check button container
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isCompleted = !_isCompleted;
                                    });
                                    final id = NotificationService
                                        .tappedNotificationId;
                                    if (id != null) {
                                      NotificationService.cancelNotification(
                                          id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Task Completed')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('No More Tasks')),
                                      );
                                    }

                                    widget.onCompleteReminder?.call(title);
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E0F0),
                                      shape: BoxShape.circle,
                                      // border: Border.all(
                                      //   color: const Color(0xFFFFF5F5),
                                      //   width: 6,
                                      // ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.check_circle,
                                        color: _isCompleted
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                        // Good job text
                        if (_isCompleted)
                          Positioned(
                            bottom: 10,
                            child: const Text(
                              "Good job!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MedicalRecords()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF5F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 4,
                        ),
                        child: Container(
                          width: 100,
                          height: 120,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFD4859E),
                                width: 4,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'lib/imagesOrlogo/MedicalRecords.png',
                                height: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Medical Records",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FitnessPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF5F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 4,
                        ),
                        child: Container(
                          width: 100,
                          height: 120,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFD4859E),
                                width: 4,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'lib/imagesOrlogo/Yoga.png',
                                height: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Fitness",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const EntertainmentPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF5F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 4,
                        ),
                        child: Container(
                          width: 100,
                          height: 120,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFD4859E),
                                width: 4,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'lib/imagesOrlogo/YT.png',
                                height: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Fun Activities",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFD4C3D4),
                              width: 4,
                            ),
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            toggleTorch();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFF5F5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: EdgeInsets.zero,
                            elevation: 4,
                          ),
                          child: SizedBox(
                            width: 150,
                            height: 50,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'lib/imagesOrlogo/Torch.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Torch",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFD4C3D4),
                              width: 4,
                            ),
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ZoomPage()),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                                    (states) {
                              if (states.contains(WidgetState.pressed)) {
                                return Color(
                                    0xFFD4C3D4); // Change color when pressed
                              } else if (states.contains(WidgetState.hovered)) {
                                return Color(
                                    0xFFD4C3D4); // Change color when hovered
                              }
                              return Color(0xFFFFF5F5); // Default color
                            }),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            elevation: WidgetStateProperty.resolveWith<double>(
                                (states) {
                              if (states.contains(WidgetState.pressed)) {
                                return 2; // Reduce elevation on press
                              }
                              return 4; // Default elevation
                            }),
                            padding: WidgetStateProperty.all(EdgeInsets.zero),
                          ),
                          child: SizedBox(
                            width: 150,
                            height: 50,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'lib/imagesOrlogo/Zoom.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Zoom",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFD4C3D4),
                              width: 4,
                            ),
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () 
                          
                          {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ChatGroupsPage()),
                          );
                        },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFF5F5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: EdgeInsets.zero,
                            elevation: 4,
                          ),
                          child: SizedBox(
                            width: 150,
                            height: 50,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'lib/imagesOrlogo/Community.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Community",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFD4C3D4),
                              width: 4,
                            ),
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {

                              Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const BankingInfoPage()),
                          );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFF5F5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: EdgeInsets.zero,
                            elevation: 4,
                          ),
                          child: SizedBox(
                            width: 150,
                            height: 50,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'lib/imagesOrlogo/Bank.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Banking",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
          // Place the chatbot button above everything else using a Stack
          Stack(
            children: [
              Positioned(
                bottom: 30,
                right: 20,
                child: SizedBox(
                  width: 76,
                  height: 66.503,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatPage()),
                      );
                    },
                    icon: Image.asset(
                      'lib/imagesOrlogo/Chatbot.png',
                      fit: BoxFit.contain,
                    ),
                    iconSize: 76,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 76,
                      minHeight: 66.503,
                      maxWidth: 76,
                      maxHeight: 66.503,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E0F0),
                  borderRadius: BorderRadius.circular(40),
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFF2D2D2D), width: 1),
                  ),
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.black,
                  unselectedItemColor: Colors.grey,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  items: [
                    BottomNavigationBarItem(
                      icon: _buildNavBarIcon('lib/imagesOrlogo/profile.png'),
                      label: 'Profile',
                    ),
                    BottomNavigationBarItem(
                      icon: _buildNavBarIcon('lib/imagesOrlogo/phone.png'),
                      label: 'Phone',
                    ),
                    BottomNavigationBarItem(
                      icon: _buildNavBarIcon('lib/imagesOrlogo/settings.png'),
                      label: 'Settings',
                    ),
                    BottomNavigationBarItem(
                      icon: _buildNavBarIcon('lib/imagesOrlogo/Location.png'),
                      label: 'Location',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                ),
              ),
            ),

            // Floating Action Button (Reminder)
            Positioned(
              bottom: 75,
              left: MediaQuery.of(context).size.width / 2 - 34,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Color(0xFFD4859E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                  border: Border.all(
                    color: Color(0xFFD4859E),
                    width: 1,
                  ),
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReminderPage()),
                    );
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Image.asset(
                    'lib/imagesOrlogo/Reminder.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarIcon(String imagePath) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Color(0xFFFDF5F5),
        shape: BoxShape.circle,
        border: Border.all(color: Color(0xFFD4859E), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          imagePath,
          width: 30,
          height: 30,
        ),
      ),
    );
  }
}
