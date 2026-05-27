// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'guild_list_response.freezed.dart';
part 'guild_list_response.g.dart';

int _parseInt(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;

/// Count the users from a users array (the list response sends the full users
/// array, but we only need the count for the guild list view).
int _countUsers(dynamic v) => v is List ? v.length : _parseInt(v);

List<GuildSummary> _parseGuilds(dynamic v) => ((v ?? []) as List)
    .map((e) => GuildSummary.fromJson(e as Map<String, dynamic>))
    .toList();

/// Lightweight guild info used in the public guild list (GET /api/guilds).
///
/// Does NOT include pictures or full user objects — use GuildResponse for
/// the full detail view.
@Freezed(toJson: false)
class GuildSummary with _$GuildSummary {
  const factory GuildSummary({
    @JsonKey(name: 'id', fromJson: _parseInt) @Default(0) int id,
    @JsonKey(name: 'guid') @Default('') String guid,
    @JsonKey(name: 'name') @Default('') String name,
    @JsonKey(name: 'is_hidden', fromJson: _parseInt) @Default(0) int isHidden,
    @JsonKey(name: 'is_locked', fromJson: _parseInt) @Default(0) int isLocked,

    /// Derived from the length of the users array in the response.
    @JsonKey(name: 'users', fromJson: _countUsers) @Default(0) int nrUsers,
  }) = _GuildSummary;

  factory GuildSummary.fromJson(Map<String, dynamic> json) =>
      _$GuildSummaryFromJson(json);
}

/// Typed result of GET /api/guilds.
@Freezed(toJson: false)
class GuildListResponse with _$GuildListResponse {
  const GuildListResponse._();

  const factory GuildListResponse({
    @JsonKey(name: 'guilds', fromJson: _parseGuilds)
    @Default([])
    List<GuildSummary> guilds,
  }) = _GuildListResponse;

  factory GuildListResponse.fromJson(Map<String, dynamic> json) =>
      _$GuildListResponseFromJson(json);

  static GuildListResponse empty() => const GuildListResponse();
}
