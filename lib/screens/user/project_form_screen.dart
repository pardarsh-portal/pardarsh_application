import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/project_provider.dart';
import '../../widgets/custom_button.dart';

class ProjectFormScreen extends StatefulWidget {
  final String? projectId;

  const ProjectFormScreen({super.key, this.projectId});

  bool get isEditing => projectId != null;

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final regionController = TextEditingController();
  final tenderDetailsController = TextEditingController();

  DateTime? selectedDeadline;
  String selectedStatus = 'Open';
  bool isLoading = false;
  bool isLoadingData = false;

  final List<String> statusOptions = [
    'Open',
    'In Progress',
    'Completed',
    'Cancelled',
    'On Hold',
  ];

  final List<String> regions = [
    'North',
    'South',
    'East',
    'West',
    'Central',
    'Northeast',
    'Northwest',
    'Southeast',
    'Southwest',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadProjectData();
    }
  }

  Future<void> _loadProjectData() async {
    setState(() => isLoadingData = true);
    try {
      final provider = Provider.of<ProjectProvider>(context, listen: false);
      final project = await provider.getProjectById(widget.projectId!);

      nameController.text = project.name;
      descriptionController.text = project.description;
      regionController.text = project.region;
      tenderDetailsController.text = project.tenderDetails ?? '';
      selectedDeadline = project.deadline;
      selectedStatus = project.status;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading project: $e')));
    } finally {
      setState(() => isLoadingData = false);
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDeadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a deadline')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final provider = Provider.of<ProjectProvider>(context, listen: false);

      final projectData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'region': regionController.text.trim(),
        'tenderDetails': tenderDetailsController.text.trim(),
        'deadline': selectedDeadline!.toIso8601String(),
        'status': selectedStatus,
      };

      if (widget.isEditing) {
        await provider.updateProject(widget.projectId!, projectData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project updated successfully')),
        );
      } else {
        await provider.createProject(projectData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project created successfully')),
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => selectedDeadline = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Project' : 'Create Project'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Project' : 'Create Project'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Project Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Project Name *',
                          prefixIcon: Icon(Icons.work),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true)
                            return 'Project name is required';
                          if (value!.length < 3)
                            return 'Name must be at least 3 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: regionController.text.isEmpty
                            ? null
                            : regionController.text,
                        decoration: const InputDecoration(
                          labelText: 'Region *',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        items: regions.map((region) {
                          return DropdownMenuItem(
                            value: region,
                            child: Text(region),
                          );
                        }).toList(),
                        onChanged: (value) {
                          regionController.text = value ?? '';
                        },
                        validator: (value) {
                          if (value?.isEmpty == true)
                            return 'Region is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true)
                            return 'Description is required';
                          if (value!.length < 10)
                            return 'Description must be at least 10 characters';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Project Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: tenderDetailsController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Tender Details',
                          prefixIcon: Icon(Icons.assignment),
                          border: OutlineInputBorder(),
                          hintText:
                              'Enter tender specifications and requirements...',
                        ),
                      ),
                      const SizedBox(height: 16),

                      InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Deadline *',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            selectedDeadline == null
                                ? 'Select deadline'
                                : '${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.info),
                          border: OutlineInputBorder(),
                        ),
                        items: statusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedStatus = value!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: isLoading
                    ? (widget.isEditing ? 'Updating...' : 'Creating...')
                    : (widget.isEditing ? 'Update Project' : 'Create Project'),
                onPressed: isLoading ? null : _saveProject,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text(
          'Are you sure you want to delete this project? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProject();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProject() async {
    setState(() => isLoading = true);
    try {
      final provider = Provider.of<ProjectProvider>(context, listen: false);
      await provider.deleteProject(widget.projectId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project deleted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting project: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    regionController.dispose();
    tenderDetailsController.dispose();
    super.dispose();
  }
}
