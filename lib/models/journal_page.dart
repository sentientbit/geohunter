/// One branch (choice) on a Journal page.
///
/// [open] is the server's authoritative gate: render a Choose button only when
/// it is true. When false, [reasons] explains why ("Libraries you have entered
/// 1 or more"), so the player always sees what the choice wants.
class JournalBranch {
  final String key;
  final String label;
  final bool open;
  final List<String> reasons;

  const JournalBranch({
    required this.key,
    required this.label,
    this.open = false,
    this.reasons = const [],
  });

  factory JournalBranch.fromJson(dynamic json) {
    final map = (json as Map?) ?? const {};
    return JournalBranch(
      key: map['key']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      open: map['open'] == true || map['open'] == 1,
      reasons: (map['reasons'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

/// A full Journal page from `GET /api/journal/{slug}`.
///
/// [body] is server-rendered HTML. [recovered] true means the page was already
/// played and is shown read-only (the Keeper keeps it); hide the branches then.
class JournalPage {
  final String slug;
  final String title;
  final String teaser;
  final String body;
  final String img;
  final bool isRepeatable;
  final bool recovered;
  final List<JournalBranch> branches;

  const JournalPage({
    required this.slug,
    required this.title,
    this.teaser = '',
    this.body = '',
    this.img = '',
    this.isRepeatable = false,
    this.recovered = false,
    this.branches = const [],
  });

  factory JournalPage.fromJson(Map<String, dynamic> json) {
    // The API nests the page under data.page; the ApiProvider envelope unwrap
    // leaves us with { success, page: {...} }.
    final map = (json['page'] as Map?) ?? json;
    return JournalPage(
      slug: map['slug']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      teaser: map['teaser']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      img: map['img']?.toString() ?? '',
      isRepeatable:
          map['is_repeatable'] == true || map['is_repeatable'] == 1,
      recovered: map['recovered'] == true || map['recovered'] == 1,
      branches: (map['branches'] as List?)
              ?.map((e) => JournalBranch.fromJson(e))
              .toList() ??
          const [],
    );
  }
}
