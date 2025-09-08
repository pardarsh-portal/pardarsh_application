import 'package:pardarsh_application/model/project.dart';
import 'package:pardarsh_application/services/api_serivces.dart';

class ProjectService {
  final ApiService _api = ApiService();

  Future<List<Project>> getProjects() async {
    final data = await _api.get('/projects');
    final projects = (data['data'] as List)
        .map((e) => Project.fromJson(e))
        .toList();
    return projects;
  }

  Future<Project> getProjectById(String id) async {
    final data = await _api.get('/projects/$id');
    return Project.fromJson(data['data']);
  }

  Future<Project> createProject(Map<String, dynamic> body, String token) async {
    final data = await _api.post('/projects', body);
    return Project.fromJson(data['data']);
  }
}
