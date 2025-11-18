import 'package:flutter/material.dart';
import 'package:pardarsh_application/provider/project_provider.dart';
import 'package:provider/provider.dart';
import '../../widgets/project_card.dart';
import 'project_detail_screen.dart';

class AssignedProjectsScreen extends StatefulWidget {
  const AssignedProjectsScreen({super.key});

  @override
  State<AssignedProjectsScreen> createState() => _AssignedProjectsScreenState();
}

class _AssignedProjectsScreenState extends State<AssignedProjectsScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to prevent setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAssignedProjects();
    });
  }

  Future<void> _loadAssignedProjects() async {
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    try {
      await provider.fetchAssignedProjects();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading projects: ${provider.lastError ?? error.toString()}',
            ),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadAssignedProjects,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Assigned Projects")),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(ProjectProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error state if there's an error and no cached data
    if (provider.lastError != null && provider.assignedProjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error Loading Projects',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                provider.lastError!,
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAssignedProjects,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (provider.assignedProjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Assigned Projects',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any projects assigned yet.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAssignedProjects,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAssignedProjects,
      child: ListView.builder(
        itemCount: provider.assignedProjects.length,
        itemBuilder: (context, index) {
          final project = provider.assignedProjects[index];
          return ProjectCard(
            project: project,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ContractorProjectDetailScreen(projectId: project.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
