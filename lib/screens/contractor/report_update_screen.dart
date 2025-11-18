import 'package:flutter/material.dart';
import '../../services/report_service.dart';

class ReportUpdateScreen extends StatefulWidget {
  final String projectId;

  const ReportUpdateScreen({super.key, required this.projectId});

  @override
  State<ReportUpdateScreen> createState() => _ReportUpdateScreenState();
}

class _ReportUpdateScreenState extends State<ReportUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final weekController = TextEditingController();
  final progressController = TextEditingController();
  final completionController = TextEditingController();

  final materialsController = TextEditingController();
  final laborController = TextEditingController();
  final equipmentController = TextEditingController();
  final otherController = TextEditingController();

  bool loading = false;
  final ReportService _service = ReportService();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    final body = {
      "weekNumber": int.parse(weekController.text),
      "weekStartDate": DateTime.now().toIso8601String(),
      "expenses": {
        "materials": double.parse(materialsController.text),
        "labor": double.parse(laborController.text),
        "equipment": double.parse(equipmentController.text),
        "other": double.tryParse(otherController.text) ?? 0,
      },
      "progressDetails": progressController.text,
      "completionPercentage": int.parse(completionController.text),
    };

    try {
      await _service.submitReport(widget.projectId, body);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report submitted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Report")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: weekController,
                decoration: const InputDecoration(labelText: "Week Number"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: progressController,
                decoration: const InputDecoration(
                  labelText: "Progress Details",
                ),
              ),
              TextFormField(
                controller: completionController,
                decoration: const InputDecoration(labelText: "Completion %"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text("Expenses", style: Theme.of(context).textTheme.titleMedium),
              TextFormField(
                controller: materialsController,
                decoration: const InputDecoration(labelText: "Materials"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: laborController,
                decoration: const InputDecoration(labelText: "Labor"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: equipmentController,
                decoration: const InputDecoration(labelText: "Equipment"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: otherController,
                decoration: const InputDecoration(labelText: "Other"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Report"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
