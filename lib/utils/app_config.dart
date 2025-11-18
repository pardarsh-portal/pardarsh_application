/// Environment configuration manager
/// Handles different environments and their specific configurations
class AppConfig {
  static const String _currentEnvironment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'staging',
  );

  // Environment types
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';

  // Get current environment
  static String get environment => _currentEnvironment;

  // Check if running in development
  static bool get isDevelopment => _currentEnvironment == development;

  // Check if running in staging
  static bool get isStaging => _currentEnvironment == staging;

  // Check if running in production
  static bool get isProduction => _currentEnvironment == production;

  // API Configuration based on environment
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case development:
        return const String.fromEnvironment(
          'DEV_API_URL',
          defaultValue: 'http://localhost:5000/api',
        );
      case production:
        return const String.fromEnvironment(
          'PROD_API_URL',
          defaultValue: 'https://api.pardarsh.com/api',
        );
      case staging:
      default:
        return const String.fromEnvironment(
          'STAGING_API_URL',
          defaultValue: 'http://192.168.1.10:5000/api',
        );
    }
  }

  // Debug mode configuration
  static bool get isDebugMode {
    return isDevelopment ||
        const bool.fromEnvironment('DEBUG_MODE', defaultValue: false);
  }

  // Logging configuration
  static bool get enableVerboseLogging {
    return isDebugMode ||
        const bool.fromEnvironment('VERBOSE_LOGGING', defaultValue: false);
  }

  // Network timeout configuration
  static int get networkTimeoutSeconds {
    return const int.fromEnvironment('NETWORK_TIMEOUT', defaultValue: 30);
  }

  // Rate limiting configuration
  static int get maxRetries {
    return const int.fromEnvironment('MAX_RETRIES', defaultValue: 3);
  }

  // Feature flags
  static bool get enableReviewSubmission {
    return const bool.fromEnvironment(
      'ENABLE_REVIEW_SUBMISSION',
      defaultValue: true,
    );
  }

  static bool get enableOfflineMode {
    return const bool.fromEnvironment(
      'ENABLE_OFFLINE_MODE',
      defaultValue: false,
    );
  }

  // App metadata
  static String get appVersion {
    return const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
  }

  static String get buildNumber {
    return const String.fromEnvironment('BUILD_NUMBER', defaultValue: '1');
  }

  // Security configuration
  static bool get enableSecurityHeaders {
    return isProduction ||
        const bool.fromEnvironment('ENABLE_SECURITY', defaultValue: true);
  }

  static Duration get tokenRefreshInterval {
    final minutes = const int.fromEnvironment(
      'TOKEN_REFRESH_MINUTES',
      defaultValue: 15,
    );
    return Duration(minutes: minutes);
  }

  // Print configuration summary (for debugging)
  static void printConfig() {
    if (isDebugMode) {
      print('=== App Configuration ===');
      print('Environment: $environment');
      print('API Base URL: $apiBaseUrl');
      print('Debug Mode: $isDebugMode');
      print('Verbose Logging: $enableVerboseLogging');
      print('Network Timeout: ${networkTimeoutSeconds}s');
      print('Max Retries: $maxRetries');
      print('App Version: $appVersion ($buildNumber)');
      print('========================');
    }
  }
}
