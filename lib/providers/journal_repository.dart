import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/journal_change.dart';
import '../models/journal_overview.dart';
import '../models/journal_page.dart';
import 'api_provider.dart';

/// Wraps the player-facing Keeper's Journal API (Bearer JWT, JSON).
///
///   GET  /api/journal          → landing: available / locked / recovered / record
///   GET  /api/journal/{slug}   → one page: body + branches
///   POST /api/journal/play     → play a branch: result prose + changes
///
/// This is the mobile counterpart of the web portal and is entirely separate
/// from the legacy CI3-parity /api/quests. Do not reuse Quest.fromJson here.
class JournalRepository {
  final ApiProvider _api = ApiProvider();

  Future<JournalOverview> getOverview() async {
    final response = await _api.get('/journal');
    return JournalOverview.fromJson(response);
  }

  Future<JournalPage> getPage(String slug) async {
    final response = await _api.get('/journal/$slug');
    return JournalPage.fromJson(response);
  }

  /// Plays one branch of an open page. The server re-validates visibility,
  /// branch requirements and repeatability; on a disallowed play it returns
  /// 422, which surfaces here as an AppError (no state change).
  Future<JournalPlayResult> play({
    required String storylet,
    required String branch,
  }) async {
    final response = await _api.post('/journal/play', {
      'storylet': storylet,
      'branch': branch,
    });
    return JournalPlayResult.fromJson(response);
  }
}

final journalRepositoryProvider =
    Provider<JournalRepository>((ref) => JournalRepository());
