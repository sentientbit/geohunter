/// One normalised effect applied by playing a branch.
///
/// Discriminated by [type]:
///   trait                      → trait_kind, name, old, new
///   xp | coins                 → amount
///   item | material | blueprint → id, qty
class JournalChange {
  final String type;

  // trait
  final String slug;
  final String traitKind;
  final String name;
  final int oldValue;
  final int newValue;

  // xp / coins
  final int amount;

  // item / material / blueprint
  final int id;
  final int qty;

  const JournalChange({
    required this.type,
    this.slug = '',
    this.traitKind = '',
    this.name = '',
    this.oldValue = 0,
    this.newValue = 0,
    this.amount = 0,
    this.id = 0,
    this.qty = 0,
  });

  factory JournalChange.fromJson(dynamic json) {
    final map = (json as Map?) ?? const {};
    int i(String k) => int.tryParse(map[k]?.toString() ?? '0') ?? 0;
    return JournalChange(
      type: map['type']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
      traitKind: map['trait_kind']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      oldValue: i('old'),
      newValue: i('new'),
      amount: i('amount'),
      id: i('id'),
      qty: i('qty'),
    );
  }

  /// A short player-facing line for the post-play summary.
  String get label {
    switch (type) {
      case 'trait':
        return newValue > oldValue ? '$name +${newValue - oldValue}' : name;
      case 'xp':
        return '+$amount XP';
      case 'coins':
        return '+$amount coins';
      case 'item':
        return 'Item ×$qty';
      case 'material':
        return 'Material ×$qty';
      case 'blueprint':
        return 'Blueprint learned';
      default:
        return '';
    }
  }
}

/// Result of `POST /api/journal/play`: the outcome prose plus what changed.
class JournalPlayResult {
  final String title;

  /// Server-rendered HTML of the outcome.
  final String result;

  final List<JournalChange> changes;

  const JournalPlayResult({
    this.title = '',
    this.result = '',
    this.changes = const [],
  });

  factory JournalPlayResult.fromJson(Map<String, dynamic> json) {
    return JournalPlayResult(
      title: json['title']?.toString() ?? '',
      result: json['result']?.toString() ?? '',
      changes: (json['changes'] as List?)
              ?.map((e) => JournalChange.fromJson(e))
              .toList() ??
          const [],
    );
  }
}
