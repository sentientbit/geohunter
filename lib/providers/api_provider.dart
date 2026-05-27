///
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// import 'package:logger/logger.dart';

///
import '../models/app_error.dart';
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
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 9),
  ));

  ///
  void addInterceptors() {
    api.interceptors.add(CustomInterceptors());
  }

  ///
  bool hookStatus(int? status) {
    if (status == 401) {
      CustomInterceptors.clearStoredCookies(GlobalConstants.apiHostUrl);
    }
    return (status == 200);
  }

  /// Unwraps the response envelope: { "success": true, "data": { ... } }
  ///
  /// Returns the data keys merged with `success: true` so that existing
  /// screens using `response["success"] == true` continue to work during
  /// the screen-by-screen migration to Riverpod.
  ///
  /// Throws [AppError] if success is false or the response shape is unexpected.
  Map<String, dynamic> _unwrap(dynamic body) {
    if (body is! Map) {
      throw const AppError(
        code: 'INVALID_RESPONSE',
        message: 'Unexpected response format from server.',
        statusCode: 0,
      );
    }
    final map = Map<String, dynamic>.from(body);
    if (map['success'] != true) {
      throw AppError.fromEnvelope(map);
    }
    final data = map['data'];
    if (data is! Map) {
      throw const AppError(
        code: 'INVALID_RESPONSE',
        message: 'Response data field is not an object.',
        statusCode: 0,
      );
    }
    // Merge success:true into data so existing response["success"] guards pass
    // during the transition. Remove once all screens are on Riverpod.
    return {'success': true, ...Map<String, dynamic>.from(data)};
  }

  /// Read
  Future<Map<String, dynamic>> get(String endpoint, {dynamic headers}) async {
    try {
      final response = await api.get(
        endpoint,
        options: Options(headers: headers, validateStatus: hookStatus),
      );
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    } on AppError {
      rethrow;
    } on Exception catch (error, stacktrace) {
      debugPrint('ApiProvider.get unexpected error: $error\n$stacktrace');
      rethrow;
    }
  }

  /// Create
  Future<Map<String, dynamic>> post(String endpoint, dynamic body,
      {dynamic headers}) async {
    try {
      final response = await api.post(
        endpoint,
        data: body,
        options: Options(headers: headers, validateStatus: hookStatus),
      );
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    } on AppError {
      rethrow;
    } on Exception catch (error, stacktrace) {
      debugPrint('ApiProvider.post unexpected error: $error\n$stacktrace');
      rethrow;
    }
  }

  /// Update
  Future<Map<String, dynamic>> put(String endpoint, dynamic body) async {
    try {
      final response = await api.put(
        endpoint,
        data: body,
        options: Options(validateStatus: hookStatus),
      );
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    } on AppError {
      rethrow;
    } on Exception catch (error, stacktrace) {
      debugPrint('ApiProvider.put unexpected error: $error\n$stacktrace');
      rethrow;
    }
  }

  ///
  Future<Map<String, dynamic>> save(
      int isId, String endpoint, dynamic body) async {
    if (isId == 0) return post(endpoint, body);
    return put(endpoint, body);
  }

  /// Delete
  Future<Map<String, dynamic>> delete(String endpoint, dynamic body) async {
    try {
      final response = await api.delete(
        endpoint,
        data: body,
        options: Options(validateStatus: hookStatus),
      );
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    } on AppError {
      rethrow;
    } on Exception catch (error, stacktrace) {
      debugPrint('ApiProvider.delete unexpected error: $error\n$stacktrace');
      rethrow;
    }
  }

  ///
  Future<User> getStoredUser() async {
    User tmp = User.blank();
    Map<String, dynamic> userDatastored = {"user": null};
    try {
      userDatastored =
          await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl);
      if (userDatastored["user"] != null) {
        tmp = User.fromJson(userDatastored);
      }
    } on Exception catch (error, stacktrace) {
      debugPrint('getStoredUser unexpected error: $error\n$stacktrace');
      return tmp;
    }
    return tmp;
  }

  ///
  Future<Map<String, dynamic>> updateProfilePicture(File image) async {
    try {
      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        "avatarfile":
            await MultipartFile.fromFile(image.path, filename: fileName),
      });
      final response = await api.post(
        "https://${GlobalConstants.apiHostUrl}/api/avatar",
        data: formData,
        options: Options(validateStatus: hookStatus),
      );
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    } on AppError {
      rethrow;
    } on Exception catch (error, stacktrace) {
      debugPrint('updateProfilePicture unexpected error: $error\n$stacktrace');
      rethrow;
    }
  }

  /// Upload pictures [image, mineId] from map with add landmark
  Future<Map<String, dynamic>> uploadLandmarkPicture(
      String endpoint, File image) async {
    try {
      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        "landmarkfile":
            await MultipartFile.fromFile(image.path, filename: fileName),
      });
      final response = await api.post(
        "https://${GlobalConstants.apiHostUrl}/api$endpoint",
        data: formData,
        options: Options(validateStatus: hookStatus),
      );
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    } on AppError {
      rethrow;
    } on Exception catch (error, stacktrace) {
      debugPrint('uploadLandmarkPicture unexpected error: $error\n$stacktrace');
      rethrow;
    }
  }
}
