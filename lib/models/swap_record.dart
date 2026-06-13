/// Model for a single active swap agreement returned by
/// GET /api/blueprint/swap as the `active_swap` field.
class SwapRecord {
  final int id;
  final int userId;

  /// The blueprint the player offered (sacrifice).
  final int blueprintId;
  final String blueprintName;
  final String blueprintImg;

  /// The blueprint the player wants to receive.
  final int wantedBlueprintId;
  final String wantedName;
  final String wantedImg;

  /// Volumes on each side (sacrifice qty == receive qty == count).
  final int count;

  final String createdAt;

  const SwapRecord({
    required this.id,
    required this.userId,
    required this.blueprintId,
    required this.blueprintName,
    required this.blueprintImg,
    required this.wantedBlueprintId,
    required this.wantedName,
    required this.wantedImg,
    required this.count,
    required this.createdAt,
  });

  factory SwapRecord.fromJson(Map<String, dynamic> json) {
    return SwapRecord(
      id:                 int.tryParse(json['id'].toString())                   ?? 0,
      userId:             int.tryParse(json['user_id'].toString())              ?? 0,
      blueprintId:        int.tryParse(json['blueprint_id'].toString())         ?? 0,
      blueprintName:      json['blueprint_name']    as String?                 ?? '',
      blueprintImg:       json['blueprint_img']     as String?                 ?? 'nothing.png',
      wantedBlueprintId:  int.tryParse(json['wanted_blueprint_id'].toString()) ?? 0,
      wantedName:         json['wanted_name']        as String?                ?? '',
      wantedImg:          json['wanted_img']         as String?                ?? 'nothing.png',
      count:              int.tryParse(json['count'].toString())               ?? 0,
      createdAt:          json['created_at']         as String?                ?? '',
    );
  }
}
