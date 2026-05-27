// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'forge_result.freezed.dart';
part 'forge_result.g.dart';

int _parseInt(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;

/// Unwrap the first element of the items array returned by the forge endpoint.
ForgeItem _parseFirstItem(dynamic v) =>
    ((v ?? []) as List).isNotEmpty
        ? ForgeItem.fromJson((v as List)[0] as Map<String, dynamic>)
        : const ForgeItem();

/// A single crafted item as returned by POST /api/forge/...
@Freezed(toJson: false)
class ForgeItem with _$ForgeItem {
  const factory ForgeItem({
    @JsonKey(name: 'nr', fromJson: _parseInt) @Default(0) int nr,
    @JsonKey(name: 'img') @Default('') String img,
    @JsonKey(name: 'name') @Default('') String name,
    @JsonKey(name: 'rarity', fromJson: _parseInt) @Default(0) int rarity,
  }) = _ForgeItem;

  factory ForgeItem.fromJson(Map<String, dynamic> json) =>
      _$ForgeItemFromJson(json);
}

/// Typed result of POST /api/forge/:blueprintId/:mat0/:mat1/:mat2.
///
/// This is a mutation result — no AsyncNotifierProvider is needed.
/// Dashboard state fields (coins, xp, guild, etc.) are intentionally ignored
/// here — callers should call ref.invalidate(userProvider) after a successful
/// forge to refresh the user's wallet and stats.
@Freezed(toJson: false)
class ForgeResult with _$ForgeResult {
  const ForgeResult._();

  const factory ForgeResult({
    @JsonKey(name: 'items', fromJson: _parseFirstItem)
    required ForgeItem item,
  }) = _ForgeResult;

  factory ForgeResult.fromJson(Map<String, dynamic> json) =>
      _$ForgeResultFromJson(json);
}
