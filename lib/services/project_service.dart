import 'package:pardarsh_application/model/project.dart';
import 'package:pardarsh_application/services/api_serivces.dart';
import 'package:pardarsh_application/model/user.dart';

class ProjectService {
  final ApiService _api = ApiService();

  Future<List<Project>> getProjects({String? status, String? region}) async {
    String endpoint = '/projects';
    Map<String, String> queryParams = {};

    if (status != null) queryParams['status'] = status;
    if (region != null) queryParams['region'] = region;

    if (queryParams.isNotEmpty) {
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      endpoint += '?$query';
    }

    final data = await _api.get(endpoint);
    final projects = (data['data'] as List)
        .map((e) => Project.fromJson(e))
        .toList();
    return projects;
  }

  Future<Project> getProjectById(String id) async {
    final data = await _api.get('/projects/$id');
    return Project.fromJson(data['data']);
  }

  Future<Project> createProject(Map<String, dynamic> body) async {
    final data = await _api.post('/projects', body);
    return Project.fromJson(data['data']);
  }

  Future<Project> updateProject(String id, Map<String, dynamic> body) async {
    final data = await _api.put('/projects/$id', body);
    return Project.fromJson(data['data']);
  }

  Future<void> deleteProject(String id) async {
    await _api.delete('/projects/$id');
  }

  Future<Project> assignContractor(
    String projectId,
    String contractorId,
  ) async {
    final data = await _api.put('/projects/$projectId/assign', {
      'contractorId': contractorId,
    });
    return Project.fromJson(data['data']);
  }

  Future<List<Project>> getAssignedProjects() async {
    try {
      // First, try to get current user info to use the contractor-specific endpoint
      final userResponse = await _api.get('/auth/me');
      final currentUser = UserModel.fromJson(userResponse['data']);

      if (currentUser.id.isNotEmpty) {
        // Use the contractor-specific projects endpoint
        final data = await _api.get('/contractors/${currentUser.id}/projects');
        final projects = (data['data'] as List)
            .map((e) => Project.fromJson(e))
            .toList();
        return projects;
      } else {
        throw Exception('Unable to get current user ID');
      }
    } catch (e) {
      // Fallback to filtering projects by query parameter
      try {
        final data = await _api.get('/projects?contractor=assigned');
        final projects = (data['data'] as List)
            .map((e) => Project.fromJson(e))
            .toList();
        return projects;
      } catch (fallbackError) {
        // If both approaches fail, return empty list instead of throwing
        return [];
      }
    }
  }

  Future<List<UserModel>> getAvailableContractors() async {
    final data = await _api.get('/contractors');
    final contractors = (data['data'] as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
    return contractors;
  }

  Future<List<Project>> getProjectsByStatus(String status) async {
    return getProjects(status: status);
  }

  Future<List<Project>> getProjectsByRegion(String region) async {
    return getProjects(region: region);
  }

  Future<Map<String, dynamic>> getProjectStatistics() async {
    final data = await _api.get('/projects/statistics');
    return data['data'];
  }
}
