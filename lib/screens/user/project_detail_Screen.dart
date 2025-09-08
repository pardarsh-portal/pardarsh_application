import 'package:flutter/material.dart';
import 'package:pardarsh_application/model/project.dart';
import 'package:pardarsh_application/services/project_service.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  Project? project;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  Future<void> _loadProject() async {
  final service = ProjectService();
  project = await service.getProjectById(widget.projectId);
  setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Project Details")),
      body: loading || project == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(project!.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text("Region: ${project!.region}"),
                  Text("Status: ${project!.status}"),
                  Text("Deadline: ${project!.deadline.toLocal()}"),
                  const SizedBox(height: 16),
                  Text("Description:", style: Theme.of(context).textTheme.labelSmall),
                  Text(project!.description),
                  const SizedBox(height: 16),
                  Text("Created By: ${project!.createdBy}"),
                  Text("Assigned Contractor: ${project!.contractorName ?? 'Not Assigned'}"),
                ],
              ),
            ),
    );
  }
}
