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
  Blueprint blueprint = Blueprint.blank();

  ///
  int materialId = 0;

  ///
  Materialmodel material = Materialmodel.blank();

  ///
  int itemId = 0;

  ///
  Item item = Item.blank();

  ///
  String date = "";

  ///
  DailyReward({
    this.day,
    this.blueprintId,
    this.blueprint,
    this.materialId,
    this.material,
    this.itemId,
    this.item,
    this.date,
  });

  ///
  factory DailyReward.blank() {
    return DailyReward(
      day: 0,
      blueprintId: 0,
      blueprint: Blueprint.blank(),
      materialId: 0,
      material: Materialmodel.blank(),
      itemId: 0,
      item: Item.blank(),
      date: "",
    );
  }

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
