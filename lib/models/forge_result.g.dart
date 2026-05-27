// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forge_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ForgeItemImpl _$$ForgeItemImplFromJson(Map<String, dynamic> json) =>
    _$ForgeItemImpl(
      nr: json['nr'] == null ? 0 : _parseInt(json['nr']),
      img: json['img'] as String? ?? '',
      name: json['name'] as String? ?? '',
      rarity: json['rarity'] == null ? 0 : _parseInt(json['rarity']),
    );

_$ForgeResultImpl _$$ForgeResultImplFromJson(Map<String, dynamic> json) =>
    _$ForgeResultImpl(
      item: _parseFirstItem(json['items']),
    );
