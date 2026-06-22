// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'dailyreward.dart';

part 'daily_rewards_response.freezed.dart';
part 'daily_rewards_response.g.dart';

List<DailyReward> _parsePastRewards(dynamic v) =>
    ((v ?? []) as List).map((e) => DailyReward.fromJson(e)).toList();

DailyReward _parseNextReward(dynamic v) =>
    v != null ? DailyReward.fromJson(v) : DailyReward.blank();

int _parseInt(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;

// Defaults double as a pre-deploy fallback: older servers omit these keys, so a
// null value must resolve to the historically-hardcoded constant, not 0.
int _parseCycleTotal(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 9;
int _parseFreq(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 84000;
int _parseReset(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 172800;

/// Typed result of GET /api/dailyrewards.
///
/// Dashboard state fields (coins, xp, guild, etc.) are present in the raw
/// response but are intentionally ignored here — userProvider handles those
/// via ref.invalidate(userProvider) after this data loads.
@Freezed(toJson: false)
class DailyRewardsResponse with _$DailyRewardsResponse {
  const DailyRewardsResponse._();

  const factory DailyRewardsResponse({
    @JsonKey(name: 'past_rewards', fromJson: _parsePastRewards)
    @Default([])
    List<DailyReward> pastRewards,
    @JsonKey(name: 'next_reward', fromJson: _parseNextReward)
    required DailyReward nextReward,
    @JsonKey(name: 'seconds_elapsed', fromJson: _parseInt)
    @Default(0)
    int secondsElapsed,
    // The full cycle (one entry per day) — powers the day-strip with previews
    // and lock states. Added server-side for the mobile "Archivist's Offering".
    @JsonKey(name: 'schedule', fromJson: _parsePastRewards)
    @Default([])
    List<DailyReward> schedule,
    @JsonKey(name: 'cycle_total', fromJson: _parseCycleTotal)
    @Default(9)
    int cycleTotal,
    @JsonKey(name: 'consecutive_recoveries', fromJson: _parseInt)
    @Default(0)
    int consecutiveRecoveries,
    @JsonKey(name: 'daily_reward_freq', fromJson: _parseFreq)
    @Default(84000)
    int dailyRewardFreq,
    @JsonKey(name: 'daily_reward_reset', fromJson: _parseReset)
    @Default(172800)
    int dailyRewardReset,
  }) = _DailyRewardsResponse;

  factory DailyRewardsResponse.fromJson(Map<String, dynamic> json) =>
      _$DailyRewardsResponseFromJson(json);

  static DailyRewardsResponse empty() =>
      DailyRewardsResponse(nextReward: DailyReward.blank());
}
