import 'journal_gate.dart';

/// A page as it appears in a Journal list (not the full read view).
///
/// One class serves all three sections of `GET /api/journal`:
///   - available[] — open now: slug, title, teaser, img, is_repeatable
///   - recovered[] — archive: slug, title, img
///   - locked[]    — the trail ahead: the above + reasons[] + gates[]
///
/// Fields absent from a given section parse to sensible empties, so the same
/// card widget can render any of them.
class JournalCard {
  final String slug;
  final String title;
  final String teaser;
  final String img;
  final bool isRepeatable;

  /// Human requirement strings, one per gate (locked[] only).
  final List<String> reasons;

  /// World-action gates blocking this page (locked[] only).
  final List<JournalGate> gates;

  const JournalCard({
    required this.slug,
    required this.title,
    this.teaser = '',
    this.img = '',
    this.isRepeatable = false,
    this.reasons = const [],
    this.gates = const [],
  });

  factory JournalCard.fromJson(dynamic json) {
    final map = (json as Map?) ?? const {};
    return JournalCard(
      slug: map['slug']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      teaser: map['teaser']?.toString() ?? '',
      img: map['img']?.toString() ?? '',
      isRepeatable:
          map['is_repeatable'] == true || map['is_repeatable'] == 1,
      reasons: (map['reasons'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      gates: (map['gates'] as List?)
              ?.map((e) => JournalGate.fromJson(e))
              .toList() ??
          const [],
    );
  }
}
