import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/guild_list_response.dart';
import '../models/guild_response.dart';
import 'guild_repository.dart';
import 'user_provider.dart';

/// Holds the current user's guild detail (GET /api/guild/:id).
///
/// Automatically re-fetches when the user's guildId changes via userProvider.
/// Returns GuildResponse.empty() if the user is not in a guild (guildId == "0").
///
/// After guild mutations (edit, kick member, leave):
///   ref.invalidate(guildProvider)  — refreshes guild detail
///   ref.invalidate(userProvider)   — refreshes guildId / unread in drawer
class GuildNotifier extends AsyncNotifier<GuildResponse> {
  @override
  Future<GuildResponse> build() async {
    final user = await ref.watch(userProvider.future);
    final guildId = user.details.guildId;
    if (guildId == '0' || guildId.isEmpty) return GuildResponse.empty();
    return ref.read(guildRepositoryProvider).getGuild(guildId);
  }
}

final guildProvider =
    AsyncNotifierProvider<GuildNotifier, GuildResponse>(GuildNotifier.new);

/// Holds the public guild list (GET /api/guilds).
///
/// Used by the no-guild screen to browse and join guilds.
/// ref.invalidate(guildListProvider) to refresh after joining.
class GuildListNotifier extends AsyncNotifier<GuildListResponse> {
  @override
  Future<GuildListResponse> build() =>
      ref.read(guildRepositoryProvider).getGuildList();
}

final guildListProvider =
    AsyncNotifierProvider<GuildListNotifier, GuildListResponse>(
        GuildListNotifier.new);
