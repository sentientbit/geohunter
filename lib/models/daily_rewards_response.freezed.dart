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
  int get secondsElapsed =>
      throw _privateConstructorUsedError; // The full cycle (one entry per day) — powers the day-strip with previews
// and lock states. Added server-side for the mobile "Archivist's Offering".
  @JsonKey(name: 'schedule', fromJson: _parsePastRewards)
  List<DailyReward> get schedule => throw _privateConstructorUsedError;
  @JsonKey(name: 'cycle_total', fromJson: _parseCycleTotal)
  int get cycleTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'consecutive_recoveries', fromJson: _parseInt)
  int get consecutiveRecoveries => throw _privateConstructorUsedError;
  @JsonKey(name: 'daily_reward_freq', fromJson: _parseFreq)
  int get dailyRewardFreq => throw _privateConstructorUsedError;
  @JsonKey(name: 'daily_reward_reset', fromJson: _parseReset)
  int get dailyRewardReset => throw _privateConstructorUsedError;

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
      @JsonKey(name: 'seconds_elapsed', fromJson: _parseInt) int secondsElapsed,
      @JsonKey(name: 'schedule', fromJson: _parsePastRewards)
      List<DailyReward> schedule,
      @JsonKey(name: 'cycle_total', fromJson: _parseCycleTotal) int cycleTotal,
      @JsonKey(name: 'consecutive_recoveries', fromJson: _parseInt)
      int consecutiveRecoveries,
      @JsonKey(name: 'daily_reward_freq', fromJson: _parseFreq)
      int dailyRewardFreq,
      @JsonKey(name: 'daily_reward_reset', fromJson: _parseReset)
      int dailyRewardReset});
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
    Object? schedule = null,
    Object? cycleTotal = null,
    Object? consecutiveRecoveries = null,
    Object? dailyRewardFreq = null,
    Object? dailyRewardReset = null,
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
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as List<DailyReward>,
      cycleTotal: null == cycleTotal
          ? _value.cycleTotal
          : cycleTotal // ignore: cast_nullable_to_non_nullable
              as int,
      consecutiveRecoveries: null == consecutiveRecoveries
          ? _value.consecutiveRecoveries
          : consecutiveRecoveries // ignore: cast_nullable_to_non_nullable
              as int,
      dailyRewardFreq: null == dailyRewardFreq
          ? _value.dailyRewardFreq
          : dailyRewardFreq // ignore: cast_nullable_to_non_nullable
              as int,
      dailyRewardReset: null == dailyRewardReset
          ? _value.dailyRewardReset
          : dailyRewardReset // ignore: cast_nullable_to_non_nullable
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
      @JsonKey(name: 'seconds_elapsed', fromJson: _parseInt) int secondsElapsed,
      @JsonKey(name: 'schedule', fromJson: _parsePastRewards)
      List<DailyReward> schedule,
      @JsonKey(name: 'cycle_total', fromJson: _parseCycleTotal) int cycleTotal,
      @JsonKey(name: 'consecutive_recoveries', fromJson: _parseInt)
      int consecutiveRecoveries,
      @JsonKey(name: 'daily_reward_freq', fromJson: _parseFreq)
      int dailyRewardFreq,
      @JsonKey(name: 'daily_reward_reset', fromJson: _parseReset)
      int dailyRewardReset});
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
    Object? schedule = null,
    Object? cycleTotal = null,
    Object? consecutiveRecoveries = null,
    Object? dailyRewardFreq = null,
    Object? dailyRewardReset = null,
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
      schedule: null == schedule
          ? _value._schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as List<DailyReward>,
      cycleTotal: null == cycleTotal
          ? _value.cycleTotal
          : cycleTotal // ignore: cast_nullable_to_non_nullable
              as int,
      consecutiveRecoveries: null == consecutiveRecoveries
          ? _value.consecutiveRecoveries
          : consecutiveRecoveries // ignore: cast_nullable_to_non_nullable
              as int,
      dailyRewardFreq: null == dailyRewardFreq
          ? _value.dailyRewardFreq
          : dailyRewardFreq // ignore: cast_nullable_to_non_nullable
              as int,
      dailyRewardReset: null == dailyRewardReset
          ? _value.dailyRewardReset
          : dailyRewardReset // ignore: cast_nullable_to_non_nullable
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
      this.secondsElapsed = 0,
      @JsonKey(name: 'schedule', fromJson: _parsePastRewards)
      final List<DailyReward> schedule = const [],
      @JsonKey(name: 'cycle_total', fromJson: _parseCycleTotal)
      this.cycleTotal = 9,
      @JsonKey(name: 'consecutive_recoveries', fromJson: _parseInt)
      this.consecutiveRecoveries = 0,
      @JsonKey(name: 'daily_reward_freq', fromJson: _parseFreq)
      this.dailyRewardFreq = 84000,
      @JsonKey(name: 'daily_reward_reset', fromJson: _parseReset)
      this.dailyRewardReset = 172800})
      : _pastRewards = pastRewards,
        _schedule = schedule,
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
// The full cycle (one entry per day) — powers the day-strip with previews
// and lock states. Added server-side for the mobile "Archivist's Offering".
  final List<DailyReward> _schedule;
// The full cycle (one entry per day) — powers the day-strip with previews
// and lock states. Added server-side for the mobile "Archivist's Offering".
  @override
  @JsonKey(name: 'schedule', fromJson: _parsePastRewards)
  List<DailyReward> get schedule {
    if (_schedule is EqualUnmodifiableListView) return _schedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedule);
  }

  @override
  @JsonKey(name: 'cycle_total', fromJson: _parseCycleTotal)
  final int cycleTotal;
  @override
  @JsonKey(name: 'consecutive_recoveries', fromJson: _parseInt)
  final int consecutiveRecoveries;
  @override
  @JsonKey(name: 'daily_reward_freq', fromJson: _parseFreq)
  final int dailyRewardFreq;
  @override
  @JsonKey(name: 'daily_reward_reset', fromJson: _parseReset)
  final int dailyRewardReset;

  @override
  String toString() {
    return 'DailyRewardsResponse(pastRewards: $pastRewards, nextReward: $nextReward, secondsElapsed: $secondsElapsed, schedule: $schedule, cycleTotal: $cycleTotal, consecutiveRecoveries: $consecutiveRecoveries, dailyRewardFreq: $dailyRewardFreq, dailyRewardReset: $dailyRewardReset)';
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
                other.secondsElapsed == secondsElapsed) &&
            const DeepCollectionEquality().equals(other._schedule, _schedule) &&
            (identical(other.cycleTotal, cycleTotal) ||
                other.cycleTotal == cycleTotal) &&
            (identical(other.consecutiveRecoveries, consecutiveRecoveries) ||
                other.consecutiveRecoveries == consecutiveRecoveries) &&
            (identical(other.dailyRewardFreq, dailyRewardFreq) ||
                other.dailyRewardFreq == dailyRewardFreq) &&
            (identical(other.dailyRewardReset, dailyRewardReset) ||
                other.dailyRewardReset == dailyRewardReset));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_pastRewards),
      nextReward,
      secondsElapsed,
      const DeepCollectionEquality().hash(_schedule),
      cycleTotal,
      consecutiveRecoveries,
      dailyRewardFreq,
      dailyRewardReset);

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
      final int secondsElapsed,
      @JsonKey(name: 'schedule', fromJson: _parsePastRewards)
      final List<DailyReward> schedule,
      @JsonKey(name: 'cycle_total', fromJson: _parseCycleTotal)
      final int cycleTotal,
      @JsonKey(name: 'consecutive_recoveries', fromJson: _parseInt)
      final int consecutiveRecoveries,
      @JsonKey(name: 'daily_reward_freq', fromJson: _parseFreq)
      final int dailyRewardFreq,
      @JsonKey(name: 'daily_reward_reset', fromJson: _parseReset)
      final int dailyRewardReset}) = _$DailyRewardsResponseImpl;
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
  int get secondsElapsed; // The full cycle (one entry per day) — powers the day-strip with previews
// and lock states. Added server-side for the mobile "Archivist's Offering".
  @override
  @JsonKey(name: 'schedule', fromJson: _parsePastRewards)
  List<DailyReward> get schedule;
  @override
  @JsonKey(name: 'cycle_total', fromJson: _parseCycleTotal)
  int get cycleTotal;
  @override
  @JsonKey(name: 'consecutive_recoveries', fromJson: _parseInt)
  int get consecutiveRecoveries;
  @override
  @JsonKey(name: 'daily_reward_freq', fromJson: _parseFreq)
  int get dailyRewardFreq;
  @override
  @JsonKey(name: 'daily_reward_reset', fromJson: _parseReset)
  int get dailyRewardReset;

  /// Create a copy of DailyRewardsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyRewardsResponseImplCopyWith<_$DailyRewardsResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
