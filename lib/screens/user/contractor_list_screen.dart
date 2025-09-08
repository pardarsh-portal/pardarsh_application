import 'package:flutter/material.dart';

class ContractorListScreen extends StatelessWidget {
  const ContractorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration
    final contractors = [
      {'name': 'John Doe', 'email': 'john@example.com'},
      {'name': 'Jane Smith', 'email': 'jane@example.com'},
      {'name': 'Bob Johnson', 'email': 'bob@example.com'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Contractor List')),
      body: ListView.builder(
        itemCount: contractors.length,
        itemBuilder: (context, index) {
          final contractor = contractors[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(contractor['name']!),
            subtitle: Text(contractor['email']!),
            onTap: () {
              // TODO: Navigate to contractor detail screen if needed
            },
          );
        },
      ),
    );
  }
}
