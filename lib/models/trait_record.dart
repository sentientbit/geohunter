/// One trait the player has earned — a Discovery, a Reputation, or a Mark.
///
/// These are the Journal's equivalent of Fallen London "qualities": the things
/// you accumulate that gate future pages. The player record groups them by
/// [kind] so the UI can show three labelled shelves.
class TraitRecord {
  final String slug;
  final String name;
  final String description;
  final String img;

  /// "discovery" | "reputation" | "mark"
  final String kind;

  final int value;

  const TraitRecord({
    required this.slug,
    required this.name,
    this.description = '',
    this.img = '',
    this.kind = '',
    this.value = 0,
  });

  factory TraitRecord.fromJson(dynamic json) {
    final map = (json as Map?) ?? const {};
    return TraitRecord(
      slug: map['slug']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      img: map['img']?.toString() ?? '',
      kind: map['kind']?.toString() ?? '',
      value: int.tryParse(map['value']?.toString() ?? '0') ?? 0,
    );
  }
}

/// The player's full trait record, grouped by kind (from `data.record`).
class JournalRecord {
  final List<TraitRecord> discovery;
  final List<TraitRecord> reputation;
  final List<TraitRecord> mark;

  const JournalRecord({
    this.discovery = const [],
    this.reputation = const [],
    this.mark = const [],
  });

  bool get isEmpty =>
      discovery.isEmpty && reputation.isEmpty && mark.isEmpty;

  factory JournalRecord.fromJson(dynamic json) {
    final map = (json as Map?) ?? const {};
    List<TraitRecord> parse(String key) =>
        (map[key] as List?)?.map((e) => TraitRecord.fromJson(e)).toList() ??
        const [];
    return JournalRecord(
      discovery: parse('discovery'),
      reputation: parse('reputation'),
      mark: parse('mark'),
    );
  }
}
