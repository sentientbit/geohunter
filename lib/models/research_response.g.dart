// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'research_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ResearchResponseImpl _$$ResearchResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ResearchResponseImpl(
      techs: json['techs'] == null ? const [] : _parseTechs(json['techs']),
      blueprints: json['blueprints'] == null
          ? const []
          : _parseBlueprints(json['blueprints']),
      manuscripts: (json['manuscripts'] as num?)?.toInt() ?? 0,
    );
