import 'package:geohunter/models/guild.dart';

///
class Friend {
  ///
  int id = 0;

  ///
  String sex = "0";

  ///
  String username = "";

  ///
  String status = "";

  ///
  int xp = 0;

  ///
  int locationPrivacy = 0;

  ///
  String thumbnail = "/img/avatar/default01.jpg";

  /// is friendship requested
  String isReq = "";

  /// Latitude
  double lat = 51.5;

  /// Longitude
  double lng = 0.0;

  ///
  Friend({
    required this.id,
    required this.sex,
    required this.username,
    required this.status,
    required this.xp,
    required this.locationPrivacy,
    required this.thumbnail,
    required this.isReq,
    required this.lat,
    required this.lng,
  });

  ///
  Friend.fromJson(dynamic json) {
    id = int.parse(json["id"].toString());
    sex = json["sex"];
    username = json["username"];
    status = json["status"];
    xp = json["xp"];
    locationPrivacy = json['privacy'];
    thumbnail = json["thumbnail"];
    lat = json["lat"];
    lng = json["lng"];
  }

  ///
  Friend.fromGuildUser(GuildUser gu) {
    id = gu.id;
    sex = gu.sex;
    username = gu.username;
    status = gu.status;
    xp = gu.xp;
    locationPrivacy = gu.privacy;
    thumbnail = gu.thumbnail;
    lat = gu.lat;
    lng = gu.lng;
  }

  ///
  factory Friend.blank() {
    return Friend(
      id: 0,
      sex: "0",
      username: "",
      status: "",
      xp: 0,
      locationPrivacy: 0,
      thumbnail: "",
      isReq: "",
      lat: 51.5,
      lng: 0.0,
    );
  }
}
