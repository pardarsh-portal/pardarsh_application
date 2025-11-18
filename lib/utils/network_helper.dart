import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/app_config.dart';
import '../utils/validators.dart';

/// Network connectivity and health checking utilities
class NetworkHelper {
  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('Internet connectivity check failed: $e');
      return false;
    }
  }

  /// Check if the backend API is reachable
  static Future<bool> isApiReachable() async {
    try {
      final url = Uri.parse(AppConfig.apiBaseUrl);
      final socket = await Socket.connect(
        url.host,
        url.port,
        timeout: const Duration(seconds: 5),
      );
      socket.destroy();
      return true;
    } catch (e) {
      debugPrint('API reachability check failed: $e');
      return false;
    }
  }

  /// Perform a comprehensive network health check
  static Future<NetworkStatus> checkNetworkHealth() async {
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      return NetworkStatus.noInternet;
    }

    final apiReachable = await isApiReachable();
    if (!apiReachable) {
      return NetworkStatus.apiUnreachable;
    }

    return NetworkStatus.healthy;
  }

  /// Get appropriate error message based on network status
  static String getNetworkErrorMessage(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.noInternet:
        return 'No internet connection. Please check your network settings.';
      case NetworkStatus.apiUnreachable:
        return 'Server is currently unreachable. Please try again later.';
      case NetworkStatus.healthy:
        return 'Network is healthy';
    }
  }

  /// Retry an operation with exponential backoff
  static Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;

        if (attempts >= maxRetries) {
          rethrow;
        }

        if (AppConfig.enableVerboseLogging) {
          debugPrint('Operation failed (attempt $attempts/$maxRetries): $e');
          debugPrint('Retrying in ${delay.inSeconds} seconds...');
        }

        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }

    throw Exception('Max retries exceeded');
  }

  /// Check if an error is network-related
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
        errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('connection') ||
        errorString.contains('handshake');
  }

  /// Format network errors with helpful suggestions
  static String formatNetworkError(dynamic error) {
    if (isNetworkError(error)) {
      return 'Connection problem. Please check your internet connection and try again.';
    }

    return ErrorFormatter.formatApiError(error);
  }
}

/// Enum representing different network status states
enum NetworkStatus { healthy, noInternet, apiUnreachable }

/// Extension to add user-friendly descriptions to NetworkStatus
extension NetworkStatusExtension on NetworkStatus {
  String get description {
    switch (this) {
      case NetworkStatus.healthy:
        return 'Network is healthy';
      case NetworkStatus.noInternet:
        return 'No internet connection';
      case NetworkStatus.apiUnreachable:
        return 'Server unreachable';
    }
  }

  bool get isHealthy => this == NetworkStatus.healthy;
  bool get hasConnectivityIssue => this != NetworkStatus.healthy;
}
