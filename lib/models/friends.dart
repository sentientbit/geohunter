///
class Friend {
  ///
  final String id;

  ///
  final String sex;

  ///
  final String username;

  ///
  final String status;

  ///
  final String xp;

  ///
  final int locationPrivacy;

  ///
  final String thumbnail;

  /// is friendship requested
  final String isReq;

  /// Latitude
  final double lat;

  /// Longitude
  final double lng;

  ///
  const Friend({
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
}
