import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_error.dart';
import '../models/friends_response.dart';
import 'api_provider.dart';

/// Fetches the player's friends list and manages friendship QR actions.
class FriendsRepository {
  final ApiProvider _api = ApiProvider();

  Future<FriendsResponse> getFriends() async {
    final response = await _api.get('/friends');
    return FriendsResponse.fromJson(response);
  }

  /// Generates a one-time friendship QR endpoint.
  ///
  /// Calls POST /friends and returns the [friendship_qr] URL from the response.
  /// Returns an empty string if the server does not include the field.
  Future<String> generateFriendshipQr() async {
    final response = await _api.post('/friends', {});
    return (response['friendship_qr'] as String?) ?? '';
  }

  /// Sends a friend request using a scanned QR URL.
  ///
  /// The URL produced by the server has the form:
  ///   https://host/qr/friendship/TOKEN/bogus
  ///                 0  1    2       3     4     5
  /// so `url.split('/')[5]` yields the token.
  /// Throws [AppError] if the scanned code is not a friendship QR or the
  /// server rejects the request.
  Future<void> addFriend(String scannedUrl) async {
    final parts = scannedUrl.split('/');
    if (parts.length <= 5 || parts[5].isEmpty) {
      throw const AppError(
        code: 'INVALID_QR',
        message: 'That is not a GeoHunter friendship QR code.',
        statusCode: 0,
      );
    }
    await _api.put('/friends/${parts[5]}', {});
  }
}

final friendsRepositoryProvider =
    Provider<FriendsRepository>((ref) => FriendsRepository());
