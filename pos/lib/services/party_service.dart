import '../api/api_service.dart';
import '../api/endpoints.dart';
import '../models/models.dart';

class PartyService {
  final ApiService _apiService = ApiService();

  Future<List<Party>> getAllParties() async {
    try {
      print('PartyService: Fetching all parties from ${Endpoints.parties}');
      final response = await _apiService.get(
        Endpoints.parties,
        requiresAuth: false,
      );

      print('PartyService: Response received: $response');

      if (response['status'] == true && response['data'] != null) {
        final List<dynamic> partyList = response['data'];
        print('PartyService: Found ${partyList.length} parties');
        return partyList.map((party) => Party.fromJson(party)).toList();
      }
      print('PartyService: No valid data in response');
      return [];
    } catch (e) {
      print('PartyService: Error fetching parties: $e');
      throw Exception('Failed to fetch parties: $e');
    }
  }

  Future<List<Party>> getPartiesByType(String type) async {
    try {
      final response = await _apiService.get(
        '${Endpoints.partiesByType}/$type',
        requiresAuth: true,
      );

      if (response['status'] == true && response['data'] != null) {
        final List<dynamic> partyList = response['data'];
        return partyList.map((party) => Party.fromJson(party)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch parties by type: $e');
    }
  }

  Future<List<Party>> getActiveParties() async {
    try {
      final response = await _apiService.get(
        Endpoints.activeParties,
        requiresAuth: true,
      );

      if (response['status'] == true && response['data'] != null) {
        final List<dynamic> partyList = response['data'];
        return partyList.map((party) => Party.fromJson(party)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch active parties: $e');
    }
  }

  Future<Party?> getPartyById(int id) async {
    try {
      final response = await _apiService.get(
        '${Endpoints.partyById}/$id',
        requiresAuth: true,
      );

      if (response['status'] == true && response['data'] != null) {
        return Party.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch party: $e');
    }
  }

  Future<Party> createParty(Party party) async {
    try {
      final response = await _apiService.post(
        Endpoints.parties,
        party.toJson(),
        requiresAuth: true,
      );

      if (response['status'] == true && response['data'] != null) {
        return Party.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to create party');
      }
    } catch (e) {
      throw Exception('Failed to create party: $e');
    }
  }

  Future<Party> updateParty(int id, Party party) async {
    try {
      final response = await _apiService.put(
        '${Endpoints.partyById}/$id',
        party.toJson(),
        requiresAuth: true,
      );

      if (response['status'] == true && response['data'] != null) {
        return Party.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to update party');
      }
    } catch (e) {
      throw Exception('Failed to update party: $e');
    }
  }

  Future<bool> deleteParty(int id) async {
    try {
      final response = await _apiService.delete(
        '${Endpoints.partyById}/$id',
        requiresAuth: true,
      );

      return response['status'] == true;
    } catch (e) {
      throw Exception('Failed to delete party: $e');
    }
  }

  Future<List<Party>> searchParties(String query, {String? type}) async {
    try {
      List<Party> parties;

      if (type != null && type.isNotEmpty) {
        parties = await getPartiesByType(type);
      } else {
        parties = await getAllParties();
      }

      return parties
          .where(
            (party) => party.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search parties: $e');
    }
  }
}
