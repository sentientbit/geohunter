// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_rewards_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailyRewardsResponse _$DailyRewardsResponseFromJson(Map<String, dynamic> json) {
  return _DailyRewardsResponse.fromJson(json);
}

/// @nodoc
mixin _$DailyRewardsResponse {
  @JsonKey(name: 'past_rewards', fromJson: _parsePastRewards)
  List<DailyReward> get pastRewards => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_reward', fromJson: _parseNextReward)
  DailyReward get nextReward => throw _privateConstructorUsedError;
  @JsonKey(name: 'seconds_elapsed', fromJson: _parseInt)
  int get secondsElapsed => throw _privateConstructorUsedError;

  /// Create a copy of DailyRewardsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyRewardsResponseCopyWith<DailyRewardsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyRewardsResponseCopyWith<$Res> {
  factory $DailyRewardsResponseCopyWith(DailyRewardsResponse value,
          $Res Function(DailyRewardsResponse) then) =
      _$DailyRewardsResponseCopyWithImpl<$Res, DailyRewardsResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'past_rewards', fromJson: _parsePastRewards)
      List<DailyReward> pastRewards,
      @JsonKey(name: 'next_reward', fromJson: _parseNextReward)
      DailyReward nextReward,
      @JsonKey(name: 'seconds_elapsed', fromJson: _parseInt)
      int secondsElapsed});
}

/// @nodoc
class _$DailyRewardsResponseCopyWithImpl<$Res,
        $Val extends DailyRewardsResponse>
    implements $DailyRewardsResponseCopyWith<$Res> {
  _$DailyRewardsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyRewardsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pastRewards = null,
    Object? nextReward = null,
    Object? secondsElapsed = null,
  }) {
    return _then(_value.copyWith(
      pastRewards: null == pastRewards
          ? _value.pastRewards
          : pastRewards // ignore: cast_nullable_to_non_nullable
              as List<DailyReward>,
      nextReward: null == nextReward
          ? _value.nextReward
          : nextReward // ignore: cast_nullable_to_non_nullable
              as DailyReward,
      secondsElapsed: null == secondsElapsed
          ? _value.secondsElapsed
          : secondsElapsed // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyRewardsResponseImplCopyWith<$Res>
    implements $DailyRewardsResponseCopyWith<$Res> {
  factory _$$DailyRewardsResponseImplCopyWith(_$DailyRewardsResponseImpl value,
          $Res Function(_$DailyRewardsResponseImpl) then) =
      __$$DailyRewardsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'past_rewards', fromJson: _parsePastRewards)
      List<DailyReward> pastRewards,
      @JsonKey(name: 'next_reward', fromJson: _parseNextReward)
      DailyReward nextReward,
      @JsonKey(name: 'seconds_elapsed', fromJson: _parseInt)
      int secondsElapsed});
}

/// @nodoc
class __$$DailyRewardsResponseImplCopyWithImpl<$Res>
    extends _$DailyRewardsResponseCopyWithImpl<$Res, _$DailyRewardsResponseImpl>
    implements _$$DailyRewardsResponseImplCopyWith<$Res> {
  __$$DailyRewardsResponseImplCopyWithImpl(_$DailyRewardsResponseImpl _value,
      $Res Function(_$DailyRewardsResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyRewardsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pastRewards = null,
    Object? nextReward = null,
    Object? secondsElapsed = null,
  }) {
    return _then(_$DailyRewardsResponseImpl(
      pastRewards: null == pastRewards
          ? _value._pastRewards
          : pastRewards // ignore: cast_nullable_to_non_nullable
              as List<DailyReward>,
      nextReward: null == nextReward
          ? _value.nextReward
          : nextReward // ignore: cast_nullable_to_non_nullable
              as DailyReward,
      secondsElapsed: null == secondsElapsed
          ? _value.secondsElapsed
          : secondsElapsed // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$DailyRewardsResponseImpl extends _DailyRewardsResponse {
  const _$DailyRewardsResponseImpl(
      {@JsonKey(name: 'past_rewards', fromJson: _parsePastRewards)
      final List<DailyReward> pastRewards = const [],
      @JsonKey(name: 'next_reward', fromJson: _parseNextReward)
      required this.nextReward,
      @JsonKey(name: 'seconds_elapsed', fromJson: _parseInt)
      this.secondsElapsed = 0})
      : _pastRewards = pastRewards,
        super._();

  factory _$DailyRewardsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyRewardsResponseImplFromJson(json);

  final List<DailyReward> _pastRewards;
  @override
  @JsonKey(name: 'past_rewards', fromJson: _parsePastRewards)
  List<DailyReward> get pastRewards {
    if (_pastRewards is EqualUnmodifiableListView) return _pastRewards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pastRewards);
  }

  @override
  @JsonKey(name: 'next_reward', fromJson: _parseNextReward)
  final DailyReward nextReward;
  @override
  @JsonKey(name: 'seconds_elapsed', fromJson: _parseInt)
  final int secondsElapsed;

  @override
  String toString() {
    return 'DailyRewardsResponse(pastRewards: $pastRewards, nextReward: $nextReward, secondsElapsed: $secondsElapsed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyRewardsResponseImpl &&
            const DeepCollectionEquality()
                .equals(other._pastRewards, _pastRewards) &&
            (identical(other.nextReward, nextReward) ||
                other.nextReward == nextReward) &&
            (identical(other.secondsElapsed, secondsElapsed) ||
                other.secondsElapsed == secondsElapsed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_pastRewards),
      nextReward,
      secondsElapsed);

  /// Create a copy of DailyRewardsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyRewardsResponseImplCopyWith<_$DailyRewardsResponseImpl>
      get copyWith =>
          __$$DailyRewardsResponseImplCopyWithImpl<_$DailyRewardsResponseImpl>(
              this, _$identity);
}

abstract class _DailyRewardsResponse extends DailyRewardsResponse {
  const factory _DailyRewardsResponse(
      {@JsonKey(name: 'past_rewards', fromJson: _parsePastRewards)
      final List<DailyReward> pastRewards,
      @JsonKey(name: 'next_reward', fromJson: _parseNextReward)
      required final DailyReward nextReward,
      @JsonKey(name: 'seconds_elapsed', fromJson: _parseInt)
      final int secondsElapsed}) = _$DailyRewardsResponseImpl;
  const _DailyRewardsResponse._() : super._();

  factory _DailyRewardsResponse.fromJson(Map<String, dynamic> json) =
      _$DailyRewardsResponseImpl.fromJson;

  @override
  @JsonKey(name: 'past_rewards', fromJson: _parsePastRewards)
  List<DailyReward> get pastRewards;
  @override
  @JsonKey(name: 'next_reward', fromJson: _parseNextReward)
  DailyReward get nextReward;
  @override
  @JsonKey(name: 'seconds_elapsed', fromJson: _parseInt)
  int get secondsElapsed;

  /// Create a copy of DailyRewardsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyRewardsResponseImplCopyWith<_$DailyRewardsResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
