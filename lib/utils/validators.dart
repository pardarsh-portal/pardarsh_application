import 'constants.dart';

/// Utility class for common validation functions
class Validators {
  /// Validates email format
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  /// Validates rating value
  static String? validateRating(double? rating) {
    if (rating == null) {
      return 'Rating is required';
    }
    if (rating < AppConstants.minRating || rating > AppConstants.maxRating) {
      return 'Rating must be between ${AppConstants.minRating} and ${AppConstants.maxRating}';
    }
    return null;
  }

  /// Validates phone number (basic)
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return null; // Phone is optional
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(phone) || phone.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates required text field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates text with minimum length
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validates numeric input
  static String? validateNumeric(
    String? value,
    String fieldName, {
    double? min,
    double? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number for $fieldName';
    }

    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }

    if (max != null && number > max) {
      return '$fieldName must not exceed $max';
    }

    return null;
  }

  /// Validates that two passwords match
  static String? validatePasswordMatch(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}

/// Utility class for formatting error messages
class ErrorFormatter {
  /// Formats API errors into user-friendly messages
  static String formatApiError(dynamic error) {
    if (error == null) return AppConstants.genericErrorMsg;

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') ||
        errorString.contains('network error')) {
      return AppConstants.networkErrorMsg;
    } else if (errorString.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (errorString.contains('401') ||
        errorString.contains('unauthorized')) {
      return AppConstants.unauthorizedMsg;
    } else if (errorString.contains('403') ||
        errorString.contains('forbidden')) {
      return 'Access denied. You don\'t have permission for this action.';
    } else if (errorString.contains('404') ||
        errorString.contains('not found')) {
      return AppConstants.notFoundMsg;
    } else if (errorString.contains('500') || errorString.contains('server')) {
      return AppConstants.serverErrorMsg;
    } else if (errorString.contains('validation')) {
      return 'Please check your input and try again.';
    } else {
      // Extract meaningful message if possible
      if (error.toString().contains('Exception:')) {
        final message = error.toString().split('Exception:').last.trim();
        return message.isNotEmpty ? message : AppConstants.genericErrorMsg;
      }
      return AppConstants.genericErrorMsg;
    }
  }

  /// Formats validation errors for display
  static String formatValidationError(List<String> errors) {
    if (errors.isEmpty) return '';
    if (errors.length == 1) return errors.first;

    return 'Please fix the following issues:\n${errors.map((e) => '• $e').join('\n')}';
  }
}
