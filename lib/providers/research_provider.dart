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

/// Derived provider: player's total manuscript count.
/// Updates automatically whenever [researchProvider] refreshes
/// (after assemble, disassemble, or manual invalidation).
final manuscriptsProvider = Provider<int>((ref) {
  return ref.watch(researchProvider).valueOrNull?.manuscripts ?? 0;
});
