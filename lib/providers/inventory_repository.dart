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

  /// Toggles the lock flag on an item.
  ///
  /// Calls PATCH /api/inventory with {"item_id": itemId, "locked": 1|0}.
  /// Returns the new lock state as confirmed by the server.
  /// Throws [AppError] on server-side rejection.
  Future<bool> setLocked(int itemId, {required bool locked}) async {
    final response = await _api.patch('/inventory', {
      'item_id': itemId,
      'locked': locked ? 1 : 0,
    });
    // Server returns {"locked": true|false}
    final val = response['locked'];
    return val == true || val == 1 || val == '1';
  }
}

final inventoryRepositoryProvider =
    Provider<InventoryRepository>((ref) => InventoryRepository());
