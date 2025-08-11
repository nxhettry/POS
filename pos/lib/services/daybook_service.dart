import '../api/api_service.dart';
import '../api/endpoints.dart';

class DaybookService {
  final ApiService _apiService = ApiService();

  // Get today's daybook summary
  Future<Map<String, dynamic>> getTodaysSummary() async {
    try {
      final response = await _apiService.get(
        Endpoints.daybookTodaysSummary,
        requiresAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch today\'s summary');
      }
    } catch (e) {
      throw Exception('Error fetching today\'s summary: $e');
    }
  }

  // Get daybook entries with optional date range
  Future<List<Map<String, dynamic>>> getDaybookEntries({
    String? startDate,
    String? endDate,
  }) async {
    try {
      String endpoint = Endpoints.daybookEntries;
      
      // Add query parameters if provided
      List<String> queryParams = [];
      if (startDate != null) queryParams.add('startDate=$startDate');
      if (endDate != null) queryParams.add('endDate=$endDate');
      
      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _apiService.get(
        endpoint,
        requiresAuth: true,
      );
      
      if (response['success'] == true) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch daybook entries');
      }
    } catch (e) {
      throw Exception('Error fetching daybook entries: $e');
    }
  }

  // Get daybook summary for a specific date
  Future<Map<String, dynamic>> getDaybookSummary(String date) async {
    try {
      final response = await _apiService.get(
        '${Endpoints.daybookSummary}/$date',
        requiresAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch daybook summary');
      }
    } catch (e) {
      throw Exception('Error fetching daybook summary: $e');
    }
  }

  // Get daybook by date
  Future<Map<String, dynamic>> getDaybookByDate(String date) async {
    try {
      final response = await _apiService.get(
        '${Endpoints.daybookByDate}/$date',
        requiresAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch daybook');
      }
    } catch (e) {
      throw Exception('Error fetching daybook: $e');
    }
  }

  // Helper method to format date for API
  String formatDateForApi(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  // Helper method to get today's date string
  String getTodayDateString() {
    return formatDateForApi(DateTime.now());
  }
}
