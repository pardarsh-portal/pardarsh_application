class Project {
  final String id;
  final String name;
  final String region;
  final String description;
  final String? tenderDetails;
  final DateTime deadline;
  final String status;
  final String? contractorName;
  final String createdBy;

  Project({
    required this.id,
    required this.name,
    required this.region,
    required this.description,
    this.tenderDetails,
    required this.deadline,
    required this.status,
    this.contractorName,
    required this.createdBy,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'],
      name: json['name'],
      region: json['region'],
      description: json['description'],
      tenderDetails: json['tenderDetails'],
      deadline: DateTime.parse(json['deadline']),
      status: json['status'] ?? 'Open',
      contractorName: json['contractorId']?['legalName'],
      createdBy: json['createdBy']?['legalName'] ?? '',
    );
  }
}
