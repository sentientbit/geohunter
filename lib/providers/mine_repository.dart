import 'package:encrypt/encrypt.dart' as enq;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mine_detail_response.dart';
import '../models/secret.dart';
import 'api_provider.dart';

/// Wraps GET /api/mine/:id — the loot-claim action.
///
/// Errors propagate as [AppError]; callers should differentiate:
///   err.code == 'COOLDOWN_ACTIVE'  → show wait time from err.message
///   err.code == 'FORBIDDEN'        → show distance error from err.message
///   otherwise                      → generic err.show(context)
class MineRepository {
  final ApiProvider _api = ApiProvider();

  /// Claims loot from [mineId] using proximity (player is physically nearby).
  ///
  /// If [enc] is non-null the proximity check is bypassed and 0.01 coins are
  /// deducted (purchase-flow token obtained from the store screen).
  Future<MineDetailResponse> getMine(int mineId, {String? enc}) async {
    final path = enc != null ? '/mine/$mineId?enc=$enc' : '/mine/$mineId';
    final response = await _api.get(path);
    return MineDetailResponse.fromJson(response);
  }

  /// Claims loot from [mineId] remotely (Places screen / paid visit).
  ///
  /// Generates the AES-256-CBC enc token internally so callers don't need to
  /// handle cryptography.  Deducts 0.01 coins server-side.
  ///
  /// The IV is built from the first 16 URL-safe chars of a random base64 string
  /// (+→p, =→e, /→s) so it survives query-string encoding without escaping.
  Future<MineDetailResponse> getMineRemote(int mineId) async {
    final secret =
        await SecretLoader(secretPath: 'assets/secrets.json').load();
    final key = enq.Key.fromBase64(secret.enqKey);

    final rnd    = enq.IV.fromSecureRandom(32);
    final ivStr  = rnd.base64
        .replaceAll('+', 'p')
        .replaceAll('=', 'e')
        .replaceAll('/', 's')
        .substring(0, 16);
    final iv         = enq.IV.fromUtf8(ivStr);
    final encrypter  = enq.Encrypter(enq.AES(key, mode: enq.AESMode.cbc));
    final payload    = '{"mine_id":$mineId,"type":"","amount":0}';
    final encrypted  = encrypter.encrypt(payload, iv: iv);
    final encToken   = Uri.encodeComponent(ivStr + encrypted.base64);

    return getMine(mineId, enc: encToken);
  }
}

final mineRepositoryProvider =
    Provider<MineRepository>((ref) => MineRepository());
