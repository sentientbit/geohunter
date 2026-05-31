import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/blueprint_page.dart';
import 'blueprint_pages_repository.dart';

/// Holds the player's blueprint page inventory (GET /api/blueprint/pages).
///
/// Invalidate after a successful assemble action:
///   ref.invalidate(blueprintPagesProvider)
class BlueprintPagesNotifier extends AsyncNotifier<List<BlueprintPage>> {
  @override
  Future<List<BlueprintPage>> build() =>
      ref.read(blueprintPagesRepositoryProvider).getPages();
}

final blueprintPagesProvider =
    AsyncNotifierProvider<BlueprintPagesNotifier, List<BlueprintPage>>(
        BlueprintPagesNotifier.new);
