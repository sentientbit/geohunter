import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/friends_response.dart';
import 'friends_repository.dart';

/// Holds the player's friends list.
///
/// After adding/removing a friend:
///   ref.invalidate(friendsProvider) — refreshes the list
///   ref.invalidate(userProvider)    — refreshes unread count in drawer
class FriendsNotifier extends AsyncNotifier<FriendsResponse> {
  @override
  Future<FriendsResponse> build() =>
      ref.read(friendsRepositoryProvider).getFriends();
}

final friendsProvider =
    AsyncNotifierProvider<FriendsNotifier, FriendsResponse>(
        FriendsNotifier.new);
