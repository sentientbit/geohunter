///
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
import '../shared/constants.dart';

///
class CustomInterceptors extends Interceptor {
  ///
  final _cache = <Uri, Response>{};

  /// to be used as prefix for all cookies
  static String prefix = 'c0K1e';

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // var response = _cache[options.uri];
    // if (options.extra['refresh'] == true) {
    //   print('${options.uri}: force refresh, ignore cache! \n');
    //   return handler.next(options);
    // } else if (response != null) {
    //   print('cache hit: ${options.uri} \n');
    //   return handler.resolve(response);
    // }
    final userDatastored = await getStoredCookies(GlobalConstants.apiHostUrl);
    if (options.path != "/login") {
      options.headers["authorization"] = "Bearer ${userDatastored["jwt"]}";
    }
    print("[${options.method}] ${options.path}");
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    //_cache[response.requestOptions.uri] = response;
    print("[${response.statusCode}] ${response.requestOptions.path}");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print("[${err.response?.statusCode}] ${err.requestOptions.path}");
    super.onError(err, handler);
  }

  ///
  static Future<Map<String, dynamic>> getStoredCookies(String hostname) async {
    try {
      final hostnameHash = hashStringMurmur(hostname);
      //print(StackTrace.current.toString());
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
    await CustomInterceptors.clearSet('$prefix-$hostnameHash');
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
  static Future clearSet(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
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
    return string1.toLowerCase() == string2.toLowerCase();
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
