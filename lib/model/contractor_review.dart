class ContractorReview {
  final String id;
  final String contractorId;
  final String reviewerId;
  final String? reviewerName;
  final double rating;
  final String? comment;
  final String? projectId;
  final String? projectName;
  final DateTime createdAt;

  ContractorReview({
    required this.id,
    required this.contractorId,
    required this.reviewerId,
    this.reviewerName,
    required this.rating,
    this.comment,
    this.projectId,
    this.projectName,
    required this.createdAt,
  });

  factory ContractorReview.fromJson(Map<String, dynamic> json) {
    return ContractorReview(
      id: json['_id'] ?? json['id'] ?? '',
      contractorId: json['contractorId'] ?? '',
      reviewerId: json['reviewerId'] ?? json['userId'] ?? '',
      reviewerName: json['reviewerName'] ?? json['userName'],
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'],
      projectId: json['projectId'],
      projectName: json['projectName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contractorId': contractorId,
      'rating': rating,
      'comment': comment,
      'projectId': projectId,
    };
  }
}
