import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/report_provider.dart';
import '../../model/report.dart';
import '../../widgets/custom_button.dart';

class EnhancedReportManagementScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const EnhancedReportManagementScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<EnhancedReportManagementScreen> createState() =>
      _EnhancedReportManagementScreenState();
}

class _EnhancedReportManagementScreenState
    extends State<EnhancedReportManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(
        context,
        listen: false,
      ).fetchReportsByProject(widget.projectId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Project Reports'),
            Text(
              widget.projectName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Reports', icon: Icon(Icons.description)),
            Tab(text: 'Create Report', icon: Icon(Icons.add_box)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildReportsTab(), _buildCreateReportTab()],
      ),
    );
  }

  Widget _buildReportsTab() {
    return Consumer<ReportProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.projectReports.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.projectReports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No reports yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first progress report',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('Create Report'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchReportsByProject(widget.projectId),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.projectReports.length,
            itemBuilder: (context, index) {
              final report = provider.projectReports[index];
              return _buildReportCard(context, report, provider);
            },
          ),
        );
      },
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    ProjectReport report,
    ReportProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week ${report.weekNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${report.weekStartDate.day}/${report.weekStartDate.month}/${report.weekStartDate.year}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      report.status,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    report.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(report.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress: ${report.completionPercentage}%',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: report.completionPercentage / 100,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(report.completionPercentage),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Expenses Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expenses',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildExpenseItem('Materials', report.materials),
                      _buildExpenseItem('Labor', report.labor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildExpenseItem('Equipment', report.equipment),
                      _buildExpenseItem('Other', report.other),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₹${(report.materials + report.labor + report.equipment + report.other).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (report.progressDetails.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Progress Details:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(report.progressDetails),
            ],

            const SizedBox(height: 16),
            Row(
              children: [
                if (report.status.toLowerCase() == 'draft') ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editReport(context, report),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _submitReport(context, report, provider),
                      icon: const Icon(Icons.send),
                      label: const Text('Submit'),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewReportDetails(context, report),
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Details'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildCreateReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ReportForm(
        projectId: widget.projectId,
        onSuccess: () {
          _tabController.animateTo(0);
          Provider.of<ReportProvider>(
            context,
            listen: false,
          ).fetchReportsByProject(widget.projectId);
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'draft':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getProgressColor(int percentage) {
    if (percentage < 30) return Colors.red;
    if (percentage < 70) return Colors.orange;
    return Colors.green;
  }

  void _editReport(BuildContext context, ProjectReport report) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditReportScreen(report: report)),
    );
  }

  Future<void> _submitReport(
    BuildContext context,
    ProjectReport report,
    ReportProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Report'),
        content: const Text(
          'Are you sure you want to submit this report? You won\'t be able to edit it after submission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.submitReportForReview(report.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit report: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _viewReportDetails(BuildContext context, ProjectReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReportDetailModal(report: report),
    );
  }
}

// Report Form Widget
class ReportForm extends StatefulWidget {
  final String projectId;
  final VoidCallback onSuccess;

  const ReportForm({
    super.key,
    required this.projectId,
    required this.onSuccess,
  });

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _weekController = TextEditingController();
  final _progressController = TextEditingController();
  final _completionController = TextEditingController();
  final _materialsController = TextEditingController();
  final _laborController = TextEditingController();
  final _equipmentController = TextEditingController();
  final _otherController = TextEditingController();
  final _challengesController = TextEditingController();
  final _nextWeekController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _weekController.dispose();
    _progressController.dispose();
    _completionController.dispose();
    _materialsController.dispose();
    _laborController.dispose();
    _equipmentController.dispose();
    _otherController.dispose();
    _challengesController.dispose();
    _nextWeekController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Weekly Report',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Week Number
          TextFormField(
            controller: _weekController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Week Number *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter week number';
              }
              if (int.tryParse(value) == null || int.parse(value) < 1) {
                return 'Please enter a valid week number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Completion Percentage
          TextFormField(
            controller: _completionController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Completion Percentage (0-100) *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter completion percentage';
              }
              final percentage = int.tryParse(value);
              if (percentage == null || percentage < 0 || percentage > 100) {
                return 'Please enter a valid percentage (0-100)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Progress Details
          TextFormField(
            controller: _progressController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Progress Details *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter progress details';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Expenses Section
          Text(
            'Expenses',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _materialsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Materials (₹) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid amount';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _laborController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Labor (₹) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid amount';
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
                  controller: _equipmentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Equipment (₹) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid amount';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _otherController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Other (₹)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        double.tryParse(value) == null) {
                      return 'Invalid amount';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Challenges
          TextFormField(
            controller: _challengesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Challenges (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Next Week Plan
          TextFormField(
            controller: _nextWeekController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Next Week Plan (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),

          // Submit Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => _submitReport(false),
                  child: const Text('Save as Draft'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: _isSubmitting ? 'Submitting...' : 'Submit Report',
                  onPressed: _isSubmitting ? null : () => _submitReport(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport(bool submitForReview) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reportData = {
        'weekNumber': int.parse(_weekController.text),
        'weekStartDate': DateTime.now().toIso8601String(),
        'materials': double.parse(_materialsController.text),
        'labor': double.parse(_laborController.text),
        'equipment': double.parse(_equipmentController.text),
        'other': double.tryParse(_otherController.text) ?? 0.0,
        'progressDetails': _progressController.text,
        'completionPercentage': int.parse(_completionController.text),
        'challenges': _challengesController.text.isNotEmpty
            ? _challengesController.text
            : null,
        'nextWeekPlan': _nextWeekController.text.isNotEmpty
            ? _nextWeekController.text
            : null,
        'status': submitForReview ? 'pending' : 'draft',
      };

      final reportProvider = Provider.of<ReportProvider>(
        context,
        listen: false,
      );
      await reportProvider.createReport(reportData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              submitForReview
                  ? 'Report submitted successfully!'
                  : 'Report saved as draft!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess();
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearForm() {
    _weekController.clear();
    _progressController.clear();
    _completionController.clear();
    _materialsController.clear();
    _laborController.clear();
    _equipmentController.clear();
    _otherController.clear();
    _challengesController.clear();
    _nextWeekController.clear();
  }
}

// Report Detail Modal
class ReportDetailModal extends StatelessWidget {
  final ProjectReport report;

  const ReportDetailModal({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Week ${report.weekNumber} Report',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem('Status', report.status.toUpperCase()),
                  _buildDetailItem(
                    'Week Start Date',
                    '${report.weekStartDate.day}/${report.weekStartDate.month}/${report.weekStartDate.year}',
                  ),
                  _buildDetailItem(
                    'Completion',
                    '${report.completionPercentage}%',
                  ),
                  _buildDetailItem('Progress Details', report.progressDetails),

                  const SizedBox(height: 16),
                  const Text(
                    'Expenses Breakdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailItem(
                    'Materials',
                    '₹${report.materials.toStringAsFixed(2)}',
                  ),
                  _buildDetailItem(
                    'Labor',
                    '₹${report.labor.toStringAsFixed(2)}',
                  ),
                  _buildDetailItem(
                    'Equipment',
                    '₹${report.equipment.toStringAsFixed(2)}',
                  ),
                  _buildDetailItem(
                    'Other',
                    '₹${report.other.toStringAsFixed(2)}',
                  ),
                  const Divider(),
                  _buildDetailItem(
                    'Total Expenses',
                    '₹${(report.materials + report.labor + report.equipment + report.other).toStringAsFixed(2)}',
                    isHighlight: true,
                  ),

                  if (report.challenges != null &&
                      report.challenges!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailItem('Challenges', report.challenges!),
                  ],

                  if (report.nextWeekPlan != null &&
                      report.nextWeekPlan!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailItem('Next Week Plan', report.nextWeekPlan!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.green.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }
}

// Edit Report Screen (placeholder)
class EditReportScreen extends StatelessWidget {
  final ProjectReport report;

  const EditReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Week ${report.weekNumber} Report')),
      body: const Center(child: Text('Edit functionality coming soon...')),
    );
  }
}
