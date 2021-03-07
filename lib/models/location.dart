///
import 'dart:io';

///
class PinLocation {
  /// if it is 0 then this does not have a record in the DB
  int mineId = 0;

  ///
  final double latitude;

  ///
  final double longitude;

  ///
  String desc;

  /// List of images for this point
  List<File> images = [];

  ///
  PinLocation({this.mineId, this.latitude, this.longitude, this.desc});
}
