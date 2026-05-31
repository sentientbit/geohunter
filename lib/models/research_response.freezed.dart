// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'research_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ResearchResponse _$ResearchResponseFromJson(Map<String, dynamic> json) {
  return _ResearchResponse.fromJson(json);
}

/// @nodoc
mixin _$ResearchResponse {
  @JsonKey(name: 'techs', fromJson: _parseTechs)
  List<Research> get techs => throw _privateConstructorUsedError;
  @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
  List<Blueprint> get blueprints => throw _privateConstructorUsedError;

  /// Total manuscripts the player currently holds.
  /// Sent at the root of GET /api/research.
  int get manuscripts => throw _privateConstructorUsedError;

  /// Create a copy of ResearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResearchResponseCopyWith<ResearchResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResearchResponseCopyWith<$Res> {
  factory $ResearchResponseCopyWith(
          ResearchResponse value, $Res Function(ResearchResponse) then) =
      _$ResearchResponseCopyWithImpl<$Res, ResearchResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'techs', fromJson: _parseTechs) List<Research> techs,
      @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
      List<Blueprint> blueprints,
      int manuscripts});
}

/// @nodoc
class _$ResearchResponseCopyWithImpl<$Res, $Val extends ResearchResponse>
    implements $ResearchResponseCopyWith<$Res> {
  _$ResearchResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? techs = null,
    Object? blueprints = null,
    Object? manuscripts = null,
  }) {
    return _then(_value.copyWith(
      techs: null == techs
          ? _value.techs
          : techs // ignore: cast_nullable_to_non_nullable
              as List<Research>,
      blueprints: null == blueprints
          ? _value.blueprints
          : blueprints // ignore: cast_nullable_to_non_nullable
              as List<Blueprint>,
      manuscripts: null == manuscripts
          ? _value.manuscripts
          : manuscripts // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResearchResponseImplCopyWith<$Res>
    implements $ResearchResponseCopyWith<$Res> {
  factory _$$ResearchResponseImplCopyWith(_$ResearchResponseImpl value,
          $Res Function(_$ResearchResponseImpl) then) =
      __$$ResearchResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'techs', fromJson: _parseTechs) List<Research> techs,
      @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
      List<Blueprint> blueprints,
      int manuscripts});
}

/// @nodoc
class __$$ResearchResponseImplCopyWithImpl<$Res>
    extends _$ResearchResponseCopyWithImpl<$Res, _$ResearchResponseImpl>
    implements _$$ResearchResponseImplCopyWith<$Res> {
  __$$ResearchResponseImplCopyWithImpl(_$ResearchResponseImpl _value,
      $Res Function(_$ResearchResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? techs = null,
    Object? blueprints = null,
    Object? manuscripts = null,
  }) {
    return _then(_$ResearchResponseImpl(
      techs: null == techs
          ? _value._techs
          : techs // ignore: cast_nullable_to_non_nullable
              as List<Research>,
      blueprints: null == blueprints
          ? _value._blueprints
          : blueprints // ignore: cast_nullable_to_non_nullable
              as List<Blueprint>,
      manuscripts: null == manuscripts
          ? _value.manuscripts
          : manuscripts // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$ResearchResponseImpl extends _ResearchResponse {
  const _$ResearchResponseImpl(
      {@JsonKey(name: 'techs', fromJson: _parseTechs)
      final List<Research> techs = const [],
      @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
      final List<Blueprint> blueprints = const [],
      this.manuscripts = 0})
      : _techs = techs,
        _blueprints = blueprints,
        super._();

  factory _$ResearchResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResearchResponseImplFromJson(json);

  final List<Research> _techs;
  @override
  @JsonKey(name: 'techs', fromJson: _parseTechs)
  List<Research> get techs {
    if (_techs is EqualUnmodifiableListView) return _techs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_techs);
  }

  final List<Blueprint> _blueprints;
  @override
  @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
  List<Blueprint> get blueprints {
    if (_blueprints is EqualUnmodifiableListView) return _blueprints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blueprints);
  }

  /// Total manuscripts the player currently holds.
  /// Sent at the root of GET /api/research.
  @override
  @JsonKey()
  final int manuscripts;

  @override
  String toString() {
    return 'ResearchResponse(techs: $techs, blueprints: $blueprints, manuscripts: $manuscripts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResearchResponseImpl &&
            const DeepCollectionEquality().equals(other._techs, _techs) &&
            const DeepCollectionEquality()
                .equals(other._blueprints, _blueprints) &&
            (identical(other.manuscripts, manuscripts) ||
                other.manuscripts == manuscripts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_techs),
      const DeepCollectionEquality().hash(_blueprints),
      manuscripts);

  /// Create a copy of ResearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResearchResponseImplCopyWith<_$ResearchResponseImpl> get copyWith =>
      __$$ResearchResponseImplCopyWithImpl<_$ResearchResponseImpl>(
          this, _$identity);
}

abstract class _ResearchResponse extends ResearchResponse {
  const factory _ResearchResponse(
      {@JsonKey(name: 'techs', fromJson: _parseTechs)
      final List<Research> techs,
      @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
      final List<Blueprint> blueprints,
      final int manuscripts}) = _$ResearchResponseImpl;
  const _ResearchResponse._() : super._();

  factory _ResearchResponse.fromJson(Map<String, dynamic> json) =
      _$ResearchResponseImpl.fromJson;

  @override
  @JsonKey(name: 'techs', fromJson: _parseTechs)
  List<Research> get techs;
  @override
  @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
  List<Blueprint> get blueprints;

  /// Total manuscripts the player currently holds.
  /// Sent at the root of GET /api/research.
  @override
  int get manuscripts;

  /// Create a copy of ResearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResearchResponseImplCopyWith<_$ResearchResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
