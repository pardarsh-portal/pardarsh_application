import 'package:flutter/material.dart';
import 'package:pardarsh_application/screens/user/contractor_list_screen.dart';
import 'project_list_screen.dart';
class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProjectListScreen()),
                );
              },
              child: const Text("View Projects"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContractorListScreen()),
                );
              },
              child: const Text("Browse Contractors"),
            ),
          ],
        ),
      ),
    );
  }
}
