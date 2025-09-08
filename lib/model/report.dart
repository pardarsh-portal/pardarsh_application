class ProjectReport {
  final String id;
  final String projectId;
  final String contractorId;
  final int weekNumber;
  final DateTime weekStartDate;
  final double materials;
  final double labor;
  final double equipment;
  final double other;
  final String progressDetails;
  final int completionPercentage;
  final String? challenges;
  final String? nextWeekPlan;
  final String status;

  ProjectReport({
    required this.id,
    required this.projectId,
    required this.contractorId,
    required this.weekNumber,
    required this.weekStartDate,
    required this.materials,
    required this.labor,
    required this.equipment,
    required this.other,
    required this.progressDetails,
    required this.completionPercentage,
    this.challenges,
    this.nextWeekPlan,
    required this.status,
  });

  factory ProjectReport.fromJson(Map<String, dynamic> json) {
    return ProjectReport(
      id: json['_id'],
      projectId: json['projectId'],
      contractorId: json['contractorId'],
      weekNumber: json['weekNumber'],
      weekStartDate: DateTime.parse(json['weekStartDate']),
      materials: (json['expenses']['materials'] ?? 0).toDouble(),
      labor: (json['expenses']['labor'] ?? 0).toDouble(),
      equipment: (json['expenses']['equipment'] ?? 0).toDouble(),
      other: (json['expenses']['other'] ?? 0).toDouble(),
      progressDetails: json['progressDetails'],
      completionPercentage: json['completionPercentage'],
      challenges: json['challenges'],
      nextWeekPlan: json['nextWeekPlan'],
      status: json['status'],
    );
  }
}
