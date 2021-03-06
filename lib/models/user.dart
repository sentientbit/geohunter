// import 'package:logger/logger.dart';

///
class User {
  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  /// Unique User Id
  String uid = "";

  ///
  String jwt = "";

  ///
  UserData details = UserData.blank();

  /// constructor
  User({
    required this.uid,
    required this.details,
    required this.jwt,
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
    ///print('--- log. toMap() ---');
    ///log.d(details);
    return {
      "user": {
        "user_id": details.id,
        "username": details.username,
        "mining_speed": details.mining,
        "unapproved_members": details.unnaprovedMembers,
        "guild": {"id": details.guildId, "permissions": 0, "guid": "0"},
        "status": details.status,
        "lat": details.lat,
        "lng": details.lng,
        "picture": {"thumbnail": details.picture},
        "sex": details.sex,
        "language": details.language,
        "location_privacy": details.locationPrivacy,
        "level": details.level,
        "percentage": details.percentage,
        "coins": details.coins,
        "xp": details.xp,
        "unread": details.unread,
        "attack": details.attack,
        "defense": details.defense,
        "daily": details.daily,
        "music": details.music,
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
    required this.guildId,
    required this.permissions,
    required this.guid,
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
  String id = "";

  ///
  String username = "";

  ///
  String guildId = "";

  ///
  double lat = 51.5;

  ///
  double lng = 0.0;

  ///
  String picture = "";

  ///
  String sex = "0";

  ///
  String language = "en";

  ///
  String locationPrivacy = "0";

  ///
  String status = "";

  ///
  List<String> currentQuests = [];

  ///
  double level = 0.0;

  ///
  int percentage = 0;

  /// Total amount of funds
  double coins = 0.0;

  ///
  int mining = 3600;

  ///
  int unnaprovedMembers = 0;

  ///
  int xp = 0;

  ///
  List<dynamic> unread = [];

  ///
  List<dynamic> attack = [];

  ///
  List<dynamic> defense = [];

  /// Elapsed number of seconds for the next Daily Reward
  int daily = 0;

  /// Music default volume
  int music = 100;

  ///
  List<dynamic> costs = [0.1, 0.1, 0.1];

  /// constructor
  UserData({
    this.username = "",
    this.sex = "0",
    this.locationPrivacy = "0",
    this.coins = 0.0,
    this.mining = 0,
    this.guildId = "",
    this.unnaprovedMembers = 0,
    this.xp = 0,
    required this.unread,
    required this.attack,
    required this.defense,
    required this.daily,
    this.music = 100,
    required this.costs,
  });

  ///
  factory UserData.blank() {
    return UserData(
      username: "Guest",
      sex: "0",
      locationPrivacy: "0",
      coins: 0.0,
      mining: 3600,
      guildId: "",
      unnaprovedMembers: 0,
      xp: 0,
      unread: [],
      attack: [],
      defense: [],
      daily: 0,
      music: 100,
      costs: [0.1, 0.1, 0.1],
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
    level = double.tryParse(json["level"].toString()) ?? 0.0;
    percentage = int.parse(json["percentage"].toString());
    coins = double.tryParse(json["coins"].toString()) ?? 0.0;
    mining = json["mining"] ?? 3600;
    unnaprovedMembers = (json["unapproved_members"] != null)
        ? int.parse(json["unapproved_members"].toString())
        : 0;
    xp = json["xp"] ?? 0;
    unread = json["unread"] ?? [];
    attack = json["attack"] ?? [];
    defense = json["defense"] ?? [];
    daily = json["daily"] ?? 0;
    music = json["music"] ?? 100;
    costs = json["costs"] ?? [0.1, 0.1, 0.1];
  }

  ///
  Map<String, dynamic> toJson() => {
        'percentage': percentage,
        'level': level,
        'mining_speed': mining,
        'coins': coins,
        'unnaprovedMembers': unnaprovedMembers,
        'xp': xp,
        'unread': unread,
        'attack': attack,
        'defense': defense,
        'daily': daily,
        'music': music,
        'costs': costs,
      };

  /// Override toString to have a beautiful log of student object
  @override
  String toString() {
    return 'UserData({level: $level, coins: $coins, mining: $mining, daily: $daily, music: $music, costs: $costs})';
  }
}
