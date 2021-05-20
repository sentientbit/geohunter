///
class User {
  /// Unique User Id
  String uid = "";

  ///
  String jwt = "";

  ///
  UserData details = UserData.blank();

  /// constructor
  User({
    this.uid,
    this.details,
    this.jwt,
  });

  ///
  factory User.blank() {
    return User(
      uid: "",
      jwt: "",
      details: UserData.blank(),
    );
  }

  ///
  factory User.fromJson(Map<String, dynamic> json) {
    var details = UserData.fromJson(json["user"]);
    return User(
      uid: details.id,
      details: details,
      jwt: json["jwt"],
    );
  }

  ///
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'details': details.toJson(),
        'jwt': jwt,
      };

  ///
  Map<String, dynamic> toMap() {
    return {
      "user": {
        "user_id": details.id,
        "username": details.username,
        "mining_speed": details.miningSpeed,
        "unapproved_members": details.unnaprovedMembers,
        "guild": {"id": details.guildId, "permissions": 0, "guid": "0"},
        "status": details.status,
        "lat": details.lat,
        "lng": details.lng,
        "picture": {"thumbnail": details.picture},
        "sex": details.sex,
        "language": details.language,
        "location_privacy": details.locationPrivacy,
        "experience": details.experience,
        "level": details.level,
        "percentage": details.percentage,
        "coins": details.coins,
        "xp": details.xp,
      },
      "jwt": jwt
    };
  }
}

///
class UserGuild {
  ///
  String guildId = "";

  ///
  int permissions = 0;

  /// Guild Unique Id
  String guid = "";

  ///
  UserGuild({
    this.guildId,
    this.permissions,
    this.guid,
  });

  ///
  factory UserGuild.fromJson(Map<String, dynamic> json) {
    return convertMaptoObject(json);
  }

  ///
  // ignore: prefer_constructors_over_static_methods
  static UserGuild convertMaptoObject(Map<String, dynamic> json) {
    return UserGuild(
      guildId: json['id'].toString(),
      permissions: int.tryParse(json['permissions'].toString()) ?? 0,
      guid: json['guid'].toString(),
    );
  }

  ///
  Map<String, dynamic> toJson() {
    return {
      'guildId': guildId,
      'permissions': permissions,
      'guid': guid,
    };
  }
}

///
class UserData {
  ///
  String id;

  ///
  String username;

  ///
  String guildId;

  ///
  double lat;

  ///
  double lng;

  ///
  String picture;

  ///
  String sex = "0";

  ///
  String language;

  ///
  String locationPrivacy = "0";

  ///
  String status;

  ///
  List<String> currentQuests;

  ///
  String experience;

  ///
  double level;

  ///
  int percentage;

  /// Total amount of funds
  double coins = 0.0;

  ///
  int miningSpeed = 0;

  ///
  int unnaprovedMembers = 0;

  ///
  int xp = 0;

  /// constructor
  UserData({
    this.username = "",
    this.sex = "0",
    this.locationPrivacy = "0",
    this.coins = 0.0,
    this.miningSpeed = 0,
    this.guildId = "",
    this.unnaprovedMembers = 0,
    this.xp = 0,
  });

  ///
  factory UserData.blank() {
    return UserData(
      username: "",
      sex: "0",
      locationPrivacy: "0",
      coins: 0.0,
      miningSpeed: 0,
      guildId: "",
      unnaprovedMembers: 0,
      xp: 0,
    );
  }

  ///
  UserData.fromJson(dynamic json) {
    if (json == null) {
      return;
    }
    id = json["user_id"].toString();
    username = json["username"];
    guildId = json["guild"]["id"];
    lat = double.parse(json["lat"].toString());
    lng = double.parse(json["lng"].toString());
    picture = json["picture"]["thumbnail"];
    sex = json["sex"].toString();
    language = json["language"];
    locationPrivacy = json["location_privacy"].toString();
    status = json["status"].toString();
    // currentQuests = json["current_quests"];
    experience = json["experience"];
    level = double.tryParse(json["level"].toString()) ?? 0.0;
    percentage = int.parse(json["percentage"].toString());
    coins = double.tryParse(json["coins"].toString()) ?? 0.0;
    miningSpeed = int.parse(json["mining_speed"].toString());
    unnaprovedMembers = (json["unapproved_members"] != null)
        ? int.parse(json["unapproved_members"].toString())
        : 0;
    xp = json["xp"];
  }

  ///
  Map<String, dynamic> toJson() => {
        'experience': experience,
        'percentage': percentage,
        'level': level,
        'miningSpeed': miningSpeed,
        'coins': coins,
        'unnaprovedMembers': unnaprovedMembers,
        'xp': xp,
      };
}
