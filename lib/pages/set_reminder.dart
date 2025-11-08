import 'package:flutter/material.dart';
import 'package:gsc_project/colors/app_colors.dart';
import 'package:gsc_project/pages/notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> saveReminderToBackend({
  required String title,
  required String description,
  required String category,
  required DateTime dateTime,
  required int snoozeDuration,
}) async {
  try {
    final response = await http.post(
      Uri.parse(
          'https://zindagigo-1gr2.onrender.com/api/reminders'), // Replace with your backend URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'category': category,
        'dateTime': dateTime.toIso8601String(),
        'snoozeDuration': snoozeDuration,
      }),
    );

    if (response.statusCode == 200) {
      print('Reminder saved successfully');
    } else {
      print('Failed to save reminder');
    }
  } catch (e) {
    print('network error while saving : $e');
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SetReminderPage(),
    );
  }
}

class SetReminderPage extends StatefulWidget {
  const SetReminderPage({super.key});

  @override
  _SetReminderPageState createState() => _SetReminderPageState();
}

class _SetReminderPageState extends State<SetReminderPage> {
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Medicines';
  DateTime _selectedDate = DateTime.now();
  String _selectedDuration = 'Everyday';
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _snoozeDuration = 5;
    @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
                    "Set Reminder",
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
      // drawer: Drawer(
      //   backgroundColor: AppColors.drawerColor,
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       // Drawer Header
      //       DrawerHeader(
      //         //decoration: BoxDecoration(color: AppColors.drawerColor),
      //         decoration: BoxDecoration(
      //           color: AppColors.drawerColor, // Make sure it blends with the drawer background
      //         ),
      //         child: Row(
      //           children: [
      //             SizedBox(
      //               width: 40,
      //               height: 40,
      //               child: const Icon(
      //                 Icons.favorite,
      //                 color: AppColors.pink,
      //                 size: 50,
      //               ),
      //             ),
      //             const SizedBox(width: 10),
      //             const Text(
      //               "HELLO USER!!",
      //               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      //             ),
      //             const Spacer(),
      //             // IconButton(
      //             //   icon: const Icon(Icons.close),
      //             //   onPressed: () {
      //             //     Navigator.pop(context);
      //             //   },
      //             // ),
      //           ],
      //         ),
      //       ),

      //       // Search Bar
      //       Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 10),
      //         child: Container(
      //           decoration: BoxDecoration(
      //             color: AppColors.searchBar, // Background color
      //             borderRadius: BorderRadius.circular(20), // Rounded corners
      //             boxShadow: const [
      //               BoxShadow(
      //                 color: Colors.black12,
      //                 blurRadius: 5,
      //                 spreadRadius: 1,
      //               ),
      //             ],
      //           ),
      //           child: TextField(
      //             decoration: InputDecoration(
      //               hintText: "search...",
      //               prefixIcon: const Icon(Icons.search, color: Colors.black),
      //               border: InputBorder.none,
      //               contentPadding: const EdgeInsets.symmetric(vertical: 10),
      //             ),
      //           ),
      //         ),
      //       ),

      //       const SizedBox(height: 10),

      //       // Menu Items
      //       ListTile(
      //         leading: Image.asset(
      //           'lib/imagesOrlogo/home2.png',
      //           width: 30,
      //           height: 27,
      //         ),
      //         title: const Text("Home"),
      //         onTap: () {
      //           Navigator.pop(context);
      //           Navigator.pushNamed(context, '/home');
      //         },
      //       ),
      //       ListTile(
      //         leading: Image.asset(
      //           'lib/imagesOrlogo/settings.png',
      //           width: 27,
      //           height: 27,
      //         ),
      //         title: const Text("Settings"),
      //         onTap: () {
      //           Navigator.pushNamed(context, '/settingspage');
      //         },
      //       ),
      //       ListTile(
      //         leading: Image.asset(
      //           'lib/imagesOrlogo/Notification.png',
      //           width: 31,
      //           height: 32,
      //         ),
      //         title: const Text("Notifications"),
      //         onTap: () {
      //           Navigator.pushNamed(context, '/notificationpage');
      //         },
      //       ),
      //       ListTile(
      //         leading: Image.asset(
      //           'lib/imagesOrlogo/phone.png',
      //           width: 31,
      //           height: 32,
      //         ),
      //         title: const Text("Help Numbers"),
      //         onTap: () {
      //           Navigator.pushNamed(context, '/helpNumbers');
      //         },
      //       ),            
      //       ListTile(
      //         leading: Image.asset(
      //           'lib/imagesOrlogo/profile.png',
      //           width: 25,
      //           height: 26,
      //         ),
      //         title: const Text("Profile"),
      //         onTap: () {
      //           Navigator.pushNamed(context, '/profilepage');
      //         },
      //       ),
      //       ListTile(
      //         leading: Image.asset(
      //           'lib/imagesOrlogo/Logout.png',
      //           width: 35,
      //           height: 36,
      //         ),
      //         title: const Text("Logout"),
      //         onTap: () {
      //           // logout(context);
      //         },
      //       ),

      //       const Spacer(),

      //       // Light & Dark Mode Toggle
      //       Padding(
      //         padding: const EdgeInsets.all(10),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             ElevatedButton.icon(
      //               onPressed: () {
      //                 // Light mode action
      //               },
      //               icon: const Icon(Icons.light_mode, color: Colors.black),
      //               label: const Text("Light"),
      //               style: ElevatedButton.styleFrom(
      //                 backgroundColor: AppColors.searchBar,
      //                 foregroundColor: Colors.black,
      //                 shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(20),
      //                 ),
      //               ),
      //             ),
      //             const SizedBox(width: 10),
      //             ElevatedButton.icon(
      //               onPressed: () {
      //                 // Dark mode action
      //               },
      //               icon: const Icon(Icons.dark_mode, color: Colors.white),
      //               label: const Text("Dark"),
      //               style: ElevatedButton.styleFrom(
      //                 backgroundColor: Colors.black,
      //                 foregroundColor: Colors.white,
      //                 shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(20),
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  icon: const Icon(Icons.title, color: AppColors.lineColor),
                  labelText: "Add title",
                  labelStyle: const TextStyle(color: Colors.black54),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.lineColor, width: 2.0),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.lineColor, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Image.asset(
                    'lib/imagesOrlogo/description.png',
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.navBarColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: "Enter description",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Image.asset(
                    'lib/imagesOrlogo/category.png',
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Category",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.navBarColor,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: ['Medicines', 'Work', 'Personal', 'Others']
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(category),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Image.asset(
                    'lib/imagesOrlogo/calendar.png',
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Date",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.navBarColor,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Text(
                        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Image.asset(
                    'lib/imagesOrlogo/duration.png',
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Duration",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.navBarColor,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedDuration,
                    items: ['Everyday', 'Weekdays', 'Weekends']
                        .map((duration) => DropdownMenuItem(
                              value: duration,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(duration),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDuration = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Image.asset(
                    'lib/imagesOrlogo/alarm.png',
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Time",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedTime = pickedTime;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.navBarColor,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Text(
                        _selectedTime.format(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Image.asset(
                    'lib/imagesOrlogo/Snooze.png',
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Snooze",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.navBarColor,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_snoozeDuration > 1) _snoozeDuration--;
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text("$_snoozeDuration mins"),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _snoozeDuration++;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    DateTime reminderDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    );

                    // Create a new reminder object
                    Map<String, dynamic> newReminder = {
                      "title": _titleController.text,
                      "description": _descriptionController.text,
                      "category": _selectedCategory,
                      "dateTime": DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      ).toIso8601String(),
                      "snoozeDuration": _snoozeDuration,
                      "isActive": true,
                    };

                    // Save reminder to backend
                    await saveReminderToBackend(
                      title: newReminder["title"],
                      description: newReminder["description"],
                      category: newReminder["category"],
                      dateTime: reminderDateTime,
                      snoozeDuration: newReminder["snoozeDuration"],
                    );

                    // Schedule local notification
                    await NotificationService.scheduleNotification(
                      id: DateTime.now().millisecondsSinceEpoch ~/
                          1000, // Unique ID
                      title: newReminder["title"],
                      body: newReminder["description"],
                      scheduledTime: reminderDateTime,
                      snoozeDuration: newReminder["snoozeDuration"],
                    );

                    // Pass the new reminder back to the previous screen
                    Navigator.pop(context, newReminder);

                    print("Reminder set successfully!");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ButtonColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Add Reminder",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                'lib/imagesOrlogo/UserInfoImg.png',
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
