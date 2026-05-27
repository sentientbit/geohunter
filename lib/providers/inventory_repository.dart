import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_response.dart';
import 'api_provider.dart';

/// Fetches the player's full inventory from the server.
///
/// Passes `types: [0]` which is the "show all" sentinel — the backend strips
/// 0 via array_filter before building the WHERE IN clause.
class InventoryRepository {
  final ApiProvider _api = ApiProvider();

  Future<InventoryResponse> getInventory() async {
    final response = await _api.post('/inventory', {'types': [0]});
    return InventoryResponse.fromJson(response);
  }
}

final inventoryRepositoryProvider =
    Provider<InventoryRepository>((ref) => InventoryRepository());
