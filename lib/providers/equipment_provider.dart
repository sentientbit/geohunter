import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/equipment_response.dart';
import 'equipment_repository.dart';

/// Holds the player's currently equipped items.
///
/// After equipping or unequipping an item:
///   ref.invalidate(equipmentProvider) — refreshes the equipment grid
///   ref.invalidate(userProvider)      — refreshes stats in drawer
class EquipmentNotifier extends AsyncNotifier<EquipmentResponse> {
  @override
  Future<EquipmentResponse> build() =>
      ref.read(equipmentRepositoryProvider).getEquipment();
}

final equipmentProvider =
    AsyncNotifierProvider<EquipmentNotifier, EquipmentResponse>(
        EquipmentNotifier.new);
