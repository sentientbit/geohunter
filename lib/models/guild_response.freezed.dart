// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guild_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GuildResponse _$GuildResponseFromJson(Map<String, dynamic> json) {
  return _GuildResponse.fromJson(json);
}

/// @nodoc
mixin _$GuildResponse {
  @JsonKey(name: 'guilds', fromJson: _parseGuild)
  Guild get guild => throw _privateConstructorUsedError;

  /// Create a copy of GuildResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GuildResponseCopyWith<GuildResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GuildResponseCopyWith<$Res> {
  factory $GuildResponseCopyWith(
          GuildResponse value, $Res Function(GuildResponse) then) =
      _$GuildResponseCopyWithImpl<$Res, GuildResponse>;
  @useResult
  $Res call({@JsonKey(name: 'guilds', fromJson: _parseGuild) Guild guild});
}

/// @nodoc
class _$GuildResponseCopyWithImpl<$Res, $Val extends GuildResponse>
    implements $GuildResponseCopyWith<$Res> {
  _$GuildResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GuildResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guild = null,
  }) {
    return _then(_value.copyWith(
      guild: null == guild
          ? _value.guild
          : guild // ignore: cast_nullable_to_non_nullable
              as Guild,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GuildResponseImplCopyWith<$Res>
    implements $GuildResponseCopyWith<$Res> {
  factory _$$GuildResponseImplCopyWith(
          _$GuildResponseImpl value, $Res Function(_$GuildResponseImpl) then) =
      __$$GuildResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'guilds', fromJson: _parseGuild) Guild guild});
}

/// @nodoc
class __$$GuildResponseImplCopyWithImpl<$Res>
    extends _$GuildResponseCopyWithImpl<$Res, _$GuildResponseImpl>
    implements _$$GuildResponseImplCopyWith<$Res> {
  __$$GuildResponseImplCopyWithImpl(
      _$GuildResponseImpl _value, $Res Function(_$GuildResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of GuildResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guild = null,
  }) {
    return _then(_$GuildResponseImpl(
      guild: null == guild
          ? _value.guild
          : guild // ignore: cast_nullable_to_non_nullable
              as Guild,
    ));
  }
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$GuildResponseImpl extends _GuildResponse {
  const _$GuildResponseImpl(
      {@JsonKey(name: 'guilds', fromJson: _parseGuild) required this.guild})
      : super._();

  factory _$GuildResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GuildResponseImplFromJson(json);

  @override
  @JsonKey(name: 'guilds', fromJson: _parseGuild)
  final Guild guild;

  @override
  String toString() {
    return 'GuildResponse(guild: $guild)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GuildResponseImpl &&
            (identical(other.guild, guild) || other.guild == guild));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, guild);

  /// Create a copy of GuildResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GuildResponseImplCopyWith<_$GuildResponseImpl> get copyWith =>
      __$$GuildResponseImplCopyWithImpl<_$GuildResponseImpl>(this, _$identity);
}

abstract class _GuildResponse extends GuildResponse {
  const factory _GuildResponse(
      {@JsonKey(name: 'guilds', fromJson: _parseGuild)
      required final Guild guild}) = _$GuildResponseImpl;
  const _GuildResponse._() : super._();

  factory _GuildResponse.fromJson(Map<String, dynamic> json) =
      _$GuildResponseImpl.fromJson;

  @override
  @JsonKey(name: 'guilds', fromJson: _parseGuild)
  Guild get guild;

  /// Create a copy of GuildResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GuildResponseImplCopyWith<_$GuildResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
