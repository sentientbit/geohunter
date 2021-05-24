///
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

///
class LtLn {
  ///
  const LtLn(double latitude, double longitude)
      : assert(latitude != null),
        assert(longitude != null),
        latitude =
            (latitude < -90.0 ? -90.0 : (90.0 < latitude ? 90.0 : latitude)),
        longitude = (longitude + 180.0) % 360.0 - 180.0;

  ///
  final double latitude;

  ///
  final double longitude;
}

/// Flutter best practices:  Wrap the constants as statics in a class
class GlobalConstants {
  ///
  const GlobalConstants();

  /// The name of this app
  static String appName = "GeoHunter";

  /// The public api endpoint used for REST services
  static String apiHostUrl = "thegeohunter.com";

  ///
  static const String appNamespace = "com.apsoni.geocraft";

  ///
  static const String appVersion = "1.1.70";

  ///

  ///
  static const List<String> keywords = [
    'gps mmo',
    'rpg',
    'location based',
    'android',
    'mobile game',
    'geolocation game',
  ];

  /// aplication background color
  static Color appBg = Colors.black;

  ///
  static Color appFg = Colors.white;

  ///
  static String mapboxToken =
      'pk.eyJ1IjoiY290ZWJyYXNzZXJpZSIsImEiOiJjanZodnNtdnAwN2RtNDlsanIzYWxpemsxIn0.bL2E8yYPw5KzpKpX86dVHQ' /*c0-t3-c0-u4*/;

  ///
  static String sentryDsn =
      "https://4caa412558e04add9193383f14862045@o414270.ingest.sentry.io/5306128";

  ///
  static const double padding = 16.0;

  ///
  static const double avatarRadius = 36.0;

  ///
  static const double researchCost = 0.9;

  ///
  static const double craftingCost = 0.9;

  ///
  static String backButtonPage = '/poi-map';

  ///
  static const pointMine = "1";

  ///
  static const pointWood = "2";

  ///
  static const pointBattle = "3";

  ///
  static const pointBoy = "4";

  ///
  static const pointGirl = "5";

  ///
  static const pointRuins = "6";

  ///
  static const pointLibrary = "7";

  ///
  static const pointTrader = "8";
}

/// Distance to dig for treasure in meters
const double digDistance = 15.0;

/// Equator radius in meters (WGS84 ellipsoid)
const double equatorRadius = 6378137.0;

/// Polar radius in meters (WGS84 ellipsoid)
const double polarRadius = 6356752.314245;

/// WGS84
const double flattening = 1 / 298.257223563;

/// Earth radius in meters
const double earthRadius = 6367444.0;

/// one radian is equal to 180/π degrees
/// To convert from degrees to radians, multiply by π/180.
const oneRad = math.pi / 180;

/// Convert Spherical coordinates to Cartesian system
List<double> sphericalToCartesian(final double lat, final double lng) {
  //ignore: omit_local_variable_types
  double latR = degToRadian(lat);
  //ignore: omit_local_variable_types
  double lngR = degToRadian(lng);
  //ignore: omit_local_variable_types
  double cos = math.cos(latR);
  return [
    earthRadius * cos * math.cos(lngR),
    earthRadius * math.sin(latR),
    earthRadius * cos * math.sin(lngR)
  ];
}

/// Returns the distance between two points.
double doubleDistance(List<double> a, List<double> b) {
  var d = 0.0;
  var k = b[0] - a[0];
  d += k * k;
  k = b[1] - a[1];
  d += k * k;
  k = b[2] - a[2];
  d += k * k;
  var root = math.sqrt(d);
  if (root.isNaN) {
    root = 0.0;
  }
  return root;
}

/// Defines a snapshot result for a daylight calculation.
class SunCalcResult {
  ///
  SunCalcResult(this.sunrise, this.sunset, this.noon);

  /// Time of the sunset in UTC
  final DateTime sunrise;

  /// Time of the sunset in UTC
  final DateTime sunset;

  /// Time of the sunset in UTC
  final DateTime noon;
}

/// Based on https://github.com/shanus/flutter_suncalc
class SunCalc {
  ///
  DateTime moonLanding = DateTime.utc(1969, 7, 20, 20, 18, 04);

  ///
  static const j2000 = 2451545;

  ///
  static const j0 = 0.0009;

  ///
  static DateTime julianEpoch = DateTime.utc(-4713, 11, 24, 12, 0, 0);

  ///
  static DateTime fromJulian(num j) {
    var mpd = Duration.millisecondsPerDay;
    return julianEpoch.add(Duration(milliseconds: (j * mpd).floor()));
  }

  ///
  static num toJulian(DateTime date) {
    return date.difference(SunCalc.julianEpoch).inSeconds /
        Duration.secondsPerDay;
  }

  ///
  static num toDays(DateTime date) {
    return SunCalc.toJulian(date) - SunCalc.j2000;
  }

  /// general calculations for position
  static num rightAscension(num l, num b) {
    return math.atan2(
        math.sin(l) * math.cos(oneRad * 23.4397) -
            math.tan(b) * math.sin(oneRad * 23.4397),
        math.cos(l));
  }

  ///
  static num declination(num l, num b) {
    return math.asin(math.sin(b) * math.cos(oneRad * 23.4397) +
        math.cos(b) * math.sin(oneRad * 23.4397) * math.sin(l));
  }

  ///
  static num julianCycle(num d, num lw) {
    return (d - SunCalc.j0 - lw / (2 * math.pi)).round();
  }

  ///
  static num approxTransit(num ht, num lw, num n) {
    return SunCalc.j0 + (ht + lw) / (2 * math.pi) + n;
  }

  ///
  static num solarTransitJ(num ds, num M, num L) {
    return SunCalc.j2000 + ds + 0.0053 * math.sin(M) - 0.0069 * math.sin(2 * L);
  }

  ///
  static num hourAngle(num h, num phi, num d) {
    return math.acos((math.sin(h) - math.sin(phi) * math.sin(d)) /
        (math.cos(phi) * math.cos(d)));
  }

  ///
  static num getSetJ(num h, num lw, num phi, num dec, num n, num M, num L) {
    var w = SunCalc.hourAngle(h, phi, dec);
    var a = SunCalc.approxTransit(w, lw, n);

    return SunCalc.solarTransitJ(a, M, L);
  }

  /// general sun calculations
  static num solarMeanAnomaly(num d) {
    return oneRad * (357.5291 + 0.98560028 * d);
  }

  ///
  static num equationOfCenter(num M) {
    var firstFactor = 1.9148 * math.sin(M);
    var secondFactor = 0.02 * math.sin(2 * M);
    var thirdFactor = 0.0003 * math.sin(3 * M);

    return oneRad * (firstFactor + secondFactor + thirdFactor);
  }

  ///
  static num eclipticLongitude(num M) {
    var C = SunCalc.equationOfCenter(M);
    var P = oneRad * 102.9372; // perihelion of the Earth

    return M + C + P + math.pi;
  }

  ///
  static Map<String, num> sunCoords(num d) {
    var M = SunCalc.solarMeanAnomaly(d);
    var L = SunCalc.eclipticLongitude(M);

    return {"dec": declination(L, 0), "ra": rightAscension(L, 0)};
  }

  ///
  static SunCalcResult getTimes(DateTime date, num lat, num lng) {
    var lw = oneRad * -lng;
    var phi = oneRad * lat;

    var d = SunCalc.toDays(date);
    var n = SunCalc.julianCycle(d, lw);
    var ds = SunCalc.approxTransit(0, lw, n);
    var M = SunCalc.solarMeanAnomaly(ds);
    var L = SunCalc.eclipticLongitude(M);
    var dec = SunCalc.declination(L, 0);
    var jnoon = SunCalc.solarTransitJ(ds, M, L);
    final noonDateTime = SunCalc.fromJulian(jnoon);
    var jset = SunCalc.getSetJ(-0.833 * oneRad, lw, phi, dec, n, M, L);

    if (jset.isNaN) {
      return SunCalcResult(DateTime.utc(1969, 7, 20, 20, 18, 04),
          DateTime.utc(1969, 7, 20, 20, 18, 04), noonDateTime);
    }

    var jrise = jnoon - (jset - jnoon);

    final sunsetDateTime = SunCalc.fromJulian(jrise);
    final sunriseDateTime = SunCalc.fromJulian(jset);

    return SunCalcResult(sunsetDateTime, sunriseDateTime, noonDateTime);
  }

  ///
  static bool isDaytime(DateTime datenow, DateTime sunrise, DateTime sunset) {
    if (datenow == null || sunrise == null || sunset == null) {
      return false;
    }
    if (sunrise.compareTo(datenow) < 0 && sunset.compareTo(datenow) > 0) {
      return true;
    }
    return false;
  }
}

/// Convert Experience into Player Level
/// log($exp / 10 + 1, 2)
int expToLevel(int exp) {
  var lvl = math.log((exp / 10) + 1) / math.ln2;
  return lvl.floor();
}

/// Convert Player Level into Experience
/// $exp = 10 * (pow(2, $lvl) - 1);
int levelToExp(int lvl) {
  var exp = math.pow(2, lvl) - 1;
  return 10 * exp;
}

/// Convert Research points into Crafting Level
num researchToCrafting(num exp) {
  var lvl = math.log((exp) + 1) / math.ln2;
  var crafting = lvl.floor();
  // Cap to level 4 for now
  if (crafting > 4) {
    return 4;
  }
  return crafting;
}

/// Convert Crafting Level into Research points
num craftingToResearch(num lvl) {
  var exp = math.pow(2, lvl) - 1;
  return exp;
}

/// String hashStringSHA256(String input) { var digest = sha256.convert(utf8.encode(input)); print("Digest as hex string: $digest"); return base64.encode(digest.bytes); }

///
String hashStringMurmur(String input) {
  var mmh = Murmur32(1083920835);
  var val = mmh.computeHashFromString(input);
  var byteData = ByteData.sublistView(val);
  return byteData.getUint32(0).toString();
}

///
Map<String, dynamic> parseJwt(String token) {
  // ignore: omit_local_variable_types
  Map<String, dynamic> blankPayload = {"usr": "", "iat": 0, "exp": 0};
  final parts = token.split('.');
  if (parts.length != 3) {
    return blankPayload;
  }

  // ignore: omit_local_variable_types
  String normalizedSource = base64Url.normalize(parts[1]);
  final payload = utf8.decode(base64Url.decode(normalizedSource));

  final payloadMap = json.decode(payload);
  if (payloadMap is! Map<String, dynamic>) {
    return blankPayload;
  }

  return payloadMap;
}

/// Murmur hash
class Murmur32 {
  ///
  int c1 = 0xcc9e2d51.toUnsigned(32);

  ///
  int c2 = 0x1b873593.toUnsigned(32);

  int _seed = 0;

  ///
  Murmur32(int seed) {
    _seed = seed.toUnsigned(32);
    _reset();
  }

  ///
  int get seed => _seed;

  ///
  int h1 = 0;

  ///
  int length = 0;

  void _reset() {
    h1 = seed;
    length = 0;
  }

  ///
  ByteData computeHashFromString(String source) {
    // ignore: omit_local_variable_types
    Uint8List buffer = Uint8List.fromList(utf8.encode(source));
    return computeHash(buffer, 0, buffer.length);
  }

  ///
  ByteData computeHash(Uint8List buffer, int offset, int count) {
    _reset();
    hashCore(buffer, 0, buffer.length);

    h1 = fMix((h1 ^ length).toUnsigned(32));
    return ByteData(4)..buffer.asByteData().setUint32(0, h1);
  }

  ///
  int fMix(int h) {
    // pipelining friendly algorithm
    h = ((h ^ (h >> 16)) * 0x85ebca6b).toUnsigned(32);
    h = ((h ^ (h >> 13)) * 0xc2b2ae35).toUnsigned(32);
    return (h ^ (h >> 16)).toUnsigned(32);
  }

  ///
  int rotateLeft(int x, int r) {
    return ((x << r) | (x >> (32 - r))).toUnsigned(32);
  }

  ///
  int toUint32(Uint8List data, int start) {
    return Endian.host == Endian.little
        ? (data[start] |
            data[start + 1] << 8 |
            data[start + 2] << 16 |
            data[start + 3] << 24)
        : (data[start] << 24 |
            data[start + 1] << 16 |
            data[start + 2] << 8 |
            data[start + 3]);
  }

  ///
  void hashCore(Uint8List buffer, int start, int count) {
    length += count.toUnsigned(32);
    // ignore: omit_local_variable_types
    int remainder = count & 3;
    // ignore: omit_local_variable_types
    int alignedLength = (start + (count - remainder)).toUnsigned(32);

    for (var i = start; i < alignedLength; i += 4) {
      var v1 = (toUint32(buffer, i) * c1).toUnsigned(32);
      var v2 = rotateLeft(v1, 15);
      var v3 = (v2 * c2).toUnsigned(32);
      var v4 = (h1 ^ v3).toUnsigned(32);
      var v5 = rotateLeft(v4, 13);
      var v6 = (v5 * 5).toUnsigned(32);

      h1 = (v6 + 0xe6546b64).toUnsigned(32);
    }

    if (remainder > 0) {
      // create our keys and initialize to 0
      var k1 = 0;

      // determine how many bytes we have left to work with based on length
      switch (remainder) {
        case 3:
          k1 ^= (buffer[alignedLength + 2] << 16).toUnsigned(32);
          continue case2;

        case2:
        case 2:
          k1 ^= (buffer[alignedLength + 1] << 8).toUnsigned(32);
          continue case1;

        case1:
        case 1:
          k1 ^= buffer[alignedLength];
          break;
      }

      h1 ^= (rotateLeft((k1 * c1).toUnsigned(32), 15) * c2).toUnsigned(32);
    }
  }
}

///
class AdManager {
  ///
  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-5663066771209660~3615389107";
    } else {
      return "ca-app-pub-5663066771209660~9566289284";
    }
  }

  ///
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/8865242552";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  ///
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/7049598008";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  ///
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-5663066771209660/4626338005";
    } else {
      return "ca-app-pub-5663066771209660/1819661207";
    }
  }

  ///
  static String get woodchopAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-5663066771209660/2238652585";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}

///
class Debouncer {
  ///
  int milliseconds = 500;

  ///
  VoidCallback action = () {};
  Timer _timer;

  ///
  Debouncer({this.milliseconds});

  ///
  void run(VoidCallback action) {
    if (_timer != null) {
      _timer.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

///
Color colorRarity(int rarity) {
  if (rarity == 1) {
    // Uncommon
    return Color(0xff7ecb3a);
  } else if (rarity == 2) {
    // Rare
    return Color(0xff0da3d8);
  } else if (rarity == 3) {
    // Epic
    return Color(0xffaa66d8);
  } else if (rarity == 4) {
    // Legendary
    return Color(0xfffeb53b);
  }
  // Commons
  return Color(0xffcccccc);
}

/// 5556665 should pass
bool guildIdOfflineValidation(String guid) {
  if (guid.length != 7) {
    return false;
  }

  var sum = int.parse(guid[0]) * 4;
  sum += int.parse(guid[1]) * 6;
  sum += int.parse(guid[2]) * 7;
  sum += int.parse(guid[3]) * 9;
  sum += int.parse(guid[4]) * 2;
  sum += int.parse(guid[5]) * 5;

  var ck = sum % 11;
  if (ck == 10) {
    ck = 1;
  }
  if (ck != int.parse(guid[6])) {
    return false;
  }
  return true;
}
