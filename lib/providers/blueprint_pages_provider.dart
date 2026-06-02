import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/blueprint_pages_response.dart';
import 'blueprint_pages_repository.dart';

/// Holds the player's blueprint page inventory + manuscript count.
/// Source: GET /api/blueprint/pages → { pages: [...], manuscripts: N }
///
/// Invalidate after any action that changes page or manuscript counts:
///   ref.invalidate(blueprintPagesProvider)  // after assemble or disassemble
class BlueprintPagesNotifier extends AsyncNotifier<BlueprintPagesResponse> {
  @override
  Future<BlueprintPagesResponse> build() =>
      ref.read(blueprintPagesRepositoryProvider).getPages();
}

final blueprintPagesProvider =
    AsyncNotifierProvider<BlueprintPagesNotifier, BlueprintPagesResponse>(
        BlueprintPagesNotifier.new);

/// Convenience provider — current Blank Manuscript count.
/// Updates automatically whenever [blueprintPagesProvider] refreshes.
final manuscriptsProvider = Provider<int>((ref) {
  return ref.watch(blueprintPagesProvider).valueOrNull?.manuscripts ?? 0;
});
