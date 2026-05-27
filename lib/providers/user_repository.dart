import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../providers/api_provider.dart';
import '../providers/custom_interceptors.dart';
import '../shared/constants.dart';

/// Fetches the authenticated user from the server and keeps cookies in sync.
class UserRepository {
  final ApiProvider _api = ApiProvider();

  /// Calls GET /api/profile, persists the fresh JWT + user to cookies, and
  /// returns a fully hydrated [User].  Throws [AppError] on failure.
  Future<User> getUser() async {
    final response = await _api.get('/profile');

    // Persist fresh credentials so getStoredUser() stays in sync
    final cookies =
        await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl);
    cookies['jwt'] = response['jwt'];
    cookies['user'] = response['user'];
    await CustomInterceptors.setStoredCookies(
        GlobalConstants.apiHostUrl, cookies);

    return User.fromJson(response);
  }
}

final userRepositoryProvider =
    Provider<UserRepository>((ref) => UserRepository());
