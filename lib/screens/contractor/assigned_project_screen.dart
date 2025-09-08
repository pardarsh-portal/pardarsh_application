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
    Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Assigned Projects")),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.projects.length,
              itemBuilder: (context, index) {
                final project = provider.projects[index];
                if (project.contractorName == null) return const SizedBox();
                return ProjectCard(
                  project: project,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContractorProjectDetailScreen(projectId: project.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
