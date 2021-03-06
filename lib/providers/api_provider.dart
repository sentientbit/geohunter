///
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// import 'package:logger/logger.dart';

///
import '../models/user.dart';
import '../providers/custom_interceptors.dart';
import '../shared/constants.dart';

/// API Provider
class ApiProvider {
  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  /// or new Dio with a BaseOptions instance.
  static Dio api = Dio(BaseOptions(
    baseUrl: "https://${GlobalConstants.apiHostUrl}/api",
    connectTimeout: 10000,
    receiveTimeout: 9000,
  ));

  ///
  void addInterceptors() {
    api.interceptors.add(CustomInterceptors());
  }

  ///
  bool hookStatus(int? status) {
    //print('hookStatus');
    //print(status);
    if (status == 401) {
      CustomInterceptors.clearStoredCookies(GlobalConstants.apiHostUrl);
    }
    return (status == 200);
  }

  /// Read
  Future get(String endpoint, {dynamic headers}) async {
    if (headers != null) {
      api.options.headers = headers;
    }
    api.options.validateStatus = hookStatus;
    final response = await api.get(endpoint);
    //log.d(response);
    try {
      return response.data;
    } on Exception catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return error;
    }
  }

  /// Create
  Future post(String endpoint, dynamic body, {dynamic headers}) async {
    if (headers != null) {
      api.options.headers = headers;
    }
    var response = await api.post(endpoint, data: body);
    try {
      return response.data;
    } on Exception catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return error;
    }
  }

  /// Update
  Future put(String endpoint, dynamic body) async {
    final response = await api.put(endpoint, data: body);
    try {
      return response.data;
    } on Exception catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return error;
    }
  }

  ///
  Future save(int isId, String endpoint, dynamic body) async {
    if (isId == 0) {
      return post(endpoint, body);
    }
    return put(endpoint, body);
  }

  /// Delete
  Future delete(String endpoint, dynamic body) async {
    final response = await api.delete(endpoint, data: body);
    try {
      return response.data;
    } on Exception catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return error;
    }
  }

  ///
  Future<User> getStoredUser() async {
    //ignore: omit_local_variable_types
    User tmp = User.blank();

    // ignore: omit_local_variable_types
    Map<String, dynamic> userDatastored = {"user": null};

    // print('--- log. getStoredUser() ---');
    // log.d(userDatastored);
    try {
      userDatastored =
          await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl);

      if (userDatastored["user"] != null) {
        tmp = User.fromJson(userDatastored);
      }
    } on Exception catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return tmp;
    }
    return tmp;
  }

  ///
  Future updateProfilePicture(File image) async {
    if (image == null) {
      return;
    }
    Response response;
    try {
      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        "avatarfile":
            await MultipartFile.fromFile(image.path, filename: fileName),
      });
      //api.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';

      response = await api.post(
        "https://${GlobalConstants.apiHostUrl}/api/avatar",
        data: formData,
      );
      //print(response);
      return response.data;
    } on Exception catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return;
    }
  }

  /// Upload pictures [image, mineId] from map with add landmark
  Future uploadLandmarkPicture(String endpoint, File image) async {
    try {
      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        "landmarkfile":
            await MultipartFile.fromFile(image.path, filename: fileName),
      });
      //api.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';

      // ignore: omit_local_variable_types
      Response response = await api.post(
        "https://${GlobalConstants.apiHostUrl}/api$endpoint",
        data: formData,
      );

      return response.data;
    } on Exception catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return error;
    }
  }
}
