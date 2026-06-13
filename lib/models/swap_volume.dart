/// One entry in the `volumes` array returned by GET /api/blueprint/swap.
///
/// Represents a blueprint the player currently owns and could offer
/// as the sacrifice side of a swap.
class SwapVolume {
  final int blueprintId;
  final String name;
  final String img;

  /// How many volumes the player currently holds.
  final int qty;

  const SwapVolume({
    required this.blueprintId,
    required this.name,
    required this.img,
    required this.qty,
  });

  factory SwapVolume.fromJson(Map<String, dynamic> json) {
    return SwapVolume(
      blueprintId: int.tryParse(json['blueprint_id'].toString()) ?? 0,
      name:        json['name'] as String?                       ?? '',
      img:         json['img']  as String?                       ?? 'nothing.png',
      qty:         int.tryParse(json['qty'].toString())          ?? 0,
    );
  }
}
