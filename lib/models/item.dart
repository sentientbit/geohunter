///
import 'dart:ui';

import 'package:geohunter/shared/constants.dart';
//import 'package:logger/logger.dart';

///
class Item {
  ///
  int id = 0;

  /// Percentage of this item droping in random locations
  int dropChance = 0;

  /// The name of the item
  String name = "";

  ///
  int blueprintId = 0;

  ///
  String img = "nothing.png";

  ///
  int level = 0;

  ///
  int rarity = 0;

  /// Nr Items
  int nr = 0;

  ///
  Item({
    required this.id,
    required this.dropChance,
    required this.name,
    required this.blueprintId,
    required this.img,
    required this.level,
    required this.rarity,
    required this.nr,
  });

  ///
  factory Item.blank() {
    return Item(
      id: 0,
      dropChance: 0,
      name: "",
      blueprintId: 0,
      img: "nothing.png",
      level: 0,
      rarity: 0,
      nr: 0,
    );
  }

  ///
  Item.fromJson(dynamic json) {
    if (json == null) {
      return;
    }
    id = int.tryParse(json["id"].toString()) ?? 0;
    dropChance = int.tryParse(json["drop_chance"].toString()) ?? 0;
    name = json["name"];
    blueprintId = int.tryParse(json["blueprint_id"].toString()) ?? 0;
    img = json["img"];
    level = int.tryParse(json["level"].toString()) ?? 0;
    rarity = int.tryParse(json["rarity"].toString()) ?? 0;
    nr = int.tryParse(json["nr"].toString()) ?? 0;
  }

  ///
  static Color color(int rarity) {
    return colorRarity(rarity);
  }

  ///
  static Color gradientTop(int rarity) {
    if (rarity == 1) {
      // Uncommon
      return Color(0xff2c3512);
    } else if (rarity == 2) {
      // Rare
      return Color(0xff142e39);
    } else if (rarity == 3) {
      // Epic
      return Color(0xff391439);
    } else if (rarity == 4) {
      // Legendary
      return Color(0xff473618);
    }
    // Common
    return Color(0xff28211c);
  }

  ///
  static Color gradientBottom(int rarity) {
    if (rarity == 1) {
      // Uncommon
      return Color(0xff100e10);
    } else if (rarity == 2) {
      // Rare
      return Color(0xff081419);
    } else if (rarity == 3) {
      // Epic
      return Color(0xff0e0f10);
    } else if (rarity == 4) {
      // Legendary
      return Color(0xff12100f);
    }
    // Common
    return Color(0xff101010);
  }
}
