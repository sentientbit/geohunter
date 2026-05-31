/// A material with a crafting affinity bonus for a research tech node.
/// Zipped with [Research.affinityPcts] — lengths are always equal.
class TechMaterial {
  final int id;
  final String name;
  final String img;

  const TechMaterial({
    required this.id,
    required this.name,
    required this.img,
  });

  factory TechMaterial.fromJson(Map<String, dynamic> json) {
    return TechMaterial(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      img: json['img'] as String? ?? '',
    );
  }
}
