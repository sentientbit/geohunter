///
import '../models/blueprint.dart';
import '../models/item.dart';
import '../models/materialmodel.dart';
import '../shared/constants.dart';

///
class Mine {
  ///
  int id = 0;

  ///
  Geometry geometry;

  /// 1 = mine, 2 = player
  int category = 0;

  ///
  Properties properties;

  ///
  String lastVisited;

  ///
  double distanceToPoint = 0.0;

  ///
  List<Item> items = [];

  ///
  List<Materialmodel> materials = [];

  ///
  List<Blueprint> blueprints = [];

  ///
  Mine(dynamic json, this.category, {LtLn location = const LtLn(51.5, 0)}) {
    id = int.parse(json["id"].toString());
    if (json["last_visited"] != null && json["last_visited"] != "") {
      lastVisited = json["last_visited"];
    } else {
      lastVisited = "1980-01-01 01:01:01Z";
    }
    geometry = Geometry.fromJson(json["geometry"]);
    properties = Properties.fromJson(json["properties"]);
    final x = sphericalToCartesian(
      geometry.coordinates[1],
      geometry.coordinates[0],
    );
    final y = sphericalToCartesian(location.latitude, location.longitude);
    distanceToPoint = doubleDistance(x, y);
  }

  ///
  void addItem(dynamic value) {
    items.add(Item.fromJson(value));
  }

  ///
  void addMaterial(dynamic value) {
    materials.add(Materialmodel.fromJson(value));
  }

  ///
  void addBlueprint(dynamic value) {
    blueprints.add(Blueprint.fromJson(value));
  }
}

///
class Geometry {
  ///
  String type;

  ///
  List<double> coordinates = [0, 0];

  ///
  Geometry.fromJson(dynamic json) {
    type = json["type"];
    coordinates[0] = json["coordinates"][0];
    coordinates[1] = json["coordinates"][1];
  }
}

///
class Properties {
  ///
  String title;

  ///
  String comment;

  ///
  String status;

  ///
  String ico;

  ///
  List<String> thumbnails = [];

  /// The User who created this point
  String uid;

  ///
  Properties.fromJson(dynamic input) {
    title = input["title"];
    comment = input["comment"];
    status = input["status"];
    ico = input["ico"].toString();
    List<dynamic> pics = input["pictures"];
    thumbnails.clear();
    if (pics != null) {
      for (var pic in pics) {
        thumbnails.add(pic["thumbnail"]);
      }
    }
    uid = input["uid"].toString();
  }

  ///
  Map<String, dynamic> toJson() => {
        'title': title,
        'comment': comment,
        'status': status,
        'ico': ico,
        'uid': uid,
      };
}
