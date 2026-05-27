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
    );
