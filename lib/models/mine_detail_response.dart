import 'blueprint.dart';
import 'item.dart';
import 'materialmodel.dart';

/// Result of GET /api/mine/:id — the loot-claim action.
///
/// The GET is intentionally mutating: it records the visit, awards +1 XP,
/// and drops items / materials / blueprints based on the point type.
///
/// Error codes propagated as [AppError.code]:
///   COOLDOWN_ACTIVE — visited too recently; message contains the wait time.
///   FORBIDDEN       — player is too far away; message contains the distance.
///
/// Blueprints only drop at Library points (ico == 7).
/// Show blueprint celebration UI only when [blueprints] is non-empty.
///
/// [pages] — blueprint pages written from marked manuscripts. Only present
/// for Library mines (ico == 7). The server converts all marked_manuscripts
/// for this player into real specific pages on each Library visit and returns
/// them here. Empty list = no manuscripts were marked before the visit.
///
/// Optional enc token: GET /api/mine/:id?enc=<token> bypasses proximity
/// and deducts 0.01 coins (purchase-flow path).
class MineDetailResponse {
  final List<Item> items;
  final List<Materialmodel> materials;
  final List<Blueprint> blueprints;

  /// How many blank manuscripts were converted into specific pages on this visit.
  ///
  /// The converted pages themselves appear in [blueprints] — they are merged
  /// server-side so the loot dialog renders everything in one grid.
  /// This count is kept separately so Flutter can detect that a conversion
  /// happened and refresh [blueprintPagesProvider] / [researchProvider].
  final int manuscriptsConverted;

  const MineDetailResponse({
    required this.items,
    required this.materials,
    required this.blueprints,
    this.manuscriptsConverted = 0,
  });

  factory MineDetailResponse.fromJson(Map<String, dynamic> json) {
    return MineDetailResponse(
      items: ((json['items'] ?? []) as List)
          .map((e) => Item.fromJson(e))
          .toList(),
      materials: ((json['materials'] ?? []) as List)
          .map((e) => Materialmodel.fromJson(e))
          .toList(),
      blueprints: ((json['blueprints'] ?? []) as List)
          .map((e) => Blueprint.fromJson(e))
          .toList(),
      manuscriptsConverted:
          int.tryParse((json['manuscripts_converted'] ?? 0).toString()) ?? 0,
    );
  }
}
