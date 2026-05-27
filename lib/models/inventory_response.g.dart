// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InventoryResponseImpl _$$InventoryResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$InventoryResponseImpl(
      items: json['items'] == null ? const [] : _parseItems(json['items']),
      materials: json['materials'] == null
          ? const []
          : _parseMaterials(json['materials']),
      blueprints: json['blueprints'] == null
          ? const []
          : _parseBlueprints(json['blueprints']),
    );
