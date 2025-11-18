import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/report_provider.dart';
import '../../widgets/custom_button.dart';

class ReportFormScreen extends StatefulWidget {
  final String projectId;
  final String? reportId;

  const ReportFormScreen({super.key, required this.projectId, this.reportId});

  bool get isEditing => reportId != null;

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final progressDetailsController = TextEditingController();
  final challengesController = TextEditingController();
  final nextWeekPlanController = TextEditingController();
  final materialsController = TextEditingController();
  final laborController = TextEditingController();
  final equipmentController = TextEditingController();
  final otherController = TextEditingController();

  int weekNumber = 1;
  DateTime weekStartDate = DateTime.now();
  int completionPercentage = 0;
  bool isLoading = false;
  bool isLoadingData = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadReportData();
    } else {
      _initializeNewReport();
    }
  }

  void _initializeNewReport() {
    // Set week start date to the beginning of current week (Monday)
    final now = DateTime.now();
    final weekday = now.weekday;
    weekStartDate = now.subtract(Duration(days: weekday - 1));
  }

  Future<void> _loadReportData() async {
    setState(() => isLoadingData = true);
    try {
      final provider = Provider.of<ReportProvider>(context, listen: false);
      final report = await provider.getReportById(
        widget.projectId,
        widget.reportId!,
      );

      weekNumber = report.weekNumber;

      weekStartDate = report.weekStartDate;
      materialsController.text = report.materials.toString();
      laborController.text = report.labor.toString();
      equipmentController.text = report.equipment.toString();
      otherController.text = report.other.toString();
      progressDetailsController.text = report.progressDetails;
      completionPercentage = report.completionPercentage;
      challengesController.text = report.challenges ?? '';
      nextWeekPlanController.text = report.nextWeekPlan ?? '';
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading report: $e')));
    } finally {
      setState(() => isLoadingData = false);
    }
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final provider = Provider.of<ReportProvider>(context, listen: false);

      final reportData = {
        'projectId': widget.projectId,
        'weekNumber': weekNumber,
        'weekStartDate': weekStartDate.toIso8601String(),
        'expenses': {
          'materials': double.tryParse(materialsController.text) ?? 0.0,
          'labor': double.tryParse(laborController.text) ?? 0.0,
          'equipment': double.tryParse(equipmentController.text) ?? 0.0,
          'other': double.tryParse(otherController.text) ?? 0.0,
        },
        'progressDetails': progressDetailsController.text.trim(),
        'completionPercentage': completionPercentage,
        'challenges': challengesController.text.trim(),
        'nextWeekPlan': nextWeekPlanController.text.trim(),
        'status': 'draft',
      };

      if (widget.isEditing) {
        await provider.updateReport(widget.reportId!, reportData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report updated successfully')),
        );
      } else {
        await provider.createReport(reportData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report created successfully')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    // First save the report, then submit it
    await _saveReport();

    if (widget.isEditing) {
      try {
        final provider = Provider.of<ReportProvider>(context, listen: false);
        await provider.submitReportForReview(widget.reportId!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted for review')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting report: $e')));
      }
    }
  }

  Future<void> _selectWeekStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: weekStartDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => weekStartDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Report' : 'Create Report'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Report' : 'Create Report'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: weekNumber.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Week Number *',
                                prefixIcon: Icon(Icons.calendar_view_week),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true)
                                  return 'Week number is required';
                                final num = int.tryParse(value!);
                                if (num == null || num < 1)
                                  return 'Enter a valid week number';
                                return null;
                              },
                              onChanged: (value) {
                                weekNumber = int.tryParse(value) ?? 1;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: _selectWeekStartDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Week Start Date *',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  '${weekStartDate.day}/${weekStartDate.month}/${weekStartDate.year}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Completion Percentage: $completionPercentage%',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Slider(
                        value: completionPercentage.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label: '$completionPercentage%',
                        onChanged: (value) {
                          setState(() => completionPercentage = value.round());
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Expenses Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Expenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: materialsController,
                              decoration: const InputDecoration(
                                labelText: 'Materials',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isNotEmpty == true) {
                                  final amount = double.tryParse(value!);
                                  if (amount == null || amount < 0) {
                                    return 'Enter valid amount';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: laborController,
                              decoration: const InputDecoration(
                                labelText: 'Labor',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isNotEmpty == true) {
                                  final amount = double.tryParse(value!);
                                  if (amount == null || amount < 0) {
                                    return 'Enter valid amount';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: equipmentController,
                              decoration: const InputDecoration(
                                labelText: 'Equipment',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isNotEmpty == true) {
                                  final amount = double.tryParse(value!);
                                  if (amount == null || amount < 0) {
                                    return 'Enter valid amount';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: otherController,
                              decoration: const InputDecoration(
                                labelText: 'Other',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isNotEmpty == true) {
                                  final amount = double.tryParse(value!);
                                  if (amount == null || amount < 0) {
                                    return 'Enter valid amount';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progress & Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: progressDetailsController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Progress Details *',
                          hintText: 'Describe the work completed this week...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true)
                            return 'Progress details are required';
                          if (value!.length < 20)
                            return 'Please provide more detailed information';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: challengesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Challenges & Issues',
                          hintText:
                              'Describe any challenges or issues faced...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: nextWeekPlanController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Next Week Plan',
                          hintText: 'Outline the plan for next week...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : _saveReport,
                      child: Text(isLoading ? 'Saving...' : 'Save Draft'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: isLoading ? 'Submitting...' : 'Submit Report',
                      onPressed: isLoading ? null : _submitReport,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    progressDetailsController.dispose();
    challengesController.dispose();
    nextWeekPlanController.dispose();
    materialsController.dispose();
    laborController.dispose();
    equipmentController.dispose();
    otherController.dispose();
    super.dispose();
  }
}
