import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/secure_storgae.dart';
import '../utils/app_config.dart';

class ApiService {
  String get baseUrl => apiBaseUrl;
  Duration get timeout => Duration(seconds: AppConfig.networkTimeoutSeconds);

  Future<Map<String, String>> _getHeaders({String? customToken}) async {
    final token = customToken ?? await SecureStorage.readToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
    String? customToken,
  }) async {
    try {
      final headers = await _getHeaders(customToken: customToken);
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
    bool requireAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(customToken: token);
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = true,
    String? customToken,
  }) async {
    try {
      final headers = await _getHeaders(customToken: customToken);
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requireAuth = true,
    String? customToken,
  }) async {
    try {
      final headers = await _getHeaders(customToken: customToken);
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    // Check if response body is empty
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true};
      } else {
        throw ApiException('Empty response from server', response.statusCode);
      }
    }

    final dynamic decodedBody;
    try {
      decodedBody = json.decode(response.body);
    } catch (e) {
      // If JSON parsing fails, return the raw response body for debugging
      print('JSON Parse Error: ${response.body}');
      throw Exception(
        'Invalid JSON response from server. Response: ${response.body}',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decodedBody is Map<String, dynamic>) {
        return decodedBody;
      } else if (decodedBody is List) {
        return {'data': decodedBody};
      } else {
        return {'data': decodedBody};
      }
    } else {
      String errorMessage = 'Unknown error occurred';

      if (decodedBody is Map<String, dynamic>) {
        errorMessage =
            decodedBody['message'] ??
            decodedBody['error'] ??
            decodedBody['detail'] ??
            'Request failed with status ${response.statusCode}';
      } else if (decodedBody is String) {
        errorMessage = decodedBody;
      } else {
        errorMessage =
            'Request failed with status ${response.statusCode}. Response: ${response.body}';
      }

      if (response.statusCode == 401) {
        // Handle unauthorized access
        SecureStorage.deleteToken();
        throw UnauthorizedException(errorMessage);
      } else if (response.statusCode == 403) {
        throw ForbiddenException(errorMessage);
      } else if (response.statusCode == 404) {
        throw NotFoundException(errorMessage);
      } else if (response.statusCode >= 500) {
        throw ServerException(errorMessage);
      }

      throw ApiException(errorMessage, response.statusCode);
    }
  }
}

// Custom Exception Classes
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, 403);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 404);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message, 500);
}
