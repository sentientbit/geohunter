///
import 'dart:io';

///
class PinLocation {
  /// if it is 0 then this does not have a record in the DB
  int mineId = 0;

  ///
  double lat = 51.5;

  ///
  double lng = 0.0;

  ///
  String desc = "";

  /// List of images for this point
  List<File> images = [];

  ///
  PinLocation({
    required this.mineId,
    required this.lat,
    required this.lng,
    required this.desc,
  });
}
