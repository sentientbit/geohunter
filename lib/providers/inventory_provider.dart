import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_response.dart';
import 'inventory_repository.dart';

/// Holds the player's full inventory (items + materials + blueprints).
///
/// Access from any ConsumerWidget:
///   `ref.watch(inventoryProvider)` → AsyncValue<InventoryResponse>
///   `ref.watch(inventoryProvider).valueOrNull` → InventoryResponse?
///
/// After any action that changes inventory (craft, disassemble, pickup):
///   `ref.invalidate(inventoryProvider)` — triggers a fresh POST /api/inventory
///   and rebuilds every widget watching this provider.
class InventoryNotifier extends AsyncNotifier<InventoryResponse> {
  @override
  Future<InventoryResponse> build() =>
      ref.read(inventoryRepositoryProvider).getInventory();
}

final inventoryProvider =
    AsyncNotifierProvider<InventoryNotifier, InventoryResponse>(
        InventoryNotifier.new);
