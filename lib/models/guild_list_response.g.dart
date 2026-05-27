// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GuildSummaryImpl _$$GuildSummaryImplFromJson(Map<String, dynamic> json) =>
    _$GuildSummaryImpl(
      id: json['id'] == null ? 0 : _parseInt(json['id']),
      guid: json['guid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isHidden: json['is_hidden'] == null ? 0 : _parseInt(json['is_hidden']),
      isLocked: json['is_locked'] == null ? 0 : _parseInt(json['is_locked']),
      nrUsers: json['users'] == null ? 0 : _countUsers(json['users']),
    );

_$GuildListResponseImpl _$$GuildListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GuildListResponseImpl(
      guilds: json['guilds'] == null ? const [] : _parseGuilds(json['guilds']),
    );
