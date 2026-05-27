///
import 'dart:io';
import 'package:dio/dio.dart';

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
    //print('hookStatus');
    //print(status);
    if (status == 401) {
      CustomInterceptors.clearStoredCookies(GlobalConstants.apiHostUrl);
    }
    return (status == 200);
  }

  /// Read
  Future<dynamic> get(String endpoint, {dynamic headers}) async {
    try {
      final response = await api.get(
        endpoint,
        options: Options(headers: headers, validateStatus: hookStatus),
      );
      return response.data;
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    } on Exception catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return null;
    }
  }

  /// Create
  Future<dynamic> post(String endpoint, dynamic body,
      {dynamic headers}) async {
    try {
      final response = await api.post(
        endpoint,
        data: body,
        options: Options(headers: headers, validateStatus: hookStatus),
      );
      return response.data;
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    } on Exception catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return null;
    }
  }

  /// Update
  Future<dynamic> put(String endpoint, dynamic body) async {
    try {
      final response = await api.put(
        endpoint,
        data: body,
        options: Options(validateStatus: hookStatus),
      );
      return response.data;
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    } on Exception catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return null;
    }
  }

  ///
  Future<dynamic> save(int isId, String endpoint, dynamic body) async {
    if (isId == 0) return post(endpoint, body);
    return put(endpoint, body);
  }

  /// Delete
  Future<dynamic> delete(String endpoint, dynamic body) async {
    try {
      final response = await api.delete(
        endpoint,
        data: body,
        options: Options(validateStatus: hookStatus),
      );
      return response.data;
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    } on Exception catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return null;
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
      return response.data;
    } on Exception catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return null;
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
      final response = await api.post(
        "https://${GlobalConstants.apiHostUrl}/api$endpoint",
        data: formData,
        options: Options(validateStatus: hookStatus),
      );
      return response.data;
    } on Exception catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return null;
    }
  }
}
