import 'package:flutter/material.dart';
import 'package:pardarsh_application/screens/contractor/assigned_project_screen.dart';

class ContractorHomeScreen extends StatelessWidget {
  const ContractorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contractor Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AssignedProjectsScreen()),
                );
              },
              child: const Text("My Assigned Projects"),
            ),
          ],
        ),
      ),
    );
  }
}
