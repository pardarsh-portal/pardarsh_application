import 'package:flutter/material.dart';
import 'package:pardarsh_application/model/project.dart';


class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectCard({super.key, required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(project.name),
        subtitle: Text("${project.region} • Deadline: ${project.deadline.toLocal()}"),
        trailing: Text(project.status),
  onTap: onTap,
      ),
    );
  }
}
