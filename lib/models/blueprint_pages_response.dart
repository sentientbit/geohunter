import 'blueprint_page.dart';

/// Typed result of GET /api/blueprint/pages.
///
/// The server returns:
///   { "pages": [...] }
///
/// Pages are the blueprint-specific collectibles earned at Library mines.
/// Assemble [pagesRequired] of the same type to bind a new volume.
class BlueprintPagesResponse {
  final List<BlueprintPage> pages;

  const BlueprintPagesResponse({
    required this.pages,
  });

  static BlueprintPagesResponse empty() =>
      const BlueprintPagesResponse(pages: []);
}
