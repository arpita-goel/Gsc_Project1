import 'package:flutter/material.dart';
import 'package:gsc_project/colors/app_colors.dart';
import 'package:gsc_project/pages/chat_page.dart';
import 'package:gsc_project/pages/welcome_page.dart';
import 'package:gsc_project/services/auth_service.dart';

class HomepageCaretaker extends StatefulWidget {
  final String firebaseUID;
  final String token;

  const HomepageCaretaker(
      {required this.firebaseUID, required this.token, super.key});

  @override
  HomepageCaretakerState createState() => HomepageCaretakerState();
}

class HomepageCaretakerState extends State<HomepageCaretaker> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushNamed(context, '/settingspage');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/reminderpage');
    }
  }

  void logout(BuildContext context) async {
    await AuthService().signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => WelcomePage()));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    //final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: AppColors.HomePageColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.12),
        child: Center(
          child: Container(
            width: screenWidth * 0.9,
            height: screenHeight * 0.08,
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
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: Image.asset(
                          'lib/imagesOrlogo/Drawer.png',
                          width: screenWidth * 0.12,
                          height: screenHeight * 0.03,
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
                      width: screenWidth * 0.12,
                      height: screenHeight * 0.04,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset(
                      'lib/imagesOrlogo/Notification.png',
                      width: screenWidth * 0.12,
                      height: screenHeight * 0.04,
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            _buildCardButton(
                screenWidth,
                screenHeight,
                'Medical Records',
                'lib/imagesOrlogo/MedicalRecords.png',
                () => Navigator.pushNamed(
                      context,
                      '/MedicalRecords',
                      arguments: {
                        'firebaseUID': widget.firebaseUID, 
                      },
                    ),
                const Color(0xFFFFFDFE),
                const Color(0xFFD4859E)),
            SizedBox(height: screenHeight * 0.02),
            _buildCardButton(
                screenWidth,
                screenHeight,
                'Fitness',
                'lib/imagesOrlogo/Yoga.png',
                () => Navigator.pushNamed(context, '/fitnessPage'),
                const Color(0xFFFFFDFE),
                const Color(0xFFD4859E)),
            SizedBox(height: screenHeight * 0.02),
            Container(
              width: screenWidth * 0.85,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: AppColors.ReminderBox,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reminder Summary',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  SizedBox(
                    height: screenHeight * 0.25,
                    child: ListView(
                      children: [
                        _buildReminderTile('paracetamol',
                            'Sun, 16 June 4:00 pm', true, screenWidth),
                        _buildReminderTile('paracetamol lorem ipsum',
                            'Tue, 18 June 6:00 pm', false, screenWidth),
                        _buildReminderTile('paracetamol',
                            'Sun, 16 June 4:00 pm', true, screenWidth),
                        _buildReminderTile('paracetamol',
                            'Sun, 16 June 4:00 pm', true, screenWidth),
                        _buildReminderTile('paracetamol lorem ipsum',
                            'Tue, 18 June 6:00 pm', false, screenWidth),
                        _buildReminderTile('paracetamol',
                            'Sun, 16 June 4:00 pm', true, screenWidth),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: screenHeight * 0.06,
          right: screenWidth * 0.03,
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Image.asset(
            'lib/imagesOrlogo/Chatbot.png',
            width: screenWidth * 0.25,
            height: screenHeight * 0.17,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: screenHeight * 0.01),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
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
                  icon: _buildNavBarIcon(
                      'lib/imagesOrlogo/settings.png', screenWidth),
                  label: 'Settings',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavBarIcon(
                      'lib/imagesOrlogo/Reminder.png', screenWidth),
                  label: 'Reminder',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavBarIcon(
                      'lib/imagesOrlogo/Location.png', screenWidth),
                  label: 'Location',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarIcon(String imagePath, double width) {
    return Container(
      width: width * 0.15,
      height: width * 0.15,
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5F5),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD4859E), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          imagePath,
          width: width * 0.09,
          height: width * 0.09,
        ),
      ),
    );
  }

  Widget _buildCardButton(
      double width,
      double height,
      String label,
      String imagePath,
      VoidCallback onTap,
      Color bgColor,
      Color bottomBorderColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 0.85,
        height: height * 0.15,
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: const Border(
            bottom: BorderSide(width: 3, color: Color(0xFFD4859E)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(imagePath, width: width * 0.18, height: width * 0.18),
            SizedBox(width: width * 0.05),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTile(
      String medicine, String time, bool isTaken, double width) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: width * 0.015),
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: isTaken ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  isTaken ? Icons.check_circle : Icons.error,
                  color: isTaken ? Colors.green : Colors.red,
                ),
                SizedBox(width: width * 0.02),
                Expanded(
                  child: Text(
                    medicine,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: width * 0.04),
                  ),
                ),
              ],
            ),
          ),
          Text(time,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: width * 0.035)),
        ],
      ),
    );
  }
}
