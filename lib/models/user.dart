///
import 'package:flutter/material.dart';

///
class User {
  /// Unique User Id
  final String uid;

  ///
  final String jwt;

  ///
  final UserData details;

  /// constructor
  User({
    @required this.uid,
    @required this.details,
    @required this.jwt,
  });

  ///
  // ignore: prefer_constructors_over_static_methods
  static User fromJson(Map<String, dynamic> json) {
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
        "coins": details.coins
      },
      "jwt": jwt
    };
  }
}

///
class UserGuild {
  ///
  String guildId;

  ///
  int permissions;

  /// Guild Unique Id
  String guid;

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
  String sex;

  ///
  String language;

  ///
  String locationPrivacy;

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
  double coins;

  ///
  int miningSpeed;

  ///
  int unnaprovedMembers;

  /// constructor
  UserData({
    this.username = '',
    this.coins = 0.0,
    this.miningSpeed = 0,
    this.guildId,
  });

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
  }

  ///
  Map<String, dynamic> toJson() => {
        'experience': experience,
        'percentage': percentage,
        'level': level,
        'miningSpeed': miningSpeed,
      };
}
