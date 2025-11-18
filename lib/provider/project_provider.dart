import 'package:flutter/material.dart';
import 'package:pardarsh_application/model/project.dart';
import '../services/project_service.dart';
import '../model/user.dart';
import '../utils/network_helper.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService _service = ProjectService();

  List<Project> _projects = [];
  List<Project> _assignedProjects = [];
  List<UserModel> _contractors = [];
  bool _isLoading = false;
  bool _isLoadingContractors = false;
  Project? _selectedProject;
  String? _lastError;

  // Getters
  List<Project> get projects => _projects;
  List<Project> get assignedProjects => _assignedProjects;
  List<UserModel> get contractors => _contractors;
  bool get isLoading => _isLoading;
  bool get isLoadingContractors => _isLoadingContractors;
  Project? get selectedProject => _selectedProject;
  String? get lastError => _lastError;

  Future<void> fetchProjects({String? status, String? region}) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      _projects = await _service.getProjects(status: status, region: region);
    } catch (e) {
      _lastError = _getErrorMessage(e);
      _projects = []; // Clear list on error
      debugPrint('Error fetching projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Project> getProjectById(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Project ID cannot be empty');
    }

    _lastError = null;

    try {
      _selectedProject = await _service.getProjectById(id);
      notifyListeners();
      return _selectedProject!;
    } catch (e) {
      _lastError = _getErrorMessage(e);
      _selectedProject = null;
      debugPrint('Error fetching project: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createProject(Map<String, dynamic> projectData) async {
    if (projectData.isEmpty) {
      throw ArgumentError('Project data cannot be empty');
    }

    _lastError = null;

    try {
      final newProject = await _service.createProject(projectData);
      _projects.insert(0, newProject);
      notifyListeners();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error creating project: $e');
      rethrow;
    }
  }

  Future<void> updateProject(
    String id,
    Map<String, dynamic> projectData,
  ) async {
    if (id.isEmpty) {
      throw ArgumentError('Project ID cannot be empty');
    }
    if (projectData.isEmpty) {
      throw ArgumentError('Project data cannot be empty');
    }

    _lastError = null;

    try {
      final updatedProject = await _service.updateProject(id, projectData);
      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projects[index] = updatedProject;
      }
      if (_selectedProject?.id == id) {
        _selectedProject = updatedProject;
      }
      notifyListeners();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error updating project: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Project ID cannot be empty');
    }

    _lastError = null;

    try {
      await _service.deleteProject(id);
      _projects.removeWhere((p) => p.id == id);
      _assignedProjects.removeWhere((p) => p.id == id);
      if (_selectedProject?.id == id) {
        _selectedProject = null;
      }
      notifyListeners();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error deleting project: $e');
      rethrow;
    }
  }

  Future<void> fetchAssignedProjects() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      _assignedProjects = await _service.getAssignedProjects();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      _assignedProjects = []; // Clear list on error
      debugPrint('Error fetching assigned projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchContractors() async {
    _isLoadingContractors = true;
    _lastError = null;
    notifyListeners();
    try {
      _contractors = await _service.getAvailableContractors();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      _contractors = []; // Clear list on error
      debugPrint('Error fetching contractors: $e');
    } finally {
      _isLoadingContractors = false;
      notifyListeners();
    }
  }

  Future<void> assignContractor(String projectId, String contractorId) async {
    if (projectId.isEmpty || contractorId.isEmpty) {
      throw ArgumentError('Project ID and Contractor ID cannot be empty');
    }

    _lastError = null;

    try {
      final updatedProject = await _service.assignContractor(
        projectId,
        contractorId,
      );
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        _projects[index] = updatedProject;
      }
      if (_selectedProject?.id == projectId) {
        _selectedProject = updatedProject;
      }
      notifyListeners();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error assigning contractor: $e');
      rethrow;
    }
  }

  Future<List<Project>> getProjectsByStatus(String status) async {
    if (status.isEmpty) {
      throw ArgumentError('Status cannot be empty');
    }

    try {
      return await _service.getProjectsByStatus(status);
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error fetching projects by status: $e');
      rethrow;
    }
  }

  Future<List<Project>> getProjectsByRegion(String region) async {
    if (region.isEmpty) {
      throw ArgumentError('Region cannot be empty');
    }

    try {
      return await _service.getProjectsByRegion(region);
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error fetching projects by region: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProjectStatistics() async {
    try {
      return await _service.getProjectStatistics();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error fetching project statistics: $e');
      rethrow;
    }
  }

  void clearSelectedProject() {
    _selectedProject = null;
    _lastError = null;
    notifyListeners();
  }

  void clearProjects() {
    _projects.clear();
    _assignedProjects.clear();
    _lastError = null;
    notifyListeners();
  }

  // Helper method to convert exceptions to user-friendly error messages
  String _getErrorMessage(dynamic error) {
    return NetworkHelper.formatNetworkError(error);
  }
}
