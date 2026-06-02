import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/research_response.dart';
import 'research_repository.dart';

/// Holds the player's research techs and blueprints.
///
/// After a successful study action:
///   ref.invalidate(researchProvider) — refreshes techs/blueprints
///   ref.invalidate(userProvider)    — refreshes coins/xp in drawer
class ResearchNotifier extends AsyncNotifier<ResearchResponse> {
  @override
  Future<ResearchResponse> build() =>
      ref.read(researchRepositoryProvider).getResearch();
}

final researchProvider =
    AsyncNotifierProvider<ResearchNotifier, ResearchResponse>(
        ResearchNotifier.new);

// manuscriptsProvider lives in blueprint_pages_provider.dart —
// it is derived from blueprintPagesProvider (GET /api/blueprint/pages)
// which is the authoritative source for the manuscript count.
