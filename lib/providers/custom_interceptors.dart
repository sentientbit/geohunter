///
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
import '../shared/constants.dart';

///
class CustomInterceptors extends InterceptorsWrapper {
  /// to be used as prefix for all cookies
  static String prefix = 'c0K1e';

  @override
  Future onRequest(RequestOptions options) async {
    final userDatastored = await getStoredCookies(GlobalConstants.apiHostUrl);
    if (options.path != "/login") {
      options.headers["authorization"] = "Bearer ${userDatastored["jwt"]}";
    }
    print("REQUEST[${options?.method}] => PATH: ${options?.path}");
    return super.onRequest(options);
  }

  @override
  Future onResponse(Response response) {
    print(
        // ignore: lines_longer_than_80_chars
        "RESPONSE[${response?.statusCode}] => PATH: ${response?.request?.path}");
    return super.onResponse(response);
  }

  @override
  Future onError(DioError err) {
    print("ERROR[${err?.response?.statusCode}] => PATH: ${err?.request?.path}");
    return super.onError(err);
  }

  ///
  static Future<Map<String, dynamic>> getStoredCookies(String hostname) async {
    try {
      final hostnameHash = hashStringMurmur(hostname);
      final cookiesJson = await storageGet('$prefix-$hostnameHash');
      var cookies = fromJson(cookiesJson);
      return Map<String, dynamic>.from(cookies);
    } on Exception catch (e) {
      print("problem reading stored cookies. fallback with empty cookies $e");
      return <String, dynamic>{};
    }
  }

  ///
  static Future setStoredCookies(
      String hostname, Map<String, dynamic> cookies) async {
    final hostnameHash = hashStringMurmur(hostname);
    final cookiesJson = CustomInterceptors.toJson(cookies);
    await CustomInterceptors.storageSet('$prefix-$hostnameHash', cookiesJson);
  }

  ///
  static Future clearStoredCookies(String hostname) async {
    final hostnameHash = hashStringMurmur(hostname);
    await CustomInterceptors.storageSet('$prefix-$hostnameHash', null);
  }

  ///
  static Future deleteStoredCookies(String hostname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  ///
  static Future storageSet(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  ///
  static Future storageGet(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(key)) {
      return '{}';
    }
    return prefs.getString(key);
  }

  ///
  static bool equalsIgnoreCase(String string1, String string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }

  ///
  static String toJson(dynamic object) {
    var encoder = JsonEncoder.withIndent("  ");
    return encoder.convert(object);
  }

  ///
  static dynamic fromJson(String jsonString) {
    return json.decode(jsonString);
  }

  ///
  static bool hasKeyIgnoreCase(Map map, String key) {
    return map.keys.any((x) => equalsIgnoreCase(x, key));
  }
}
