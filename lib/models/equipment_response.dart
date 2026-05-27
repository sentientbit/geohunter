// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'item.dart';

part 'equipment_response.freezed.dart';
part 'equipment_response.g.dart';

/// An equipped item with its grid slot position (1-based).
class EquippedItem {
  final Item item;

  /// 1-based slot index (subtract 1 for List indexing).
  final int placement;

  const EquippedItem({required this.item, required this.placement});
}

List<EquippedItem> _parseEquipment(dynamic v) => ((v ?? []) as List).map((e) {
      final placement =
          int.tryParse(e['placement']?.toString() ?? '0') ?? 0;
      return EquippedItem(item: Item.fromJson(e), placement: placement);
    }).toList();

/// Typed result of GET /api/equipment.
///
/// Dashboard state fields (coins, xp, guild, etc.) are intentionally ignored
/// here — userProvider handles those via ref.invalidate(userProvider).
@Freezed(toJson: false)
class EquipmentResponse with _$EquipmentResponse {
  const EquipmentResponse._();

  const factory EquipmentResponse({
    @JsonKey(name: 'equipment', fromJson: _parseEquipment)
    @Default([])
    List<EquippedItem> equipment,
  }) = _EquipmentResponse;

  factory EquipmentResponse.fromJson(Map<String, dynamic> json) =>
      _$EquipmentResponseFromJson(json);

  static EquipmentResponse empty() => const EquipmentResponse();
}
