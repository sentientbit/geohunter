import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/blueprint_page.dart';
import '../models/blueprint_pages_response.dart';
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

  Future<BlueprintPagesResponse> getPages() async {
    final response = await _api.get('/blueprint/pages');
    final list = (response['pages'] ?? []) as List;
    final pages = list.map((e) => BlueprintPage.fromJson(e)).toList();
    final manuscripts =
        int.tryParse((response['manuscripts'] ?? 0).toString()) ?? 0;
    return BlueprintPagesResponse(pages: pages, manuscripts: manuscripts);
  }

  /// Assembles one volume from pages.
  /// Requires pages_owned >= pages_required — no hybrid path.
  Future<Map<String, dynamic>> assemble(int pageId) async {
    return await _api.post('/blueprint/assemble', {'page_id': pageId});
  }

  /// Sets the marked manuscript count for a blueprint.
  ///
  /// Marked manuscripts are reserved with intent — they become real specific
  /// pages for [blueprintId] the next time the player visits a Library mine.
  /// [quantity] replaces the current mark (not additive). Pass 0 to clear.
  ///
  /// Returns the confirmed mark count and remaining available manuscripts.
  Future<Map<String, dynamic>> mark(int blueprintId, int quantity) async {
    return await _api.patch('/blueprint/mark', {
      'blueprint_id': blueprintId,
      'quantity': quantity,
    });
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
