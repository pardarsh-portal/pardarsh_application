import 'package:flutter/material.dart';
import 'package:pardarsh_application/model/report.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _service = ReportService();
  List<ProjectReport> _reports = [];
  bool _isLoading = false;

  List<ProjectReport> get reports => _reports;
  bool get isLoading => _isLoading;

  Future<void> fetchReports(String projectId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _reports = await _service.getReports(projectId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
