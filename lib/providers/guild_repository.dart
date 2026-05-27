import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/guild_list_response.dart';
import '../models/guild_response.dart';
import 'api_provider.dart';

/// Fetches guild data from the server.
class GuildRepository {
  final ApiProvider _api = ApiProvider();

  /// GET /api/guild/:guildId — full guild detail with members.
  Future<GuildResponse> getGuild(String guildId) async {
    final response = await _api.get('/guild/$guildId');
    return GuildResponse.fromJson(response);
  }

  /// GET /api/guilds — public guild list (lightweight, no full user objects).
  Future<GuildListResponse> getGuildList() async {
    final response = await _api.get('/guilds');
    return GuildListResponse.fromJson(response);
  }
}

final guildRepositoryProvider =
    Provider<GuildRepository>((ref) => GuildRepository());
