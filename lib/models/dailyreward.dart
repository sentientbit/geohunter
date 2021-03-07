import '../models/blueprint.dart';
import '../models/item.dart';
import '../models/materialmodel.dart';

///
class DailyReward {
  ///
  int day = 0;

  ///
  int blueprintId = 0;

  ///
  Blueprint blueprint;

  ///
  int materialId = 0;

  ///
  Materialmodel material;

  ///
  int itemId = 0;

  ///
  Item item;

  ///
  String date = '';

  ///
  DailyReward({
    this.day,
    this.blueprintId,
    this.blueprint,
    this.materialId,
    this.itemId,
    this.date,
  });

  ///
  DailyReward.fromJson(dynamic json) {
    if (json == null) {
      return;
    }
    day = int.tryParse(json["day"].toString()) ?? 0;
    blueprintId = int.tryParse(json["blueprint_id"].toString()) ?? 0;
    blueprint = Blueprint.fromJson(json["blueprint"]);
    materialId = int.tryParse(json["material_id"].toString()) ?? 0;
    material = Materialmodel.fromJson(json["material"]);
    itemId = int.tryParse(json["item_id"].toString()) ?? 0;
    item = Item.fromJson(json["item"]);
    if (json["date"] != null && json["date"] != "") {
      date = json["date"];
    } else {
      date = "2000-01-01 01:01:01Z";
    }
  }
}
