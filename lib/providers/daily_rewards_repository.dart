import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_rewards_response.dart';
import 'api_provider.dart';

/// Fetches the player's daily reward calendar from the server.
class DailyRewardsRepository {
  final ApiProvider _api = ApiProvider();

  Future<DailyRewardsResponse> getDailyRewards() async {
    final response = await _api.get('/dailyrewards');
    return DailyRewardsResponse.fromJson(response);
  }
}

final dailyRewardsRepositoryProvider =
    Provider<DailyRewardsRepository>((ref) => DailyRewardsRepository());
