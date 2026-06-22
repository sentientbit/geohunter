// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_rewards_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyRewardsResponseImpl _$$DailyRewardsResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$DailyRewardsResponseImpl(
      pastRewards: json['past_rewards'] == null
          ? const []
          : _parsePastRewards(json['past_rewards']),
      nextReward: _parseNextReward(json['next_reward']),
      secondsElapsed: json['seconds_elapsed'] == null
          ? 0
          : _parseInt(json['seconds_elapsed']),
      schedule: json['schedule'] == null
          ? const []
          : _parsePastRewards(json['schedule']),
      cycleTotal: json['cycle_total'] == null
          ? 9
          : _parseCycleTotal(json['cycle_total']),
      consecutiveRecoveries: json['consecutive_recoveries'] == null
          ? 0
          : _parseInt(json['consecutive_recoveries']),
      dailyRewardFreq: json['daily_reward_freq'] == null
          ? 84000
          : _parseFreq(json['daily_reward_freq']),
      dailyRewardReset: json['daily_reward_reset'] == null
          ? 172800
          : _parseReset(json['daily_reward_reset']),
    );
