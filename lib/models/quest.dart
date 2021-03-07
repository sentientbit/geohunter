///
class Quest {
  ///
  String id;

  ///
  String title;

  ///
  String body;

  ///
  String img;

  ///
  String thumbnail;

  ///
  String quest;

  ///
  Status status;

  ///
  Condition condition;

  ///
  List<Options> options = [];

  ///
  Quest.fromJson(dynamic json) {
    id = json["id"].toString();
    title = json["title"];
    body = json["body"];
    img = json["img"];
    thumbnail = json["thumbnail"];
    quest = json["quest"];
    status = Status.fromJson(json["status"]);
    condition = Condition.fromJson(json["condition"]);

    for (dynamic option in json["options"]) {
      options.add(Options.fromJson(option));
    }
  }
}

///
class Options {
  ///
  String id;

  ///
  String option;

  ///
  Reward reward;

  ///
  int chosen;

  ///
  Condition condition;

  ///
  Status status;

  ///
  Options.fromJson(dynamic json) {
    id = json["id"].toString();
    option = json["option"];
    reward = Reward.fromJson(json);
    status = Status.fromJson(json["status"]);
    condition = Condition.fromJson(json["condition"]);
    // chosen = int.parse(json["chosen"].toString());
  }
}

///
class Reward {
  ///
  String xp;

  ///
  Reward.fromJson(dynamic json) {
    xp = json["xp"].toString();
  }
}

///
class Status {
  ///
  String isStarted;

  ///
  String isCompleted;

  ///
  String isFailed;

  ///
  Status.fromJson(dynamic json) {
    isStarted = json["is_started"].toString();
    isCompleted = json["is_completed"].toString();
    isFailed = json["is_failed"].toString();
  }
}

///
class Condition {
  ///
  String iff;

  ///
  Condition.fromJson(dynamic json) {
    iff = json != null ? json["if"] : 'No constraints';
  }
}
