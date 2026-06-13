import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/journal_overview.dart';
import '../models/journal_page.dart';
import 'journal_repository.dart';

/// The Journal landing payload (available / locked / recovered / record).
///
/// After a successful play:
///   ref.invalidate(journalProvider)   — recompute open + locked + archive
///   ref.invalidate(userProvider)      — coins / xp may have changed
class JournalNotifier extends AsyncNotifier<JournalOverview> {
  @override
  Future<JournalOverview> build() =>
      ref.read(journalRepositoryProvider).getOverview();
}

final journalProvider =
    AsyncNotifierProvider<JournalNotifier, JournalOverview>(
        JournalNotifier.new);

/// A single page, keyed by slug. autoDispose so it refetches each open
/// (read-only recovered pages and freshly-opened pages alike stay current).
final journalPageProvider =
    FutureProvider.family.autoDispose<JournalPage, String>((ref, slug) {
  return ref.read(journalRepositoryProvider).getPage(slug);
});
