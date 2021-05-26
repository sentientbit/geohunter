///
class Guild {
  ///
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
  Picture picture = Picture.blank();

  /// Guild Unique Id
  String guid = "0";

  ///
  List<GuildUser> users = [];

  ///
  int nrUsers = 0;

  ///
  Guild({
    required this.id,
    required this.factionId,
    required this.leaderId,
    required this.name,
    required this.description,
    required this.isLocked,
    required this.isHidden,
    required this.picture,
    required this.guid,
    required this.users,
    required this.nrUsers,
  });

  ///
  factory Guild.blank() {
    return Guild(
      id: 0,
      factionId: 0,
      leaderId: 0,
      name: "",
      description: "",
      isLocked: 0,
      isHidden: 0,
      picture: Picture.blank(),
      guid: "0",
      users: [],
      nrUsers: 0,
    );
  }

  ///
  Guild.fromJson(dynamic json) {
    id = int.parse(json["id"].toString());
    factionId = int.parse(json["faction_id"].toString());
    leaderId = int.parse(json["leader_id"].toString());
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
  int id = 0;

  ///
  String fileName = "";

  ///
  String thumbnail = "";

  /// constructor
  Picture({
    required this.id,
    required this.fileName,
    required this.thumbnail,
  });

  ///
  factory Picture.blank() {
    return Picture(
      id: 0,
      fileName: "",
      thumbnail: "",
    );
  }

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
  int id = 0;

  ///
  String permissions = "";

  ///
  DateTime created = DateTime.now();

  /// constructor
  GuildUser({
    required this.id,
    required this.permissions,
    required this.created,
  });

  ///
  factory GuildUser.blank() {
    return GuildUser(
      id: 0,
      permissions: "",
      created: DateTime.now(),
    );
  }

  ///
  GuildUser.fromJson(dynamic json) {
    id = int.parse(json["user_id"].toString());
    permissions = json["permissions"].toString();
    created = json["created"] != null
        ? DateTime.parse(json["created"])
        : DateTime.parse('2020-01-01 01:01:01');
  }
}
