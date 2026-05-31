// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'blueprint.dart';
import 'research.dart';

part 'research_response.freezed.dart';
part 'research_response.g.dart';

List<Research> _parseTechs(dynamic v) =>
    ((v ?? []) as List).map((e) => Research.fromJson(e)).toList();

List<Blueprint> _parseBlueprints(dynamic v) =>
    ((v ?? []) as List).map((e) => Blueprint.fromJson(e)).toList();

/// Typed result of GET /api/research.
///
/// Dashboard state fields (coins, xp, guild, etc.) are intentionally ignored
/// here — userProvider handles those via ref.invalidate(userProvider).
@Freezed(toJson: false)
class ResearchResponse with _$ResearchResponse {
  const ResearchResponse._();

  const factory ResearchResponse({
    @JsonKey(name: 'techs', fromJson: _parseTechs)
    @Default([])
    List<Research> techs,
    @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
    @Default([])
    List<Blueprint> blueprints,
    /// Total manuscripts the player currently holds.
    /// Sent at the root of GET /api/research.
    @Default(0) int manuscripts,
  }) = _ResearchResponse;

  factory ResearchResponse.fromJson(Map<String, dynamic> json) =>
      _$ResearchResponseFromJson(json);

  static ResearchResponse empty() => const ResearchResponse();
}
