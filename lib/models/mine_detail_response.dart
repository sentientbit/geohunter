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
/// Optional enc token: GET /api/mine/:id?enc=<token> bypasses proximity
/// and deducts 0.01 coins (purchase-flow path).
class MineDetailResponse {
  final List<Item> items;
  final List<Materialmodel> materials;
  final List<Blueprint> blueprints;

  const MineDetailResponse({
    required this.items,
    required this.materials,
    required this.blueprints,
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
    );
  }
}
