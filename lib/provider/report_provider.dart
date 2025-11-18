import 'package:flutter/material.dart';
import 'package:pardarsh_application/model/report.dart';
import '../services/report_service.dart';
import '../utils/network_helper.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _service = ReportService();

  List<ProjectReport> _reports = [];
  List<ProjectReport> _projectReports = [];
  List<ProjectReport> _pendingReports = [];
  bool _isLoading = false;
  ProjectReport? _selectedReport;
  String? _lastError;

  // Getters
  List<ProjectReport> get reports => _reports;
  List<ProjectReport> get projectReports => _projectReports;
  List<ProjectReport> get pendingReports => _pendingReports;
  bool get isLoading => _isLoading;
  ProjectReport? get selectedReport => _selectedReport;
  String? get lastError => _lastError;

  Future<void> fetchReports({String? projectId, String? status}) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      _reports = await _service.getReports(
        projectId: projectId,
        status: status,
      );
    } catch (e) {
      _lastError = _getErrorMessage(e);
      _reports = []; // Clear list on error
      debugPrint('Error fetching reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ProjectReport> getReportById(String projectId, String reportId) async {
    if (projectId.isEmpty || reportId.isEmpty) {
      throw ArgumentError('Project ID and Report ID cannot be empty');
    }

    _lastError = null;

    try {
      _selectedReport = await _service.getReportById(projectId, reportId);
      notifyListeners();
      return _selectedReport!;
    } catch (e) {
      _lastError = _getErrorMessage(e);
      _selectedReport = null;
      debugPrint('Error fetching report: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchReportsByProject(String projectId) async {
    if (projectId.isEmpty) {
      throw ArgumentError('Project ID cannot be empty');
    }

    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      _projectReports = await _service.getReportsByProject(projectId);
    } catch (e) {
      _lastError = _getErrorMessage(e);
      _projectReports = []; // Clear list on error
      debugPrint('Error fetching project reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createReport(Map<String, dynamic> reportData) async {
    if (reportData.isEmpty) {
      throw ArgumentError('Report data cannot be empty');
    }

    _lastError = null;

    try {
      final newReport = await _service.createReport(reportData);
      _reports.insert(0, newReport);
      _projectReports.insert(0, newReport);
      notifyListeners();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error creating report: $e');
      rethrow;
    }
  }

  Future<void> updateReport(String id, Map<String, dynamic> reportData) async {
    if (id.isEmpty) {
      throw ArgumentError('Report ID cannot be empty');
    }
    if (reportData.isEmpty) {
      throw ArgumentError('Report data cannot be empty');
    }

    _lastError = null;

    try {
      final updatedReport = await _service.updateReport(id, reportData);
      _updateReportInLists(updatedReport);
      if (_selectedReport?.id == id) {
        _selectedReport = updatedReport;
      }
      notifyListeners();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error updating report: $e');
      rethrow;
    }
  }

  Future<void> deleteReport(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Report ID cannot be empty');
    }

    _lastError = null;

    try {
      await _service.deleteReport(id);
      _reports.removeWhere((r) => r.id == id);
      _projectReports.removeWhere((r) => r.id == id);
      _pendingReports.removeWhere((r) => r.id == id);
      if (_selectedReport?.id == id) {
        _selectedReport = null;
      }
      notifyListeners();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error deleting report: $e');
      rethrow;
    }
  }

  Future<void> submitReportForReview(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Report ID cannot be empty');
    }

    _lastError = null;

    try {
      final updatedReport = await _service.submitReportForReview(id);
      _updateReportInLists(updatedReport);
      if (_selectedReport?.id == id) {
        _selectedReport = updatedReport;
      }
      notifyListeners();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error submitting report: $e');
      rethrow;
    }
  }

  Future<void> approveReport(String id, {String? feedback}) async {
    if (id.isEmpty) {
      throw ArgumentError('Report ID cannot be empty');
    }

    _lastError = null;

    try {
      final updatedReport = await _service.approveReport(
        id,
        feedback: feedback,
      );
      _updateReportInLists(updatedReport);
      _pendingReports.removeWhere((r) => r.id == id);
      if (_selectedReport?.id == id) {
        _selectedReport = updatedReport;
      }
      notifyListeners();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error approving report: $e');
      rethrow;
    }
  }

  Future<void> rejectReport(String id, String reason) async {
    if (id.isEmpty) {
      throw ArgumentError('Report ID cannot be empty');
    }
    if (reason.isEmpty) {
      throw ArgumentError('Rejection reason cannot be empty');
    }

    _lastError = null;

    try {
      final updatedReport = await _service.rejectReport(id, reason);
      _updateReportInLists(updatedReport);
      _pendingReports.removeWhere((r) => r.id == id);
      if (_selectedReport?.id == id) {
        _selectedReport = updatedReport;
      }
      notifyListeners();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error rejecting report: $e');
      rethrow;
    }
  }

  Future<void> fetchPendingReports() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      _pendingReports = await _service.getPendingReports();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      _pendingReports = []; // Clear list on error
      debugPrint('Error fetching pending reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getReportStatistics({String? projectId}) async {
    _lastError = null;

    try {
      return await _service.getReportStatistics(projectId: projectId);
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error fetching report statistics: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getExpenseSummary({
    String? projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _lastError = null;

    try {
      return await _service.getExpenseSummary(
        projectId: projectId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error fetching expense summary: $e');
      rethrow;
    }
  }

  void _updateReportInLists(ProjectReport updatedReport) {
    // Update in main reports list
    final reportsIndex = _reports.indexWhere((r) => r.id == updatedReport.id);
    if (reportsIndex != -1) {
      _reports[reportsIndex] = updatedReport;
    }

    // Update in project reports list
    final projectReportsIndex = _projectReports.indexWhere(
      (r) => r.id == updatedReport.id,
    );
    if (projectReportsIndex != -1) {
      _projectReports[projectReportsIndex] = updatedReport;
    }

    // Update in pending reports list
    final pendingIndex = _pendingReports.indexWhere(
      (r) => r.id == updatedReport.id,
    );
    if (pendingIndex != -1) {
      _pendingReports[pendingIndex] = updatedReport;
    }
  }

  void clearSelectedReport() {
    _selectedReport = null;
    _lastError = null;
    notifyListeners();
  }

  void clearReports() {
    _reports.clear();
    _projectReports.clear();
    _pendingReports.clear();
    _lastError = null;
    notifyListeners();
  }

  // Helper method to convert exceptions to user-friendly error messages
  String _getErrorMessage(dynamic error) {
    return NetworkHelper.formatNetworkError(error);
  }
}
