import 'package:flutter/material.dart';
import '../model/user.dart';
import '../model/contractor_review.dart';
import '../services/contractor_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

// Sort options constants
class SortOptions {
  static const String rating = 'rating';
  static const String name = 'name';
  static const String totalReviews = 'totalReviews';
}

class ContractorProvider extends ChangeNotifier {
  final ContractorService _service = ContractorService();

  List<UserModel> _contractors = [];
  List<ContractorReview> _reviews = [];
  bool _isLoading = false;
  bool _isSubmittingReview = false;
  UserModel? _selectedContractor;
  String _searchQuery = '';
  String _sortBy = SortOptions.rating;
  String? _lastError;
  double? _minRating;

  // Getters
  List<UserModel> get contractors => _contractors;
  List<ContractorReview> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get isSubmittingReview => _isSubmittingReview;
  UserModel? get selectedContractor => _selectedContractor;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  double? get minRating => _minRating;
  String? get lastError => _lastError;

  // Setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    fetchContractors();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
    fetchContractors();
  }

  void setMinRating(double? rating) {
    _minRating = rating;
    notifyListeners();
    fetchContractors();
  }

  Future<void> fetchContractors() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _contractors = await _service.getAllContractors(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        minRating: _minRating,
      );
    } catch (e) {
      _lastError = _getErrorMessage(e);
      _contractors = []; // Clear list on error
      debugPrint('Error fetching contractors: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchContractorDetails(String contractorId) async {
    _lastError = null;

    try {
      _selectedContractor = await _service.getContractorById(contractorId);
      notifyListeners();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      _selectedContractor = null;
      debugPrint('Error fetching contractor details: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchContractorReviews(String contractorId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _reviews = await _service.getContractorReviews(contractorId);
    } catch (e) {
      _lastError = _getErrorMessage(e);
      _reviews = [];
      debugPrint('Error fetching contractor reviews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ContractorReview> submitReview({
    required String contractorId,
    required double rating,
    String? comment,
    String? projectId,
  }) async {
    // Validate inputs
    if (contractorId.isEmpty) {
      throw ArgumentError('Contractor ID cannot be empty');
    }
    if (rating < AppConstants.minRating || rating > AppConstants.maxRating) {
      throw ArgumentError(
        'Rating must be between ${AppConstants.minRating} and ${AppConstants.maxRating}',
      );
    }

    _isSubmittingReview = true;
    _lastError = null;
    notifyListeners();

    try {
      final reviewData = {
        'contractorId': contractorId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
        if (projectId != null) 'projectId': projectId,
      };

      final newReview = await _service.submitReview(reviewData);
      _reviews.insert(0, newReview);

      // Update contractor average rating if available
      if (_selectedContractor?.id == contractorId) {
        // Refresh contractor details to get updated rating
        await fetchContractorDetails(contractorId);
      }

      return newReview;
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error submitting review: $e');
      rethrow;
    } finally {
      _isSubmittingReview = false;
      notifyListeners();
    }
  }

  Future<void> updateReview(
    String reviewId, {
    required double rating,
    String? comment,
  }) async {
    // Validate inputs
    if (reviewId.isEmpty) {
      throw ArgumentError('Review ID cannot be empty');
    }
    if (rating < AppConstants.minRating || rating > AppConstants.maxRating) {
      throw ArgumentError(
        'Rating must be between ${AppConstants.minRating} and ${AppConstants.maxRating}',
      );
    }

    _lastError = null;

    try {
      final reviewData = {
        'rating': rating,
        if (comment != null) 'comment': comment,
      };

      await _service.updateReview(reviewId, reviewData);

      // Update the review in the local list
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        // Create updated review (simplified approach)
        final updatedReview = ContractorReview(
          id: _reviews[index].id,
          contractorId: _reviews[index].contractorId,
          reviewerId: _reviews[index].reviewerId,
          reviewerName: _reviews[index].reviewerName,
          rating: rating,
          comment: comment,
          projectId: _reviews[index].projectId,
          projectName: _reviews[index].projectName,
          createdAt: _reviews[index].createdAt,
        );
        _reviews[index] = updatedReview;
      }

      notifyListeners();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error updating review: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    if (reviewId.isEmpty) {
      throw ArgumentError('Review ID cannot be empty');
    }

    _lastError = null;

    try {
      await _service.deleteReview(reviewId);
      _reviews.removeWhere((r) => r.id == reviewId);
      notifyListeners();
    } catch (e) {
      _lastError = _getErrorMessage(e);
      debugPrint('Error deleting review: $e');
      rethrow;
    }
  }

  void clearSelectedContractor() {
    _selectedContractor = null;
    _reviews.clear();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _sortBy = SortOptions.rating;
    _minRating = null;
    _lastError = null;
    notifyListeners();
    fetchContractors();
  }

  // Helper method to convert exceptions to user-friendly error messages
  String _getErrorMessage(dynamic error) {
    return ErrorFormatter.formatApiError(error);
  }
}
