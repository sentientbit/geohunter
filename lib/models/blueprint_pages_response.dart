import 'blueprint_page.dart';

/// Typed result of GET /api/blueprint/pages.
///
/// The server returns:
///   { "pages": [...], "manuscripts": 6 }
///
/// [manuscripts] is the player's total Blank Manuscript count.
/// Manuscripts are earned by disassembling volumes (yield per volume comes
/// from the API as [Research.manuscriptsYield] — Flutter never recomputes it).
/// They are spent by marking them for a specific blueprint via
/// PATCH /api/blueprint/mark, then visiting a Library mine to convert them
/// into real specific pages server-side.
class BlueprintPagesResponse {
  final List<BlueprintPage> pages;

  /// Total Blank Manuscripts the player currently holds.
  final int manuscripts;

  const BlueprintPagesResponse({
    required this.pages,
    required this.manuscripts,
  });

  static BlueprintPagesResponse empty() =>
      const BlueprintPagesResponse(pages: [], manuscripts: 0);
}
