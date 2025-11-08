import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class YogaPage extends StatefulWidget {
  const YogaPage({super.key});

  @override
  State<YogaPage> createState() => _YogaPageState();
}

class _YogaPageState extends State<YogaPage> {
  List<dynamic> yoga = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchYoga();
  }

  Future<void> fetchYoga() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Not logged in");

      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse("https://zindagigo-1gr2.onrender.com/api/fitness/recommendYoga"),
        headers: {
          'Authorization': 'Bearer $token',
           'Content-Type': 'application/json',
        },
      );

      final json = jsonDecode(response.body);

      if (json['success']) {
        if (!mounted) return; 
        setState(() {
          yoga = json['data'];
          errorMessage = '';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = json['message'] ?? "Failed to get yoga recommendations";
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return; 
      debugPrint("Error fetching yoga recommendations: $e");
      setState(() {
        errorMessage = "Failed to get yoga recommendation: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  void openVideo(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open video")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recommended Yoga")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: yoga.length,
                  itemBuilder: (context, index) {
                    final item = yoga[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 20),
                      elevation: 5,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['yoga'] ?? 'Yoga',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text("⏱ Duration: ${item['duration']} min"),
                            const SizedBox(height: 4),
                            Text("🎯 Purpose: ${item['purpose']}"),
                            const SizedBox(height: 4),
                            Text("⚠️ Caution: ${item['caution']}"),
                            const SizedBox(height: 10),
                            if (item['video'] != null && item['video'].toString().isNotEmpty)
                              ElevatedButton.icon(
                                onPressed: () => openVideo(item['video']),
                                icon: const Icon(Icons.play_circle_fill),
                                label: const Text("Watch Video"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
