import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/blueprint_pages_response.dart';
import 'blueprint_pages_repository.dart';

/// Holds the player's blueprint page inventory.
/// Source: GET /api/blueprint/pages → { pages: [...] }
///
/// Invalidate after any action that changes page counts:
///   ref.invalidate(blueprintPagesProvider)  // after assemble
class BlueprintPagesNotifier extends AsyncNotifier<BlueprintPagesResponse> {
  @override
  Future<BlueprintPagesResponse> build() =>
      ref.read(blueprintPagesRepositoryProvider).getPages();
}

final blueprintPagesProvider =
    AsyncNotifierProvider<BlueprintPagesNotifier, BlueprintPagesResponse>(
        BlueprintPagesNotifier.new);
