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
      id: json['_id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      contractorId: json['contractorId']?.toString() ?? '',
      weekNumber: (json['weekNumber'] as num?)?.toInt() ?? 0,
      weekStartDate:
          DateTime.tryParse(json['weekStartDate']?.toString() ?? '') ??
          DateTime.now(),
      materials: ((json['expenses']?['materials'] ?? 0) as num).toDouble(),
      labor: ((json['expenses']?['labor'] ?? 0) as num).toDouble(),
      equipment: ((json['expenses']?['equipment'] ?? 0) as num).toDouble(),
      other: ((json['expenses']?['other'] ?? 0) as num).toDouble(),
      progressDetails: json['progressDetails']?.toString() ?? '',
      completionPercentage:
          (json['completionPercentage'] as num?)?.toInt() ?? 0,
      challenges: json['challenges']?.toString(),
      nextWeekPlan: json['nextWeekPlan']?.toString(),
      status: json['status']?.toString() ?? 'draft',
    );
  }
}
