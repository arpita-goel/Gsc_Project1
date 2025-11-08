import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final TextEditingController _placeController = TextEditingController();

  void _launchMapWithQuery() {
    String place = _placeController.text.trim();
    if (place.isNotEmpty) {
      MapsLauncher.launchQuery(place);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a place name")),
      );
    }
  }

  @override
  void dispose() {
    _placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with lavender background
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        title: const Text(
          '📍 Find Location',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE2E0F0),
      ),

      // Light pink background
      backgroundColor: const Color(0xFFFFF5F5),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Input Field
            TextField(
              controller: _placeController,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.place, color: Color(0xFF5A4087)),
                hintText: 'Type a place name...',
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF5A4087), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Button with new rose pink color
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _launchMapWithQuery,
                icon: const Icon(Icons.map, color: Color(0xFF5A4087)),
                label: const Text("Open in Maps", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFFFBDC8),// 🌸 New button color
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
