import 'app_config.dart';

const String appName = "Pardarsh Portal";

// API Configuration - Now uses environment-based configuration
String get apiBaseUrl => AppConfig.apiBaseUrl;

// App Constants
class AppConstants {
  static const int defaultTimeoutSeconds = 30;
  static const int maxRetries = 3;
  static const int minPasswordLength = 6;
  static const int maxRating = 5;
  static const int minRating = 1;
  static const double defaultRating = 0.0;
  static const String defaultAvatarIcon = 'engineering';
  static const String unknownContractorName = 'Unknown Contractor';
  static const String anonymousReviewer = 'Anonymous';

  // Error Messages
  static const String networkErrorMsg =
      'Network error. Please check your connection.';
  static const String serverErrorMsg = 'Server error. Please try again later.';
  static const String unauthorizedMsg = 'Please log in again.';
  static const String notFoundMsg = 'Requested data not found.';
  static const String genericErrorMsg =
      'Something went wrong. Please try again.';
}
