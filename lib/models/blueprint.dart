///
//import 'package:logger/logger.dart';

///
class Blueprint {
  ///
  int id = 0;

  ///
  String name = "";

  ///
  String img = "nothing.png";

  /// Nr of blueprints available to the player
  int nr = 0;

  ///
  Blueprint({
    required this.id,
    required this.name,
    required this.img,
    required this.nr,
  });

  ///
  factory Blueprint.blank() {
    return Blueprint(
      id: 0,
      name: "",
      img: "nothing.png",
      nr: 0,
    );
  }

  ///
  Blueprint.fromJson(dynamic json) {
    if (json == null) {
      return;
    }
    id = int.tryParse(json["id"].toString()) ?? 0;
    name = json["name"];
    img = json["img"];
    nr = int.tryParse(json["nr"].toString()) ?? 0;
  }
}
