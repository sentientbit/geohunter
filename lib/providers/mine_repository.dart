import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mine_detail_response.dart';
import 'api_provider.dart';

/// Wraps GET /api/mine/:id — the loot-claim action.
///
/// Errors propagate as [AppError]; callers should differentiate:
///   err.code == 'COOLDOWN_ACTIVE'  → show wait time from err.message
///   err.code == 'FORBIDDEN'        → show distance error from err.message
///   otherwise                      → generic err.show(context)
class MineRepository {
  final ApiProvider _api = ApiProvider();

  /// Claims loot from [mineId].
  ///
  /// If [enc] is non-null the proximity check is bypassed and 0.01 coins are
  /// deducted (purchase-flow token obtained from the store screen).
  Future<MineDetailResponse> getMine(int mineId, {String? enc}) async {
    final path = enc != null ? '/mine/$mineId?enc=$enc' : '/mine/$mineId';
    final response = await _api.get(path);
    return MineDetailResponse.fromJson(response);
  }
}

final mineRepositoryProvider =
    Provider<MineRepository>((ref) => MineRepository());
