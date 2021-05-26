///
class Quest {
  ///
  String id = "";

  ///
  String title = "";

  ///
  String body = "";

  ///
  String img = "";

  ///
  String thumbnail = "";

  ///
  String quest = "";

  ///
  Status status = Status.blank();

  ///
  Condition condition = Condition.blank();

  ///
  List<Options> options = [];

  /// constructor
  Quest({
    required this.id,
    required this.title,
    required this.img,
  });

  ///
  factory Quest.blank() {
    return Quest(
      id: "",
      title: "",
      img: "",
    );
  }

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
  String id = "";

  ///
  String option = "";

  ///
  Reward reward = Reward.blank();

  ///
  int chosen = 0;

  ///
  Condition condition = Condition.blank();

  ///
  Status status = Status.blank();

  /// constructor
  Options({
    required this.id,
    required this.option,
    required this.chosen,
  });

  ///
  factory Options.blank() {
    return Options(
      id: "",
      option: "",
      chosen: 0,
    );
  }

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
  String xp = "";

  /// constructor
  Reward({
    required this.xp,
  });

  ///
  factory Reward.blank() {
    return Reward(
      xp: "",
    );
  }

  ///
  Reward.fromJson(dynamic json) {
    xp = json["xp"].toString();
  }
}

///
class Status {
  ///
  String isStarted = "";

  ///
  String isCompleted = "";

  ///
  String isFailed = "";

  /// constructor
  Status({
    required this.isStarted,
    required this.isCompleted,
    required this.isFailed,
  });

  ///
  factory Status.blank() {
    return Status(
      isStarted: "",
      isCompleted: "",
      isFailed: "",
    );
  }

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
  String iff = "";

  /// constructor
  Condition({
    required this.iff,
  });

  ///
  factory Condition.blank() {
    return Condition(
      iff: "",
    );
  }

  ///
  Condition.fromJson(dynamic json) {
    iff = json != null ? json["if"] : 'No constraints';
  }
}
