/// Shared helper — applies a GET /equipment response to a [User] object.
///
/// Both [RockPaperScissorsPage] and [SettingsPage] call GET /equipment on
/// init to hydrate fresh user data.  The field-mapping logic was previously
/// duplicated in each screen's private `_getUserDetails()`.  This file is the
/// single source of truth for that mapping.
///
/// Screen-specific derived state (battle stats, slider values, settings
/// fallback logic) remains in each screen's own handler — only the common
/// field assignments live here.
library equipment_loader;

import '../models/user.dart';
import '../models/player_stats.dart';

/// Applies all common fields from a GET /equipment [response] to [user].
///
/// Returns the same [user] instance (mutated in-place) for convenience.
/// Does nothing if [response] does not contain the expected "coins" key.
User applyEquipmentResponse(User user, Map<String, dynamic> response) {
  if (!response.containsKey('coins')) return user;

  user.details.coins =
      double.tryParse(response['coins'].toString()) ?? user.details.coins;
  user.details.guildId =
      (response['guild']?['id'] ?? user.details.guildId).toString();
  user.details.mining = response['mining'] ?? user.details.mining;
  user.details.xp = response['xp'] ?? user.details.xp;
  user.details.unread = ((response['unread'] ?? []) as List)
      .map((e) => (e as num).toInt())
      .toList();
  user.details.attack =
      StatRange.fromList((response['attack'] ?? []) as List);
  user.details.defense =
      StatRange.fromList((response['defense'] ?? []) as List);
  user.details.daily = response['daily'] ?? user.details.daily;
  user.details.costs =
      ActionCosts.fromList((response['costs'] ?? [0.1, 0.1, 0.1]) as List);

  // Settings: only overwrite when the server sends a settings key.
  // Settings screen handles the else-branch itself (falls back to local
  // slider values), so we only write here on explicit server data.
  if (response.containsKey('settings')) {
    user.details.settings = PlayerSettings.fromList(
        (response['settings'] ?? [0, 0, 0]) as List);
  }

  return user;
}
