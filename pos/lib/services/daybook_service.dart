import '../api/api_service.dart';
import '../api/endpoints.dart';

class DaybookService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getTodaysSummary() async {
    try {
      final response = await _apiService.get(
        Endpoints.daybookTodaysSummary,
        requiresAuth: true,
      );

      if (response['status'] == true) {
        return response['data'];
      } else {
        throw Exception(
          response['message'] ?? 'Failed to fetch today\'s summary',
        );
      }
    } catch (e) {
      throw Exception('Error fetching today\'s summary: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDaybookEntries({
    String? startDate,
    String? endDate,
  }) async {
    try {
      String endpoint = Endpoints.daybookEntries;

      List<String> queryParams = [];
      if (startDate != null) queryParams.add('startDate=$startDate');
      if (endDate != null) queryParams.add('endDate=$endDate');

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _apiService.get(endpoint, requiresAuth: true);

      if (response['status'] == true) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception(
          response['message'] ?? 'Failed to fetch daybook entries',
        );
      }
    } catch (e) {
      throw Exception('Error fetching daybook entries: $e');
    }
  }

  Future<Map<String, dynamic>> getDaybookSummary(String date) async {
    try {
      final response = await _apiService.get(
        '${Endpoints.daybookSummary}/$date',
        requiresAuth: true,
      );

      if (response['status'] == true) {
        return response['data'];
      } else {
        throw Exception(
          response['message'] ?? 'Failed to fetch daybook summary',
        );
      }
    } catch (e) {
      throw Exception('Error fetching daybook summary: $e');
    }
  }

  Future<Map<String, dynamic>> getDaybookByDate(String date) async {
    try {
      final response = await _apiService.get(
        '${Endpoints.daybookByDate}/$date',
        requiresAuth: true,
      );

      if (response['status'] == true) {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch daybook');
      }
    } catch (e) {
      throw Exception('Error fetching daybook: $e');
    }
  }

  String formatDateForApi(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  String getTodayDateString() {
    return formatDateForApi(DateTime.now());
  }
}
