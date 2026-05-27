import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/forge_result.dart';
import 'api_provider.dart';

/// Handles the forge crafting action.
///
/// This is a mutation, not a queryable state — no AsyncNotifier is used.
/// After a successful craft, callers should:
///   ref.invalidate(inventoryProvider) — refreshes items/materials
///   ref.invalidate(userProvider)      — refreshes coins/xp in drawer
class ForgeRepository {
  final ApiProvider _api = ApiProvider();

  /// POST /api/forge/:blueprintId/:mat0/:mat1/:mat2
  Future<ForgeResult> craft(
      int blueprintId, int mat0, int mat1, int mat2) async {
    final response =
        await _api.post('/forge/$blueprintId/$mat0/$mat1/$mat2', {});
    return ForgeResult.fromJson(response);
  }
}

final forgeRepositoryProvider =
    Provider<ForgeRepository>((ref) => ForgeRepository());
