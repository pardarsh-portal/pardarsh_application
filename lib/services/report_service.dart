import 'package:pardarsh_application/model/report.dart';
import 'package:pardarsh_application/services/api_serivces.dart';


class ReportService {
  final ApiService _api = ApiService();

  Future<List<ProjectReport>> getReports(String projectId) async {
    final data = await _api.get('/projects/$projectId/reports');
    final reports = (data['data'] as List)
        .map((e) => ProjectReport.fromJson(e))
        .toList();
    return reports;
  }

  Future<ProjectReport> submitReport(String projectId, Map<String, dynamic> body) async {
    final data = await _api.post('/projects/$projectId/reports', body);
    return ProjectReport.fromJson(data['data']);
  }
}
