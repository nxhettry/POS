import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static String? _authToken;
  final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  // Set authentication token
  static void setAuthToken(String token) {
    _authToken = token;
  }

  // Get authentication token
  static String? getAuthToken() {
    return _authToken;
  }

  // Clear authentication token
  static void clearAuthToken() {
    _authToken = null;
  }

  // Get headers with authentication
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {'Content-Type': 'application/json'};

    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<dynamic> get(String endpoint, {bool requiresAuth = false}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(includeAuth: requiresAuth),
      );

      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(includeAuth: requiresAuth),
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(includeAuth: requiresAuth),
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(includeAuth: requiresAuth),
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = false}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(includeAuth: requiresAuth),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      // Success response
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } else if (statusCode == 401) {
      // Unauthorized - clear token and throw
      clearAuthToken();
      throw Exception('Unauthorized access. Please login again.');
    } else if (statusCode == 403) {
      throw Exception('Access forbidden.');
    } else if (statusCode == 404) {
      throw Exception('Resource not found.');
    } else if (statusCode == 422) {
      // Validation error
      final errorBody = jsonDecode(response.body);
      throw Exception(
        'Validation error: ${errorBody['message'] ?? 'Invalid data'}',
      );
    } else if (statusCode == 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
