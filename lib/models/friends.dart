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
  String? status = "";

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
    id = int.tryParse(json["id"].toString()) ?? 0;
    sex = json["sex"].toString();
    username = json["username"].toString();
    status = json["status"]?.toString() ?? "";
    xp = int.tryParse(json["xp"].toString()) ?? 0;
    locationPrivacy = int.tryParse(json["privacy"].toString()) ?? 0;
    thumbnail = json["thumbnail"].toString();
    isReq = json["is_req"]?.toString() ?? "";
    lat = double.tryParse(json["lat"].toString()) ?? 51.5;
    lng = double.tryParse(json["lng"].toString()) ?? 0.0;
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
