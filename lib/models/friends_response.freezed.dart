// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friends_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FriendsResponse _$FriendsResponseFromJson(Map<String, dynamic> json) {
  return _FriendsResponse.fromJson(json);
}

/// @nodoc
mixin _$FriendsResponse {
  @JsonKey(name: 'friends', fromJson: _parseFriends)
  List<Friend> get friends => throw _privateConstructorUsedError;

  /// Create a copy of FriendsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendsResponseCopyWith<FriendsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendsResponseCopyWith<$Res> {
  factory $FriendsResponseCopyWith(
          FriendsResponse value, $Res Function(FriendsResponse) then) =
      _$FriendsResponseCopyWithImpl<$Res, FriendsResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'friends', fromJson: _parseFriends)
      List<Friend> friends});
}

/// @nodoc
class _$FriendsResponseCopyWithImpl<$Res, $Val extends FriendsResponse>
    implements $FriendsResponseCopyWith<$Res> {
  _$FriendsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friends = null,
  }) {
    return _then(_value.copyWith(
      friends: null == friends
          ? _value.friends
          : friends // ignore: cast_nullable_to_non_nullable
              as List<Friend>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FriendsResponseImplCopyWith<$Res>
    implements $FriendsResponseCopyWith<$Res> {
  factory _$$FriendsResponseImplCopyWith(_$FriendsResponseImpl value,
          $Res Function(_$FriendsResponseImpl) then) =
      __$$FriendsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'friends', fromJson: _parseFriends)
      List<Friend> friends});
}

/// @nodoc
class __$$FriendsResponseImplCopyWithImpl<$Res>
    extends _$FriendsResponseCopyWithImpl<$Res, _$FriendsResponseImpl>
    implements _$$FriendsResponseImplCopyWith<$Res> {
  __$$FriendsResponseImplCopyWithImpl(
      _$FriendsResponseImpl _value, $Res Function(_$FriendsResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of FriendsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friends = null,
  }) {
    return _then(_$FriendsResponseImpl(
      friends: null == friends
          ? _value._friends
          : friends // ignore: cast_nullable_to_non_nullable
              as List<Friend>,
    ));
  }
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$FriendsResponseImpl extends _FriendsResponse {
  const _$FriendsResponseImpl(
      {@JsonKey(name: 'friends', fromJson: _parseFriends)
      final List<Friend> friends = const []})
      : _friends = friends,
        super._();

  factory _$FriendsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendsResponseImplFromJson(json);

  final List<Friend> _friends;
  @override
  @JsonKey(name: 'friends', fromJson: _parseFriends)
  List<Friend> get friends {
    if (_friends is EqualUnmodifiableListView) return _friends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_friends);
  }

  @override
  String toString() {
    return 'FriendsResponse(friends: $friends)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendsResponseImpl &&
            const DeepCollectionEquality().equals(other._friends, _friends));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_friends));

  /// Create a copy of FriendsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendsResponseImplCopyWith<_$FriendsResponseImpl> get copyWith =>
      __$$FriendsResponseImplCopyWithImpl<_$FriendsResponseImpl>(
          this, _$identity);
}

abstract class _FriendsResponse extends FriendsResponse {
  const factory _FriendsResponse(
      {@JsonKey(name: 'friends', fromJson: _parseFriends)
      final List<Friend> friends}) = _$FriendsResponseImpl;
  const _FriendsResponse._() : super._();

  factory _FriendsResponse.fromJson(Map<String, dynamic> json) =
      _$FriendsResponseImpl.fromJson;

  @override
  @JsonKey(name: 'friends', fromJson: _parseFriends)
  List<Friend> get friends;

  /// Create a copy of FriendsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendsResponseImplCopyWith<_$FriendsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
