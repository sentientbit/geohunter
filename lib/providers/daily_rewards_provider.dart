import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_rewards_response.dart';
import 'daily_rewards_repository.dart';

/// Holds the player's daily reward calendar (past rewards + next reward).
///
/// After a successful claim call:
///   ref.invalidate(dailyRewardsProvider) — refreshes past/next rewards
///   ref.invalidate(userProvider)         — refreshes coins/xp/daily counter
class DailyRewardsNotifier extends AsyncNotifier<DailyRewardsResponse> {
  @override
  Future<DailyRewardsResponse> build() =>
      ref.read(dailyRewardsRepositoryProvider).getDailyRewards();
}

final dailyRewardsProvider =
    AsyncNotifierProvider<DailyRewardsNotifier, DailyRewardsResponse>(
        DailyRewardsNotifier.new);
