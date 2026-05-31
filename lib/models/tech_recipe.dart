/// A craftable item unlocked by a research tech node.
/// Shown in the 3×2 Unlocked Recipes grid in the Discipline Effects panel.
class TechRecipe {
  final int id;
  final String name;
  final String img;

  /// true = player has researched enough to unlock this recipe in the Forge.
  final bool unlocked;

  const TechRecipe({
    required this.id,
    required this.name,
    required this.img,
    required this.unlocked,
  });

  factory TechRecipe.fromJson(Map<String, dynamic> json) {
    return TechRecipe(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      img: json['img'] as String? ?? '',
      // PHP may send bool true, int 1, or string "1"
      unlocked: json['unlocked'] == true ||
                json['unlocked'] == 1 ||
                json['unlocked'] == '1',
    );
  }
}
