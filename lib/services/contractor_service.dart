import '../model/user.dart';
import '../model/contractor_review.dart';
import 'api_serivces.dart';

class ContractorService {
  final ApiService _api = ApiService();

  Future<List<UserModel>> getAllContractors({
    String? search,
    String? sortBy,
    double? minRating,
  }) async {
    String endpoint = '/contractors';
    Map<String, String> queryParams = {};

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (minRating != null) queryParams['minRating'] = minRating.toString();

    if (queryParams.isNotEmpty) {
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      endpoint += '?$query';
    }

    final data = await _api.get(endpoint);
    return (data['data'] as List).map((e) => UserModel.fromJson(e)).toList();
  }

  Future<UserModel> getContractorById(String contractorId) async {
    final data = await _api.get('/contractors/$contractorId');
    return UserModel.fromJson(data['data']);
  }

  Future<List<ContractorReview>> getContractorReviews(
    String contractorId,
  ) async {
    final data = await _api.get('/contractors/$contractorId/reviews');
    return (data['data'] as List)
        .map((e) => ContractorReview.fromJson(e))
        .toList();
  }

  Future<ContractorReview> submitReview(Map<String, dynamic> reviewData) async {
    final contractorId = reviewData['contractorId'];
    final data = await _api.post(
      '/contractors/$contractorId/reviews',
      reviewData,
    );
    return ContractorReview.fromJson(data['data']);
  }

  Future<void> updateReview(
    String reviewId,
    Map<String, dynamic> reviewData,
  ) async {
    await _api.put('/users/contractors/reviews/$reviewId', reviewData);
  }

  Future<void> deleteReview(String reviewId) async {
    await _api.delete('/users/contractors/reviews/$reviewId');
  }

  Future<Map<String, dynamic>> getContractorStatistics(
    String contractorId,
  ) async {
    final data = await _api.get('/users/contractors/$contractorId/statistics');
    return data['data'];
  }
}
