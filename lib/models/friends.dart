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
  String thumbnail = "";

  /// is friendship requested
  String isReq = "";

  /// Latitude
  double lat = 51.5;

  /// Longitude
  double lng = 0.0;

  ///
  Friend({
    this.id,
    this.sex,
    this.username,
    this.status,
    this.xp,
    this.locationPrivacy,
    this.thumbnail,
    this.isReq,
    this.lat,
    this.lng,
  });

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
