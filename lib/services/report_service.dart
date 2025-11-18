import 'package:pardarsh_application/model/report.dart';
import 'package:pardarsh_application/services/api_serivces.dart';

class ReportService {
  final ApiService _api = ApiService();

  Future<List<ProjectReport>> getReports({
    String? projectId,
    String? status,
  }) async {
    String endpoint = '/reports';
    Map<String, String> queryParams = {};

    if (projectId != null) queryParams['projectId'] = projectId;
    if (status != null) queryParams['status'] = status;

    if (queryParams.isNotEmpty) {
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      endpoint += '?$query';
    }

    final data = await _api.get(endpoint);
    final reports = (data['data'] as List)
        .map((e) => ProjectReport.fromJson(e))
        .toList();
    return reports;
  }

  Future<ProjectReport> getReportById(String projectId, String reportId) async {
    final data = await _api.get('/projects/$projectId/reports/$reportId');
    return ProjectReport.fromJson(data['data']);
  }

  Future<List<ProjectReport>> getReportsByProject(String projectId) async {
    final data = await _api.get('/projects/$projectId/reports');
    final reports = (data['data'] as List)
        .map((e) => ProjectReport.fromJson(e))
        .toList();
    return reports;
  }

  Future<ProjectReport> createReport(Map<String, dynamic> body) async {
    final data = await _api.post('/reports', body);
    return ProjectReport.fromJson(data['data']);
  }

  Future<ProjectReport> updateReport(
    String id,
    Map<String, dynamic> body,
  ) async {
    final data = await _api.put('/reports/$id', body);
    return ProjectReport.fromJson(data['data']);
  }

  Future<void> deleteReport(String id) async {
    await _api.delete('/reports/$id');
  }

  Future<ProjectReport> submitReport(
    String projectId,
    Map<String, dynamic> body,
  ) async {
    final data = await _api.post('/projects/$projectId/reports', body);
    return ProjectReport.fromJson(data['data']);
  }

  Future<ProjectReport> submitReportForReview(String id) async {
    final data = await _api.put('/reports/$id/submit', {});
    return ProjectReport.fromJson(data['data']);
  }

  Future<ProjectReport> approveReport(String id, {String? feedback}) async {
    final data = await _api.put('/reports/$id/approve', {
      if (feedback != null) 'feedback': feedback,
    });
    return ProjectReport.fromJson(data['data']);
  }

  Future<ProjectReport> rejectReport(String id, String reason) async {
    final data = await _api.put('/reports/$id/reject', {'reason': reason});
    return ProjectReport.fromJson(data['data']);
  }

  Future<List<ProjectReport>> getPendingReports() async {
    return getReports(status: 'pending');
  }

  Future<List<ProjectReport>> getApprovedReports() async {
    return getReports(status: 'approved');
  }

  Future<Map<String, dynamic>> getReportStatistics({String? projectId}) async {
    String endpoint = '/reports/statistics';
    if (projectId != null) {
      endpoint += '?projectId=$projectId';
    }
    final data = await _api.get(endpoint);
    return data['data'];
  }

  Future<Map<String, dynamic>> getExpenseSummary({
    String? projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String endpoint = '/reports/expenses/summary';
    Map<String, String> queryParams = {};

    if (projectId != null) queryParams['projectId'] = projectId;
    if (startDate != null)
      queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

    if (queryParams.isNotEmpty) {
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      endpoint += '?$query';
    }

    final data = await _api.get(endpoint);
    return data['data'];
  }
}
