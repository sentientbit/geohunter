class Blueprint {
  int id = 0;
  String name = "";
  String img = "nothing.png";

  /// Nr of blueprint volumes the player currently holds.
  int nr = 0;

  /// Set to "swap" on blueprints returned from a mine visit that fulfilled
  /// an active swap agreement. Null for normal Library drops.
  String? source;

  Blueprint({
    required this.id,
    required this.name,
    required this.img,
    required this.nr,
    this.source,
  });

  factory Blueprint.blank() {
    return Blueprint(id: 0, name: "", img: "nothing.png", nr: 0);
  }

  Blueprint.fromJson(dynamic json) {
    if (json == null) return;
    id   = int.tryParse(json["id"].toString()) ?? 0;
    name = json["name"] as String? ?? '';
    img  = json["img"]  as String? ?? 'nothing.png';
    if (json.containsKey("nr")) {
      nr = int.tryParse(json["nr"].toString()) ?? 0;
    }
    // Mine drop response uses "learned" for the quantity awarded
    if (json.containsKey("learned")) {
      nr = int.tryParse(json["learned"].toString()) ?? nr;
    }
    if (json.containsKey("source")) {
      source = json["source"] as String?;
    }
  }
}
