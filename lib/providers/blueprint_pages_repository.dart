import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/blueprint_page.dart';
import '../models/disassemble_result.dart';
import 'api_provider.dart';

/// Wraps blueprint-page endpoints:
///
/// GET  /api/blueprint/pages
///   Returns all page types the player currently holds (+ manuscripts total at root).
///
/// POST /api/blueprint/assemble  { "page_id": <int> [, "use_manuscripts": true] }
///   Consumes exactly [blueprint.pagesRequired] pages (or ≥ 50% pages + manuscripts
///   in hybrid mode). The server decides the quantity — client never sends a count.
///   Error codes: INSUFFICIENT_PAGES, INSUFFICIENT_MANUSCRIPTS.
///
/// POST /api/blueprint/disassemble  { "blueprint_id": <int>, "qty": <int> }
///   Converts [qty] volumes back into manuscripts.
///   Returns manuscripts_gained, manuscripts_total, volumes_remaining.
///
/// Callers must invalidate [blueprintPagesProvider], [researchProvider],
/// and [userProvider] after a successful assemble or disassemble.
class BlueprintPagesRepository {
  final ApiProvider _api = ApiProvider();

  Future<List<BlueprintPage>> getPages() async {
    final response = await _api.get('/blueprint/pages');
    final list = (response['pages'] ?? []) as List;
    return list.map((e) => BlueprintPage.fromJson(e)).toList();
  }

  /// Assembles one volume from pages.
  /// [pageId] is [BlueprintPage.id] — the server looks up pages_required.
  /// [useManuscripts] enables hybrid mode: supplements missing pages with
  /// manuscripts, subject to the server-enforced 50% page floor.
  Future<Map<String, dynamic>> assemble(int pageId,
      {bool useManuscripts = false}) async {
    final body = <String, dynamic>{'page_id': pageId};
    if (useManuscripts) body['use_manuscripts'] = true;
    return await _api.post('/blueprint/assemble', body);
  }

  /// Disassembles [qty] volumes of [blueprintId] into manuscripts.
  /// Yield per volume: T1=2, T2=5, T3=10, T4=17 manuscripts.
  Future<DisassembleResult> disassemble(int blueprintId, int qty) async {
    final response = await _api.post('/blueprint/disassemble', {
      'blueprint_id': blueprintId,
      'qty': qty,
    });
    return DisassembleResult.fromJson(response);
  }
}

final blueprintPagesRepositoryProvider =
    Provider<BlueprintPagesRepository>((ref) => BlueprintPagesRepository());
