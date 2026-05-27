import 'blueprint.dart';
import 'item.dart';
import 'materialmodel.dart';

/// Typed result of POST /api/inventory.
///
/// `items`      — equipment/consumables the player owns
/// `materials`  — crafting raw materials
/// `blueprints` — always [] currently; typed safely for future use
class InventoryResponse {
  final List<Item> items;
  final List<Materialmodel> materials;
  final List<Blueprint> blueprints;

  const InventoryResponse({
    required this.items,
    required this.materials,
    required this.blueprints,
  });

  factory InventoryResponse.empty() => const InventoryResponse(
        items: [],
        materials: [],
        blueprints: [],
      );

  factory InventoryResponse.fromJson(Map<String, dynamic> json) {
    return InventoryResponse(
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
