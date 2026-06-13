import 'journal_card.dart';
import 'trait_record.dart';

/// The whole Journal landing payload from `GET /api/journal`.
///
///   available — pages open to play now
///   locked    — the trail ahead: reachable pages blocked only by a world-action
///   recovered — the re-readable archive
///   record    — the player's traits (Discoveries / Reputation / Marks)
class JournalOverview {
  final List<JournalCard> available;
  final List<JournalCard> locked;
  final List<JournalCard> recovered;
  final JournalRecord record;

  const JournalOverview({
    this.available = const [],
    this.locked = const [],
    this.recovered = const [],
    this.record = const JournalRecord(),
  });

  factory JournalOverview.fromJson(Map<String, dynamic> json) {
    List<JournalCard> parse(String key) =>
        (json[key] as List?)?.map((e) => JournalCard.fromJson(e)).toList() ??
        const [];
    return JournalOverview(
      available: parse('available'),
      locked: parse('locked'),
      recovered: parse('recovered'),
      record: JournalRecord.fromJson(json['record']),
    );
  }
}
