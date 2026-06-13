/// A single world-action that gates a locked Journal page.
///
/// The Keeper surfaces a page in `locked[]` only when the story prerequisite is
/// already met and the one missing thing is a real-world action — visiting a
/// place, gathering materials. [ico] is the authoritative map filter key: it is
/// the LOC_TYPE integer the POI map / Places list already filters by, so the
/// "Show X nearby" button can deep-link straight to it.
class JournalGate {
  /// "location" | "materials" | "mark"
  final String type;

  /// LOC_TYPE the map POI filter uses (1 forge, 2 woodland, 3 tannery,
  /// 6 ruin, 7 library, 8 market). 0 = no single POI (e.g. mine anywhere).
  final int ico;

  /// Convenience label: forge|woodland|tannery|ruin|library|market ('' if N/A).
  final String poi;

  /// Self-describing, localized human label ("Visit a woodland"). Backend
  /// contract: present on every gate, equal to the parallel reasons[] entry.
  /// Use this directly for display — no index-coupling needed.
  final String label;

  final int have;
  final int need;

  /// The underlying trait slug driving this gate (diagnostic; not shown).
  final String trait;

  const JournalGate({
    required this.type,
    required this.ico,
    required this.poi,
    required this.label,
    required this.have,
    required this.need,
    required this.trait,
  });

  /// True when this gate is a real-world action the player can act on from the
  /// map: a place to walk to (ico>0) or "mine anywhere" (materials). Backend no
  /// longer emits story-sequence (ico:0 mark) gates, so everything here is
  /// actionable, but this stays defensive.
  bool get isActionable => ico > 0 || type == 'materials';

  /// True once the player has satisfied this gate (defensive: backend only
  /// lists unmet gates, but we never want a full bar to read as incomplete).
  bool get isMet => have >= need;

  /// 0.0–1.0 progress toward the requirement.
  double get progress =>
      need > 0 ? (have / need).clamp(0.0, 1.0) : 0.0;

  factory JournalGate.fromJson(dynamic json) {
    final map = (json as Map?) ?? const {};
    return JournalGate(
      type: map['type']?.toString() ?? 'location',
      ico: int.tryParse(map['ico']?.toString() ?? '0') ?? 0,
      poi: map['poi']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      have: int.tryParse(map['have']?.toString() ?? '0') ?? 0,
      need: int.tryParse(map['need']?.toString() ?? '1') ?? 1,
      trait: map['trait']?.toString() ?? '',
    );
  }
}
