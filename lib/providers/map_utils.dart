///import 'package:logger/logger.dart';

// import 'package:url_launcher/url_launcher.dart';
///
class MapUtils {
  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  static void openMap(double latitude, double longitude) async {
    // String googleUrl =
    //     'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    // if (await canLaunch(googleUrl)) {
    //   await launch(googleUrl);
    // } else {
    //   log.e('Could not open the map.');
    // }
  }

  ///
  static void openWazeMap(double latitude, double longitude) async {
    // String wazeUrl =
    //     'https://www.waze.com/ul?ll=$latitude%2C$longitude&navigate=yes&zoom=17';
    // if (await canLaunch(wazeUrl)) {
    //   await launch(wazeUrl);
    // } else {
    //   log.e('Could not open the map.');
    // }
  }

  ///
  static void openPreferredMap(double latitude, double longitude) async {
    // // String preferredMapUrl;
    // final userStoredData = await Requests.getStoredCookies(
    //  gConstants.apiHostUrl
    // );
    // if (userStoredData["preferredNav"] == "waze")
    //   preferredMapUrl =
    //       'https://www.waze.com/ul?ll=$latitude%2C$longitude&navigate=yes&zoom=17';
    // else
    //   preferredMapUrl =
    //       'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    // if (await canLaunch(preferredMapUrl)) {
    //   await launch(preferredMapUrl);
    // } else {
    //   log.e('Could not open the map.');
    // }
  }

  ///
  static void commPhone(String action, String phoneNumber) async {
    // String cmd = "$action:$phoneNumber";

    // if (await canLaunch(cmd)) {
    //   await launch(cmd);
    // } else {
    //   log.e('Could not open the map.');
    // }
  }
}
