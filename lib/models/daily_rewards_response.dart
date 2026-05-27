import 'dailyreward.dart';

/// Typed result of GET /api/dailyrewards.
///
/// Dashboard state fields (coins, xp, guild, etc.) are present in the raw
/// response but are intentionally ignored here — userProvider handles those
/// via ref.invalidate(userProvider) after this data loads.
class DailyRewardsResponse {
  final List<DailyReward> pastRewards;
  final DailyReward nextReward;
  final int secondsElapsed;

  const DailyRewardsResponse({
    required this.pastRewards,
    required this.nextReward,
    required this.secondsElapsed,
  });

  factory DailyRewardsResponse.empty() => DailyRewardsResponse(
        pastRewards: const [],
        nextReward: DailyReward.blank(),
        secondsElapsed: 0,
      );

  factory DailyRewardsResponse.fromJson(Map<String, dynamic> json) {
    return DailyRewardsResponse(
      pastRewards: ((json['past_rewards'] ?? []) as List)
          .map((e) => DailyReward.fromJson(e))
          .toList(),
      nextReward: json['next_reward'] != null
          ? DailyReward.fromJson(json['next_reward'])
          : DailyReward.blank(),
      secondsElapsed:
          int.tryParse(json['seconds_elapsed']?.toString() ?? '0') ?? 0,
    );
  }
}
