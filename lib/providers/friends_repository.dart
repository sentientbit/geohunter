import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/friends_response.dart';
import 'api_provider.dart';

/// Fetches the player's friends list from the server.
class FriendsRepository {
  final ApiProvider _api = ApiProvider();

  Future<FriendsResponse> getFriends() async {
    final response = await _api.get('/friends');
    return FriendsResponse.fromJson(response);
  }
}

final friendsRepositoryProvider =
    Provider<FriendsRepository>((ref) => FriendsRepository());
