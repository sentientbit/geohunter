import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/swap_record.dart';
import '../models/swap_response.dart';
import 'api_provider.dart';

/// Wraps GET / POST / DELETE /api/blueprint/swap.
class BlueprintSwapRepository {
  final ApiProvider _api = ApiProvider();

  /// GET /api/blueprint/swap?wanted_blueprint_id=X
  ///
  /// Returns the player's active swap (if any), the max count at their current
  /// mastery for [wantedBlueprintId], and their full blueprint inventory.
  Future<SwapResponse> getSwap(int wantedBlueprintId) async {
    final response =
        await _api.get('/blueprint/swap?wanted_blueprint_id=$wantedBlueprintId');
    return SwapResponse.fromJson(response);
  }

  /// POST /api/blueprint/swap
  ///
  /// Creates a swap agreement. Deducts [count] volumes of [blueprintId]
  /// immediately. Returns the newly created [SwapRecord].
  Future<SwapRecord> agreeSwap({
    required int wantedBlueprintId,
    required int blueprintId,
    required int count,
  }) async {
    final response = await _api.post('/blueprint/swap', {
      'wanted_blueprint_id': wantedBlueprintId,
      'blueprint_id': blueprintId,
      'count': count,
    });
    return SwapRecord.fromJson(response['swap'] as Map<String, dynamic>);
  }

  /// DELETE /api/blueprint/swap
  ///
  /// Cancels the active swap for [wantedBlueprintId]. Refunds the sacrifice
  /// volumes immediately.
  Future<void> cancelSwap(int wantedBlueprintId) async {
    await _api.delete('/blueprint/swap', {
      'wanted_blueprint_id': wantedBlueprintId,
    });
  }
}

final blueprintSwapRepositoryProvider =
    Provider<BlueprintSwapRepository>((ref) => BlueprintSwapRepository());
