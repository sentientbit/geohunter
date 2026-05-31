/// A single blueprint page — the new base-level collectible dropped at
/// Library mines (ico == 7).
///
/// Pages are assembled into blueprint volumes via
/// POST /api/blueprint/assemble { "page_id": id }.
/// The server reads [pagesRequired] from DB and consumes exactly that many.
class BlueprintPage {
  /// page_id — used as the body of POST /api/blueprint/assemble.
  final int id;

  /// Cross-reference to the Blueprint (volume) this page assembles into.
  final int blueprintId;

  ///
  final String name;

  ///
  final String img;

  /// How many of this page the player currently holds.
  final int quantity;

  const BlueprintPage({
    required this.id,
    required this.blueprintId,
    required this.name,
    required this.img,
    required this.quantity,
  });

  factory BlueprintPage.fromJson(Map<String, dynamic> json) {
    return BlueprintPage(
      id: int.tryParse(json['id'].toString()) ?? 0,
      blueprintId:
          int.tryParse((json['blueprint_id'] ?? 0).toString()) ?? 0,
      name: json['name'] as String? ?? '',
      img: json['img'] as String? ?? 'nothing.png',
      quantity: int.tryParse((json['quantity'] ?? 0).toString()) ?? 0,
    );
  }
}
