/// Guild object
class Guild {
  /// OR Guild
  int id = 0;

  ///
  int factionId = 0;

  ///
  int leaderId = 0;

  ///
  String name = 'Guild name';

  ///
  String description = 'Guild description';

  ///
  int isLocked = 0;

  ///
  int isHidden = 0;

  ///
  Picture picture;

  /// Guild Unique Id
  String guid = "0";

  ///
  List<GuildUser> users = [];

  ///
  int nrUsers = 0;

  ///
  Guild({
    this.id,
    this.factionId,
    this.leaderId,
    this.name,
    this.description,
    this.isLocked,
    this.isHidden,
    this.picture,
    this.guid,
    this.users,
    this.nrUsers,
  });

  ///
  Guild.fromJson(dynamic json) {
    id = int.parse(json["id"].toString());
    factionId = int.parse(json["faction_id"].toString());
    leaderId = int.parse(json["leader_id"]?.toString());
    name = json["name"].toString();
    isLocked = int.tryParse(json["is_locked"]) ?? 0;
    isHidden = int.tryParse(json["is_hidden"]) ?? 0;
    name = json["name"].toString();
    picture = Picture.fromJson(json["pictures"][0]);
    guid = json["guid"].toString();
    json["users"].forEach(addUser);
    nrUsers = json["users"].length;
  }

  ///
  void addUser(dynamic value) {
    users.add(GuildUser.fromJson(value));
  }
}

///
class Picture {
  ///
  int id;

  ///
  String fileName;

  ///
  String thumbnail;

  ///
  Picture.fromJson(dynamic json) {
    id = json["id"] ?? 0;
    fileName = json["name"];
    thumbnail = json["thumbnail"];
  }
}

///
class GuildUser {
  ///
  int id;

  ///
  String permissions;

  ///
  DateTime created;

  ///
  GuildUser.fromJson(dynamic json) {
    id = int.parse(json["user_id"].toString());
    permissions = json["permissions"].toString();
    created = json["created"] != null
        ? DateTime.parse(json["created"])
        : DateTime.parse('2020-01-01 01:01:01');
  }
}

///
class GuildChat {
  ///
  String userId;

  ///
  String userName;

  ///
  String userIcon;

  ///
  String message;

  ///
  String sendAt;

  ///
  GuildChat.fromJson(dynamic json) {
    userName = json["user_name"];
    userId = json["user_id"].toString();
    userIcon = json["user_icon"].toString();
    message = json["message"];
    sendAt = json["send_at"];
  }

  ///
  Map<String, dynamic> toStr(String userId, String message, String icon) {
    return {"user_id": userId, "message": message, "user_icon": icon};
  }
}
