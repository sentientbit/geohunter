///
//import 'package:logger/logger.dart';

///
class Materialmodel {
  ///
  int id = 0;

  ///
  String name = "";

  ///
  String img = "nothing.png";

  /// Total nr of materials in player posession
  int nr = 0;

  /// Nr of materials needed for an operation
  int needed = 0;

  ///
  Materialmodel({
    required this.id,
    required this.name,
    required this.img,
    required this.nr,
    required this.needed,
  });

  ///
  factory Materialmodel.blank() {
    return Materialmodel(
      id: 0,
      name: "",
      img: "nothing.png",
      nr: 0,
      needed: 0,
    );
  }

  ///
  Materialmodel.fromJson(dynamic json) {
    if (json == null) {
      return;
    }
    id = int.tryParse(json["id"].toString()) ?? 0;
    name = json["name"];
    img = json["img"];
    nr = int.tryParse(json["nr"].toString()) ?? 0;
    if (json.containsKey("needed")) {
      needed = int.tryParse(json["needed"].toString()) ?? 0;
    }
  }
}
