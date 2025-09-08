import 'package:flutter/material.dart';
import 'package:pardarsh_application/model/project.dart';
import '../services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService _service = ProjectService();
  List<Project> _projects = [];
  bool _isLoading = false;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;

  Future<void> fetchProjects() async {
    _isLoading = true;
    notifyListeners();
    try {
      _projects = await _service.getProjects();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
