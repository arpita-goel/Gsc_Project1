import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gsc_project/colors/app_colors.dart';
import 'package:gsc_project/main.dart';
import 'package:gsc_project/pages/diet_page.dart';
import 'package:gsc_project/pages/exercise_page.dart';
import 'package:gsc_project/pages/graphs_page.dart';
import 'package:gsc_project/pages/yoga_page.dart';
import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'dart:io';

void main() {
  runApp(const MyApp());
}

class FitnessPage extends StatefulWidget {
  const FitnessPage({super.key});
  @override
  State<FitnessPage> createState() => _FitnessPageState();
}

class _FitnessPageState extends State<FitnessPage> {
  int todaySteps = 0;
  int todayCalories = 0;
  String todayDistance = '0.00';

  final health = Health();

  Future<Map<String, List<HealthDataPoint>>> fetchLast30DaysHealthData() async {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: 30));

    final types = <HealthDataType>[
      HealthDataType.WEIGHT,
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_GLUCOSE,
    ];

    final permissions = types.map((e) => HealthDataAccess.READ).toList();
    await health.requestAuthorization(types, permissions: permissions);
    final data = await health.getHealthDataFromTypes(
      types: types,
      startTime: from,
      endTime: now,
    );

    // group by type
    return {
      "weight": data.where((e) => e.type == HealthDataType.WEIGHT).toList(),
      "heart_rate":
          data.where((e) => e.type == HealthDataType.HEART_RATE).toList(),
      "blood_pressure": data
          .where((e) => e.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC)
          .toList(),
      "glucose":
          data.where((e) => e.type == HealthDataType.BLOOD_GLUCOSE).toList(),
    };
  }

  double _extractNumericValue(dynamic value) {
    if (value is num) return value.toDouble();

    // Try to extract number from string like: "NumericHealthValue - numericValue: 21"
    final str = value.toString();
    final match = RegExp(r'numericValue:\s*([\d.]+)').firstMatch(str);
    return match != null ? double.tryParse(match.group(1)!) ?? 0.0 : 0.0;
  }

  Future<Map<String, dynamic>> getTodayFitnessData() async {
    final now = DateTime.now().toLocal();
    final midnight = DateTime(now.year, now.month, now.day);

    final types = <HealthDataType>[
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.DISTANCE_DELTA,
    ];

    try {
      final permissions = types.map((type) => HealthDataAccess.READ).toList();
      final bool isAuthorized =
          await health.requestAuthorization(types, permissions: permissions);

      if (!isAuthorized) {
        throw Exception("Permission not granted to access health data.");
      }

      final List<HealthDataPoint> healthData =
          await health.getHealthDataFromTypes(
        types: types,
        startTime: midnight,
        endTime: now,
      );
      print("Fetching from $midnight to $now");

      double steps = 0.0, calories = 0.0, distance = 0.0;

      for (var point in healthData) {
        // print("→ ${point.type}: ${point.value} from ${point.dateFrom} to ${point.dateTo}");
        double value = _extractNumericValue(point.value);
        print("Parsed ${point.type}: $value");
        switch (point.type) {
          case HealthDataType.STEPS:
            steps += value;
            break;
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            calories += value;
            break;
          case HealthDataType.DISTANCE_DELTA:
            distance += value;
            break;
          default:
            break;
        }
      }

      return {
        'steps': steps.toInt(),
        'calories': calories.toInt(),
        'distanceKm': (distance / 1000).toStringAsFixed(2),
      };
    } catch (e) {
      debugPrint("Health Data Error: $e");
      return {
        'steps': 0,
        'calories': 0,
        'distanceKm': '0.00',
        'error': e.toString(),
      };
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // await health.configure();
      // final firebaseToken = await FirebaseAuth.instance.currentUser!.getIdToken();
      final todayData = await getTodayFitnessData();
      // await logFitnessDataToBackend(firebaseToken!, todayData);

      setState(() {
        todaySteps = todayData['steps'];
        todayCalories = todayData['calories'];
        todayDistance = todayData['distanceKm'];
        // todaySteps = 1234;
        // todayCalories = 123;
        // todayDistance = '121.00';
      });
    } catch (e) {
      print("Error loading fitness data: $e");
    }
  }

  Future<void> logFitnessDataToBackend(
      String token, Map<String, dynamic> fitnessData) async {
    final response = await http.post(
      Uri.parse('https://zindagigo-1gr2.onrender.com/api/fitness/log'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'date': DateTime.now().toIso8601String().split('T')[0],
        'steps': fitnessData['steps'],
        'distanceKm': fitnessData['distanceKm'],
        'sleepHours': 0, // Optional or can be manually added
        'exercises': [],
        'notes': '',
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: Text(
                    "Fitness",
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
              decoration: BoxDecoration(
                color: AppColors.drawerColor,
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
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.searchBar,
                  borderRadius: BorderRadius.circular(20),
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
                //logout(context);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stats Card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFE2E0F0),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_walk, color: Color(0xFF37775D)),
                        SizedBox(width: 8),
                        Text('$todaySteps steps',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer, color: Color(0xFF594087)),
                        SizedBox(width: 8),
                        Text('$todayDistance km',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            color: Color(0xFFD4859E)),
                        SizedBox(width: 8),
                        Text('$todayCalories kcal',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final start = now.subtract(Duration(days: 6));
// final start = DateTime(now.year, now.month, now.day);
// final end = DateTime(now.year, now.month, now.day + 1);
                        print("Fetching from $start to $now");
                        final types = <HealthDataType>[
                          HealthDataType.STEPS,
                          HealthDataType.ACTIVE_ENERGY_BURNED,
                          HealthDataType.DISTANCE_DELTA,
                        ];
                        final permissions =
                            types.map((e) => HealthDataAccess.READ).toList();
                        final health = Health();
                        final authorized = await health.requestAuthorization(
                            types,
                            permissions: permissions);

                        if (!authorized) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text("Health permissions not granted")),
                          );
                          return;
                        }

                        final data = await health.getHealthDataFromTypes(
                          types: types,
                          startTime: start,
                          endTime: now,
                        );
                        for (var point in data) {
                          print(
                              "✅ ${point.type} → ${point.value} at ${point.dateFrom}");
                        }
                        Map<String, List<HealthDataPoint>> grouped = {
                          "steps": data
                              .where((d) => d.type == HealthDataType.STEPS)
                              .toList(),
                          "distance": data
                              .where((d) =>
                                  d.type == HealthDataType.DISTANCE_DELTA)
                              .toList(),
                          "calories": data
                              .where((d) =>
                                  d.type == HealthDataType.ACTIVE_ENERGY_BURNED)
                              .toList(),
                        };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GraphsPage(health: grouped),
                          ),
                        );
                      },
                      child: Text("Show More Info"),
                    )
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Sleep Card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFE2E0F0),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sleep",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("8h 00m", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF594087),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "22:00 - 6:00",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFFA176C8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Record this time",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Buttons
              buildActivityButton(
                Icons.fitness_center,
                "Exercise",
                Color(0xFFD4859E),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExercisePage()),
                  );
                },
              ),
              SizedBox(height: 12),
              buildActivityButton(
                Icons.self_improvement,
                "Yoga",
                Color(0xFFD485A0),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => YogaPage()),
                  );
                },
              ),
              SizedBox(height: 12),
              buildActivityButton(
                Icons.spa,
                "Diet",
                Color(0xFFFFBDC8),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DietPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildActivityButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
