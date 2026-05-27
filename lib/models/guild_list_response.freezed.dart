// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guild_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GuildSummary _$GuildSummaryFromJson(Map<String, dynamic> json) {
  return _GuildSummary.fromJson(json);
}

/// @nodoc
mixin _$GuildSummary {
  @JsonKey(name: 'id', fromJson: _parseInt)
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'guid')
  String get guid => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_hidden', fromJson: _parseInt)
  int get isHidden => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_locked', fromJson: _parseInt)
  int get isLocked => throw _privateConstructorUsedError;

  /// Derived from the length of the users array in the response.
  @JsonKey(name: 'users', fromJson: _countUsers)
  int get nrUsers => throw _privateConstructorUsedError;

  /// Create a copy of GuildSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GuildSummaryCopyWith<GuildSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GuildSummaryCopyWith<$Res> {
  factory $GuildSummaryCopyWith(
          GuildSummary value, $Res Function(GuildSummary) then) =
      _$GuildSummaryCopyWithImpl<$Res, GuildSummary>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id', fromJson: _parseInt) int id,
      @JsonKey(name: 'guid') String guid,
      @JsonKey(name: 'name') String name,
      @JsonKey(name: 'is_hidden', fromJson: _parseInt) int isHidden,
      @JsonKey(name: 'is_locked', fromJson: _parseInt) int isLocked,
      @JsonKey(name: 'users', fromJson: _countUsers) int nrUsers});
}

/// @nodoc
class _$GuildSummaryCopyWithImpl<$Res, $Val extends GuildSummary>
    implements $GuildSummaryCopyWith<$Res> {
  _$GuildSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GuildSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? guid = null,
    Object? name = null,
    Object? isHidden = null,
    Object? isLocked = null,
    Object? nrUsers = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isHidden: null == isHidden
          ? _value.isHidden
          : isHidden // ignore: cast_nullable_to_non_nullable
              as int,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as int,
      nrUsers: null == nrUsers
          ? _value.nrUsers
          : nrUsers // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GuildSummaryImplCopyWith<$Res>
    implements $GuildSummaryCopyWith<$Res> {
  factory _$$GuildSummaryImplCopyWith(
          _$GuildSummaryImpl value, $Res Function(_$GuildSummaryImpl) then) =
      __$$GuildSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id', fromJson: _parseInt) int id,
      @JsonKey(name: 'guid') String guid,
      @JsonKey(name: 'name') String name,
      @JsonKey(name: 'is_hidden', fromJson: _parseInt) int isHidden,
      @JsonKey(name: 'is_locked', fromJson: _parseInt) int isLocked,
      @JsonKey(name: 'users', fromJson: _countUsers) int nrUsers});
}

/// @nodoc
class __$$GuildSummaryImplCopyWithImpl<$Res>
    extends _$GuildSummaryCopyWithImpl<$Res, _$GuildSummaryImpl>
    implements _$$GuildSummaryImplCopyWith<$Res> {
  __$$GuildSummaryImplCopyWithImpl(
      _$GuildSummaryImpl _value, $Res Function(_$GuildSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of GuildSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? guid = null,
    Object? name = null,
    Object? isHidden = null,
    Object? isLocked = null,
    Object? nrUsers = null,
  }) {
    return _then(_$GuildSummaryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isHidden: null == isHidden
          ? _value.isHidden
          : isHidden // ignore: cast_nullable_to_non_nullable
              as int,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as int,
      nrUsers: null == nrUsers
          ? _value.nrUsers
          : nrUsers // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$GuildSummaryImpl implements _GuildSummary {
  const _$GuildSummaryImpl(
      {@JsonKey(name: 'id', fromJson: _parseInt) this.id = 0,
      @JsonKey(name: 'guid') this.guid = '',
      @JsonKey(name: 'name') this.name = '',
      @JsonKey(name: 'is_hidden', fromJson: _parseInt) this.isHidden = 0,
      @JsonKey(name: 'is_locked', fromJson: _parseInt) this.isLocked = 0,
      @JsonKey(name: 'users', fromJson: _countUsers) this.nrUsers = 0});

  factory _$GuildSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$GuildSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'id', fromJson: _parseInt)
  final int id;
  @override
  @JsonKey(name: 'guid')
  final String guid;
  @override
  @JsonKey(name: 'name')
  final String name;
  @override
  @JsonKey(name: 'is_hidden', fromJson: _parseInt)
  final int isHidden;
  @override
  @JsonKey(name: 'is_locked', fromJson: _parseInt)
  final int isLocked;

  /// Derived from the length of the users array in the response.
  @override
  @JsonKey(name: 'users', fromJson: _countUsers)
  final int nrUsers;

  @override
  String toString() {
    return 'GuildSummary(id: $id, guid: $guid, name: $name, isHidden: $isHidden, isLocked: $isLocked, nrUsers: $nrUsers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GuildSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isHidden, isHidden) ||
                other.isHidden == isHidden) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked) &&
            (identical(other.nrUsers, nrUsers) || other.nrUsers == nrUsers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, guid, name, isHidden, isLocked, nrUsers);

  /// Create a copy of GuildSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GuildSummaryImplCopyWith<_$GuildSummaryImpl> get copyWith =>
      __$$GuildSummaryImplCopyWithImpl<_$GuildSummaryImpl>(this, _$identity);
}

abstract class _GuildSummary implements GuildSummary {
  const factory _GuildSummary(
          {@JsonKey(name: 'id', fromJson: _parseInt) final int id,
          @JsonKey(name: 'guid') final String guid,
          @JsonKey(name: 'name') final String name,
          @JsonKey(name: 'is_hidden', fromJson: _parseInt) final int isHidden,
          @JsonKey(name: 'is_locked', fromJson: _parseInt) final int isLocked,
          @JsonKey(name: 'users', fromJson: _countUsers) final int nrUsers}) =
      _$GuildSummaryImpl;

  factory _GuildSummary.fromJson(Map<String, dynamic> json) =
      _$GuildSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'id', fromJson: _parseInt)
  int get id;
  @override
  @JsonKey(name: 'guid')
  String get guid;
  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(name: 'is_hidden', fromJson: _parseInt)
  int get isHidden;
  @override
  @JsonKey(name: 'is_locked', fromJson: _parseInt)
  int get isLocked;

  /// Derived from the length of the users array in the response.
  @override
  @JsonKey(name: 'users', fromJson: _countUsers)
  int get nrUsers;

  /// Create a copy of GuildSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GuildSummaryImplCopyWith<_$GuildSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GuildListResponse _$GuildListResponseFromJson(Map<String, dynamic> json) {
  return _GuildListResponse.fromJson(json);
}

/// @nodoc
mixin _$GuildListResponse {
  @JsonKey(name: 'guilds', fromJson: _parseGuilds)
  List<GuildSummary> get guilds => throw _privateConstructorUsedError;

  /// Create a copy of GuildListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GuildListResponseCopyWith<GuildListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GuildListResponseCopyWith<$Res> {
  factory $GuildListResponseCopyWith(
          GuildListResponse value, $Res Function(GuildListResponse) then) =
      _$GuildListResponseCopyWithImpl<$Res, GuildListResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'guilds', fromJson: _parseGuilds)
      List<GuildSummary> guilds});
}

/// @nodoc
class _$GuildListResponseCopyWithImpl<$Res, $Val extends GuildListResponse>
    implements $GuildListResponseCopyWith<$Res> {
  _$GuildListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GuildListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guilds = null,
  }) {
    return _then(_value.copyWith(
      guilds: null == guilds
          ? _value.guilds
          : guilds // ignore: cast_nullable_to_non_nullable
              as List<GuildSummary>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GuildListResponseImplCopyWith<$Res>
    implements $GuildListResponseCopyWith<$Res> {
  factory _$$GuildListResponseImplCopyWith(_$GuildListResponseImpl value,
          $Res Function(_$GuildListResponseImpl) then) =
      __$$GuildListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'guilds', fromJson: _parseGuilds)
      List<GuildSummary> guilds});
}

/// @nodoc
class __$$GuildListResponseImplCopyWithImpl<$Res>
    extends _$GuildListResponseCopyWithImpl<$Res, _$GuildListResponseImpl>
    implements _$$GuildListResponseImplCopyWith<$Res> {
  __$$GuildListResponseImplCopyWithImpl(_$GuildListResponseImpl _value,
      $Res Function(_$GuildListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of GuildListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guilds = null,
  }) {
    return _then(_$GuildListResponseImpl(
      guilds: null == guilds
          ? _value._guilds
          : guilds // ignore: cast_nullable_to_non_nullable
              as List<GuildSummary>,
    ));
  }
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$GuildListResponseImpl extends _GuildListResponse {
  const _$GuildListResponseImpl(
      {@JsonKey(name: 'guilds', fromJson: _parseGuilds)
      final List<GuildSummary> guilds = const []})
      : _guilds = guilds,
        super._();

  factory _$GuildListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GuildListResponseImplFromJson(json);

  final List<GuildSummary> _guilds;
  @override
  @JsonKey(name: 'guilds', fromJson: _parseGuilds)
  List<GuildSummary> get guilds {
    if (_guilds is EqualUnmodifiableListView) return _guilds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_guilds);
  }

  @override
  String toString() {
    return 'GuildListResponse(guilds: $guilds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GuildListResponseImpl &&
            const DeepCollectionEquality().equals(other._guilds, _guilds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_guilds));

  /// Create a copy of GuildListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GuildListResponseImplCopyWith<_$GuildListResponseImpl> get copyWith =>
      __$$GuildListResponseImplCopyWithImpl<_$GuildListResponseImpl>(
          this, _$identity);
}

abstract class _GuildListResponse extends GuildListResponse {
  const factory _GuildListResponse(
      {@JsonKey(name: 'guilds', fromJson: _parseGuilds)
      final List<GuildSummary> guilds}) = _$GuildListResponseImpl;
  const _GuildListResponse._() : super._();

  factory _GuildListResponse.fromJson(Map<String, dynamic> json) =
      _$GuildListResponseImpl.fromJson;

  @override
  @JsonKey(name: 'guilds', fromJson: _parseGuilds)
  List<GuildSummary> get guilds;

  /// Create a copy of GuildListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GuildListResponseImplCopyWith<_$GuildListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
