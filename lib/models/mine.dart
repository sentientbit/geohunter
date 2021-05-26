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
  Geometry geometry = Geometry.blank();

  /// 1 = mine, 2 = player
  int category = 0;

  ///
  MineProperties properties = MineProperties.blank();

  ///
  String lastVisited = "1980-01-01 01:01:01Z";

  ///
  double distanceToPoint = 0.0;

  ///
  List<Item> items = [];

  ///
  List<Materialmodel> materials = [];

  ///
  List<Blueprint> blueprints = [];

  ///
  Mine({
    required this.id,
    required this.geometry,
    required this.category,
    required this.properties,
    required this.lastVisited,
    required this.distanceToPoint,
    required this.items,
    required this.materials,
    required this.blueprints,
  });

  ///
  Mine.fromJson(dynamic json, this.category, LtLn location) {
    id = int.parse(json["id"].toString());
    if (json["last_visited"] != null && json["last_visited"] != "") {
      lastVisited = json["last_visited"];
    } else {
      lastVisited = "1980-01-01 01:01:01Z";
    }
    geometry = Geometry.fromJson(json["geometry"]);
    properties = MineProperties.fromJson(json["properties"]);
    final x = sphericalToCartesian(
      geometry.coordinates[1],
      geometry.coordinates[0],
    );
    final y = sphericalToCartesian(location.latitude, location.longitude);
    distanceToPoint = doubleDistance(x, y);
  }

  ///
  factory Mine.blank() {
    return Mine(
      id: 0,
      geometry: Geometry.blank(),
      category: 0,
      properties: MineProperties.blank(),
      lastVisited: "1980-01-01 01:01:01Z",
      distanceToPoint: 0.0,
      items: [],
      materials: [],
      blueprints: [],
    );
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
  String type = "";

  ///
  List<double> coordinates = [51.5, 0.0];

  ///
  Geometry({
    required this.type,
    required this.coordinates,
  });

  ///
  factory Geometry.blank() {
    return Geometry(
      type: "",
      coordinates: [51.5, 0.0],
    );
  }

  ///
  Geometry.fromJson(dynamic json) {
    type = json["type"];
    coordinates[0] = json["coordinates"][0];
    coordinates[1] = json["coordinates"][1];
  }
}

///
class MineProperties {
  ///
  String title = "";

  ///
  String comment = "";

  ///
  String status = "";

  ///
  String ico = "0";

  ///
  List<String> thumbnails = [];

  /// The User who created this point
  String uid = "";

  ///
  MineProperties({
    required this.title,
    required this.comment,
    required this.status,
    required this.ico,
    required this.thumbnails,
    required this.uid,
  });

  ///
  factory MineProperties.blank() {
    return MineProperties(
      title: "",
      comment: "",
      status: "",
      ico: "0",
      thumbnails: [],
      uid: "",
    );
  }

  ///
  MineProperties.fromJson(dynamic input) {
    title = input["title"];
    comment = input["comment"];
    status = input["status"];
    ico = input["ico"].toString();
    List<dynamic> pics = input["pictures"] ?? [];
    thumbnails.clear();
    if (pics.length > 0) {
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
