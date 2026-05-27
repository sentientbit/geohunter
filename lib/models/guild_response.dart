// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'guild.dart';

part 'guild_response.freezed.dart';
part 'guild_response.g.dart';

/// The endpoint returns { "guilds": [guildObj] } — unwrap index 0.
Guild _parseGuild(dynamic v) =>
    ((v ?? []) as List).isNotEmpty
        ? Guild.fromJson((v as List)[0])
        : Guild.blank();

/// Typed result of GET /api/guild/:id (single guild detail).
@Freezed(toJson: false)
class GuildResponse with _$GuildResponse {
  const GuildResponse._();

  const factory GuildResponse({
    @JsonKey(name: 'guilds', fromJson: _parseGuild)
    required Guild guild,
  }) = _GuildResponse;

  factory GuildResponse.fromJson(Map<String, dynamic> json) =>
      _$GuildResponseFromJson(json);

  static GuildResponse empty() => GuildResponse(guild: Guild.blank());
}
