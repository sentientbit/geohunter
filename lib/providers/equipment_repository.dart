import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/equipment_response.dart';
import 'api_provider.dart';

/// Fetches the player's currently equipped items from the server.
class EquipmentRepository {
  final ApiProvider _api = ApiProvider();

  Future<EquipmentResponse> getEquipment() async {
    final response = await _api.get('/equipment');
    return EquipmentResponse.fromJson(response);
  }
}

final equipmentRepositoryProvider =
    Provider<EquipmentRepository>((ref) => EquipmentRepository());
