// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'blueprint.dart';
import 'item.dart';
import 'materialmodel.dart';

part 'inventory_response.freezed.dart';
part 'inventory_response.g.dart';

List<Item> _parseItems(dynamic v) =>
    ((v ?? []) as List).map((e) => Item.fromJson(e)).toList();

List<Materialmodel> _parseMaterials(dynamic v) =>
    ((v ?? []) as List).map((e) => Materialmodel.fromJson(e)).toList();

List<Blueprint> _parseBlueprints(dynamic v) =>
    ((v ?? []) as List).map((e) => Blueprint.fromJson(e)).toList();

/// Typed result of POST /api/inventory.
///
/// `items`      — equipment/consumables the player owns
/// `materials`  — crafting raw materials
/// `blueprints` — always [] currently; typed safely for future use
@Freezed(toJson: false)
class InventoryResponse with _$InventoryResponse {
  const InventoryResponse._();

  const factory InventoryResponse({
    @JsonKey(name: 'items', fromJson: _parseItems)
    @Default([])
    List<Item> items,
    @JsonKey(name: 'materials', fromJson: _parseMaterials)
    @Default([])
    List<Materialmodel> materials,
    @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
    @Default([])
    List<Blueprint> blueprints,
  }) = _InventoryResponse;

  factory InventoryResponse.fromJson(Map<String, dynamic> json) =>
      _$InventoryResponseFromJson(json);

  static InventoryResponse empty() => const InventoryResponse();
}
