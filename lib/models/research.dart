///
import '../models/blueprint.dart';
import '../shared/constants.dart';

///
class Research {
  ///
  int id = 0;

  /// The name of the item
  String name = "";

  ///
  String img = "";

  ///
  int nrInvested = 0;

  ///
  Blueprint blueprint = Blueprint.blank();

  ///
  Research({
    required this.id,
    required this.name,
    required this.img,
    required this.blueprint,
  });

  ///
  Research.fromJson(dynamic json) {
    id = int.tryParse(json["id"].toString()) ?? 0;
    name = json["name"];
    img = json["img"];
    nrInvested = int.tryParse(json["nr_invested"].toString()) ?? 0;
    blueprint = Blueprint.fromJson(json["blueprint"]);
  }

  ///
  static String skill(int nrPoints) {
    var craftingLevel = researchToCrafting(nrPoints);
    if (craftingLevel == 1) {
      // Beginner
      return "Novice";
    } else if (craftingLevel == 2) {
      // Apprentice, Assistant
      return "Amateur";
    } else if (craftingLevel == 3) {
      // Competent, Practitioner
      return "Expert";
    } else if (craftingLevel == 4) {
      // Sage, Mentor
      return "Master";
    }
    // None
    return "Untrained";
  }
}
