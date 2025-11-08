import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  List<dynamic> diet = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDiet();
  }

  Future<void> fetchDiet() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Not logged in");

      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse("https://zindagigo-1gr2.onrender.com/api/fitness/recommendDiet"),
        headers: {
          'Authorization': 'Bearer $token',
           'Content-Type': 'application/json',
        },
      );

      final json = jsonDecode(response.body);

      if (json['success']) {
        if (!mounted) return; 
        setState(() {
          diet = json['data'];
          errorMessage = '';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = json['message'] ?? "Unknown error";
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return; 
      debugPrint("Error fetching diet recommendations: $e");
      setState(() {
        errorMessage = "Failed to get diet recommendation: ${e.toString()}";
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recommended Diets")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: diet.length,
                  itemBuilder: (context, index) {
                    final item = diet[index];
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
                              item['mealType'] ?? 'Meal Type',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text("⏱ Meal Time: ${item['timeofMeal']} "),
                            const SizedBox(height: 4),
                            Text("Ingredients: ${item['items']} "),
                            const SizedBox(height: 4),
                            Text("🎯 Purpose: ${item['purpose']}"),
                            const SizedBox(height: 4),
                            Text("⚠️ Caution: ${item['caution']}"),
                            const SizedBox(height: 10),
                              Text("Note: ${item['note']}"),
                            const SizedBox(height: 4),
                            
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
