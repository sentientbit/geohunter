/// Typed wrappers for the positional arrays returned by /equipment and /research.
/// Replaces raw List<dynamic> access like settings[0], attack[0], etc.

// ── Settings ─────────────────────────────────────────────────────────────────

class PlayerSettings {
  /// 0 = off, >0 = volume level  (stat key 100)
  final int music;

  /// 0 = off, 1 = on  (stat key 101)
  final int notifications;

  /// 0 = off, >0 = on  (stat key 102)
  final int sounds;

  /// 0 = off, 1 = on  (stat key 103)
  final int vibrate;

  const PlayerSettings({
    required this.music,
    required this.notifications,
    this.sounds = 0,
    this.vibrate = 0,
  });

  factory PlayerSettings.fromList(List<dynamic> s) {
    if (s.length < 2) return const PlayerSettings(music: 0, notifications: 0);
    return PlayerSettings(
      music: int.tryParse(s[0].toString()) ?? 0,
      notifications: int.tryParse(s[1].toString()) ?? 0,
      sounds: s.length > 2 ? (int.tryParse(s[2].toString()) ?? 0) : 0,
      vibrate: s.length > 3 ? (int.tryParse(s[3].toString()) ?? 0) : 0,
    );
  }

  bool get isMusicOn => music > 0;
  bool get isNotificationsOn => notifications > 0;
  bool get isSoundsOn => sounds > 0;
  bool get isVibrateOn => vibrate > 0;

  List<dynamic> toList() => [music, notifications, sounds, vibrate];

  PlayerSettings copyWith({int? music, int? notifications, int? sounds, int? vibrate}) =>
      PlayerSettings(
        music: music ?? this.music,
        notifications: notifications ?? this.notifications,
        sounds: sounds ?? this.sounds,
        vibrate: vibrate ?? this.vibrate,
      );

  @override
  String toString() =>
      'PlayerSettings(music: $music, notifications: $notifications, sounds: $sounds, vibrate: $vibrate)';
}

// ── Action costs ──────────────────────────────────────────────────────────────

class ActionCosts {
  final double mining;
  final double research;
  final double crafting;

  const ActionCosts({
    required this.mining,
    required this.research,
    required this.crafting,
  });

  const ActionCosts.defaults()
      : mining = 0.1,
        research = 0.1,
        crafting = 0.1;

  factory ActionCosts.fromList(List<dynamic> c) {
    if (c.length < 3) return const ActionCosts.defaults();
    return ActionCosts(
      mining: double.tryParse(c[0].toString()) ?? 0.1,
      research: double.tryParse(c[1].toString()) ?? 0.1,
      crafting: double.tryParse(c[2].toString()) ?? 0.1,
    );
  }

  List<dynamic> toList() => [mining, research, crafting];

  @override
  String toString() =>
      'ActionCosts(mining: $mining, research: $research, crafting: $crafting)';
}

// ── Combat stat range ─────────────────────────────────────────────────────────

class StatRange {
  final double min;
  final double max;

  const StatRange({required this.min, required this.max});

  const StatRange.zero()
      : min = 0,
        max = 0;

  factory StatRange.fromList(List<dynamic> a) {
    if (a.length < 2) return const StatRange.zero();
    return StatRange(
      min: double.tryParse(a[0].toString()) ?? 0,
      max: double.tryParse(a[1].toString()) ?? 0,
    );
  }

  List<dynamic> toList() => [min, max];

  @override
  String toString() => 'StatRange($min–$max)';
}
