// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'friends.dart';

part 'friends_response.freezed.dart';
part 'friends_response.g.dart';

List<Friend> _parseFriends(dynamic v) =>
    ((v ?? []) as List).map((e) => Friend.fromJson(e)).toList();

/// Typed result of GET /api/friends.
///
/// Dashboard state fields (coins, xp, guild, etc.) are present in the raw
/// response but are intentionally ignored here — userProvider handles those
/// via ref.invalidate(userProvider) after this data loads.
@Freezed(toJson: false)
class FriendsResponse with _$FriendsResponse {
  const FriendsResponse._();

  const factory FriendsResponse({
    @JsonKey(name: 'friends', fromJson: _parseFriends)
    @Default([])
    List<Friend> friends,
  }) = _FriendsResponse;

  factory FriendsResponse.fromJson(Map<String, dynamic> json) =>
      _$FriendsResponseFromJson(json);

  static FriendsResponse empty() => const FriendsResponse();
}
