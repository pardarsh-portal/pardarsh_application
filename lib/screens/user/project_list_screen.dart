import 'package:flutter/material.dart';
import 'package:pardarsh_application/provider/project_provider.dart';
import 'package:pardarsh_application/screens/user/project_detail_screen.dart';
import 'package:pardarsh_application/screens/user/project_form_screen.dart';
import 'package:provider/provider.dart';
import '../../widgets/project_card.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  String? selectedStatus;
  String? selectedRegion;

  final List<String> statusOptions = [
    'All',
    'Open',
    'In Progress',
    'Completed',
    'Cancelled',
    'On Hold',
  ];

  final List<String> regionOptions = [
    'All',
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
    // Use addPostFrameCallback to defer the API call until after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjects();
    });
  }

  void _loadProjects() {
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    provider.fetchProjects(
      status: selectedStatus == 'All' ? null : selectedStatus,
      region: selectedRegion == 'All' ? null : selectedRegion,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Projects"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProjects),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (selectedStatus != null || selectedRegion != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  if (selectedStatus != null && selectedStatus != 'All')
                    Chip(
                      label: Text('Status: $selectedStatus'),
                      onDeleted: () {
                        setState(() => selectedStatus = null);
                        _loadProjects();
                      },
                    ),
                  if (selectedRegion != null && selectedRegion != 'All')
                    Chip(
                      label: Text('Region: $selectedRegion'),
                      onDeleted: () {
                        setState(() => selectedRegion = null);
                        _loadProjects();
                      },
                    ),
                ],
              ),
            ),

          // Project list
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.projects.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No projects found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Create a new project to get started',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => _loadProjects(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.projects.length,
                      itemBuilder: (context, index) {
                        final project = provider.projects[index];
                        return ProjectCard(
                          project: project,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProjectDetailScreen(projectId: project.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProjectFormScreen()),
          ).then((_) => _loadProjects());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Projects'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: statusOptions.map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) {
                setState(() => selectedStatus = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRegion,
              decoration: const InputDecoration(
                labelText: 'Region',
                border: OutlineInputBorder(),
              ),
              items: regionOptions.map((region) {
                return DropdownMenuItem(value: region, child: Text(region));
              }).toList(),
              onChanged: (value) {
                setState(() => selectedRegion = value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedStatus = null;
                selectedRegion = null;
              });
              Navigator.pop(context);
              _loadProjects();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadProjects();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
