import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/swap_response.dart';
import 'blueprint_swap_repository.dart';

/// Loads the swap state for a single discipline, keyed by [wantedBlueprintId].
///
/// Auto-disposed when the Study Detail screen closes.
///
/// Invalidate after:
///   - Agree Swap    → ref.invalidate(swapProvider(wantedBlueprintId))
///   - Cancel Swap   → ref.invalidate(swapProvider(wantedBlueprintId))
///   - Mine visit with swap-fulfilled blueprints → ref.invalidate(swapProvider)
///     (invalidates all family instances — fulfilled blueprint id may differ from
///     the discipline currently on screen)
final swapProvider =
    FutureProvider.family.autoDispose<SwapResponse, int>((ref, wantedBlueprintId) {
  return ref.read(blueprintSwapRepositoryProvider).getSwap(wantedBlueprintId);
});
