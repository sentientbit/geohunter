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
        "guild": {
          "id": details.guild.id,
          "permissions": details.guild.permissions,
          "guid": details.guild.guid
        },
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
  String id;

  ///
  String permissions;

  /// Guild Unique Id
  String guid;

  ///
  UserGuild.fromJson(dynamic json) {
    id = json["id"].toString();
    permissions = json["permissions"].toString();
    guid = json["guid"].toString();
  }
}

///
class UserData {
  ///
  String id;

  ///
  String username;

  ///
  UserGuild guild;

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
  });

  ///
  UserData.fromJson(dynamic json) {
    if (json == null) {
      return;
    }
    id = json["user_id"].toString();
    username = json["username"];
    guild = UserGuild.fromJson(json["guild"]);
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
