import 'swap_record.dart';
import 'swap_volume.dart';

/// Unwrapped payload from GET /api/blueprint/swap?wanted_blueprint_id=X.
class SwapResponse {
  /// The player's earliest active swap, regardless of which wanted_blueprint_id
  /// was requested. Null when the player has no active swap at all.
  ///
  /// Flutter must compare [activeSwap.wantedBlueprintId] against the current
  /// discipline's blueprint ID to decide which UI state to show.
  final SwapRecord? activeSwap;

  /// Maximum volumes the player may offer for this discipline at their current
  /// mastery level. Formula: round(4 × (craftingLevel + 1) ^ 1.8).
  final int maxCount;

  /// Full blueprint inventory — unfiltered. Flutter applies
  ///   qty >= chosenCount && blueprintId != wantedBlueprintId
  /// when building the sacrifice dropdown.
  final List<SwapVolume> volumes;

  const SwapResponse({
    required this.activeSwap,
    required this.maxCount,
    required this.volumes,
  });

  factory SwapResponse.fromJson(Map<String, dynamic> json) {
    final rawSwap = json['active_swap'];
    final SwapRecord? activeSwap = rawSwap is Map<String, dynamic>
        ? SwapRecord.fromJson(rawSwap)
        : null;

    final int maxCount =
        int.tryParse((json['max_count'] ?? 4).toString()) ?? 4;

    final rawVolumes = json['volumes'];
    final List<SwapVolume> volumes = rawVolumes is List
        ? rawVolumes
            .map((e) => SwapVolume.fromJson(e as Map<String, dynamic>))
            .toList()
        : [];

    return SwapResponse(
      activeSwap: activeSwap,
      maxCount: maxCount,
      volumes: volumes,
    );
  }
}
