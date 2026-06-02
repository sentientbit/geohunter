import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/blueprint_page.dart';
import '../models/blueprint_pages_response.dart';
import 'api_provider.dart';

/// Wraps blueprint-page endpoints:
///
/// GET  /api/blueprint/pages
///   Returns all page types the player currently holds.
///
/// POST /api/blueprint/assemble  { "page_id": <int> }
///   Consumes exactly [blueprint.pagesRequired] pages.
///   The server decides the quantity — client never sends a count.
///   Error codes: INSUFFICIENT_PAGES.
///
/// Callers must invalidate [blueprintPagesProvider], [researchProvider],
/// and [userProvider] after a successful assemble.
class BlueprintPagesRepository {
  final ApiProvider _api = ApiProvider();

  Future<BlueprintPagesResponse> getPages() async {
    final response = await _api.get('/blueprint/pages');
    final list = (response['pages'] ?? []) as List;
    final pages = list.map((e) => BlueprintPage.fromJson(e)).toList();
    return BlueprintPagesResponse(pages: pages);
  }

  /// Assembles one volume from pages.
  /// Requires pages_owned >= pages_required.
  Future<Map<String, dynamic>> assemble(int pageId) async {
    return await _api.post('/blueprint/assemble', {'page_id': pageId});
  }
}

final blueprintPagesRepositoryProvider =
    Provider<BlueprintPagesRepository>((ref) => BlueprintPagesRepository());
