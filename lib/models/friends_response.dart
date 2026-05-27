import 'friends.dart';

/// Typed result of GET /api/friends.
///
/// Dashboard state fields (coins, xp, guild, etc.) are present in the raw
/// response but are intentionally ignored here — userProvider handles those
/// via ref.invalidate(userProvider) after this data loads.
class FriendsResponse {
  final List<Friend> friends;

  const FriendsResponse({required this.friends});

  factory FriendsResponse.empty() =>
      const FriendsResponse(friends: []);

  factory FriendsResponse.fromJson(Map<String, dynamic> json) {
    return FriendsResponse(
      friends: ((json['friends'] ?? []) as List)
          .map((e) => Friend.fromJson(e))
          .toList(),
    );
  }
}
