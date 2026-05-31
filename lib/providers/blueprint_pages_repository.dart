import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/blueprint_page.dart';
import 'api_provider.dart';

/// Wraps two endpoints for the blueprint pages system:
///
/// GET  /api/blueprint/pages
///   Returns all page types the player currently holds with their quantities.
///   Cross-reference by [BlueprintPage.blueprintId] to match the volume
///   (blueprint) shown in StudyDetailPage.
///
/// POST /api/blueprint/assemble  { "page_id": <int> }
///   Consumes exactly [blueprint.pagesRequired] pages of the given type.
///   The server decides the quantity — the client never sends a count.
///   Response: full dashboard block (coins, xp, guild, …) plus
///             "blueprint" (updated volume nr), "page" (updated page nr),
///             "pages_used" (int).
///   Callers must invalidate [blueprintPagesProvider], [researchProvider],
///   and [userProvider] after a successful call.
class BlueprintPagesRepository {
  final ApiProvider _api = ApiProvider();

  Future<List<BlueprintPage>> getPages() async {
    final response = await _api.get('/blueprint/pages');
    final list = (response['pages'] ?? []) as List;
    return list.map((e) => BlueprintPage.fromJson(e)).toList();
  }

  /// Assembles one volume from pages.
  /// [pageId] is [BlueprintPage.id] — the server looks up pages_required.
  Future<Map<String, dynamic>> assemble(int pageId) async {
    return await _api.post('/blueprint/assemble', {'page_id': pageId});
  }
}

final blueprintPagesRepositoryProvider =
    Provider<BlueprintPagesRepository>((ref) => BlueprintPagesRepository());
