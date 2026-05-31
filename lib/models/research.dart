///
import '../models/blueprint.dart';
import '../models/tech_material.dart';
import '../models/tech_recipe.dart';
import '../shared/constants.dart';

///
class Research {
  int id = 0;

  /// Display name of the research tech.
  String name = '';

  ///
  String img = '';

  /// Cumulative volumes invested so far.
  int nrInvested = 0;

  /// The blueprint (volume) consumed when studying this tech.
  Blueprint blueprint = Blueprint.blank();

  // ── New fields from GET /api/research enrichment ──────────────────────────

  /// Current crafting level derived server-side (matches researchToCrafting).
  int craftingLevel = 0;

  /// Real crafting bonus percentage (e.g. 18). Replaces the +6/12/18/25 placeholder.
  int craftingBonusPct = 0;

  /// Human-readable bonus label (e.g. '+18% Exceptional').
  String craftingBonusLabel = '—';

  /// Rarity influence percentages — 5 values: [Common, Uncommon, Rare, Epic, Legendary].
  List<int> rarityPcts = [0, 0, 0, 0, 0];

  /// How many blueprint volumes the player currently holds for this tech.
  /// Mirrors blueprint.nr; provided here for convenience.
  int volumesOwned = 0;

  /// page_id to pass to POST /api/blueprint/assemble. Null if no pages exist yet.
  int? pageId;

  /// How many blueprint pages the player holds for this tech.
  /// Comes directly from the tech node — no second endpoint needed.
  int pagesOwned = 0;

  /// Up to 6 craftable recipes unlocked by this tech. Drives the 3×2 grid.
  List<TechRecipe> recipes = [];

  /// Top-4 materials with affinity bonuses for this tech.
  List<TechMaterial> affinityMats = [];

  /// Affinity bonus percentages, zipped with [affinityMats]. Same length, always.
  List<int> affinityPcts = [];

  // ── Level threshold fields ─────────────────────────────────────────────────
  // The server is the single source of truth for the crafting formula.
  // These two values remove all formula calls from the Flutter client.
  //
  // Backend keys: next_level_threshold, current_level_floor
  // If not yet present in the API response, we fall back to the local formula
  // so old builds keep working during the transition.

  /// Absolute point total required to reach the next crafting level.
  int nextLevelThreshold = 1;

  /// Absolute point total at the start of the current crafting level (progress floor).
  int currentLevelFloor = 0;

  ///
  Research({
    required this.id,
    required this.name,
    required this.img,
    required this.blueprint,
  });

  ///
  Research.fromJson(dynamic json) {
    id = int.tryParse(json['id'].toString()) ?? 0;
    name = json['name'] as String? ?? '';
    img = json['img'] as String? ?? '';
    nrInvested = int.tryParse(json['nr_invested'].toString()) ?? 0;
    blueprint = Blueprint.fromJson(json['blueprint']);

    // Enriched fields — safe defaults so old API responses still parse cleanly
    craftingLevel =
        int.tryParse((json['crafting_level'] ?? 0).toString()) ?? 0;
    craftingBonusPct =
        int.tryParse((json['crafting_bonus_pct'] ?? 0).toString()) ?? 0;
    craftingBonusLabel =
        json['crafting_bonus_label'] as String? ?? '—';

    final rawRarity = json['rarity_pcts'];
    if (rawRarity is List && rawRarity.length == 5) {
      rarityPcts = rawRarity
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList();
    }

    volumesOwned =
        int.tryParse((json['volumes_owned'] ?? 0).toString()) ?? 0;

    final rawPageId = json['page_id'];
    pageId = rawPageId != null
        ? int.tryParse(rawPageId.toString())
        : null;

    pagesOwned =
        int.tryParse((json['pages_owned'] ?? 0).toString()) ?? 0;

    final rawRecipes = json['recipes'];
    if (rawRecipes is List) {
      recipes = rawRecipes
          .map((e) => TechRecipe.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final rawMats = json['affinity_mats'];
    if (rawMats is List) {
      affinityMats = rawMats
          .map((e) => TechMaterial.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final rawPcts = json['affinity_pcts'];
    if (rawPcts is List) {
      affinityPcts =
          rawPcts.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    }

    // Level thresholds — use server values when present (single source of truth).
    // Falls back to local formula for backward compat while backend transitions.
    final rawNext = json['next_level_threshold'];
    nextLevelThreshold = rawNext != null
        ? (int.tryParse(rawNext.toString()) ??
            craftingToResearch(craftingLevel + 1))
        : craftingToResearch(craftingLevel + 1);

    final rawFloor = json['current_level_floor'];
    currentLevelFloor = rawFloor != null
        ? (int.tryParse(rawFloor.toString()) ??
            craftingToResearch(craftingLevel))
        : craftingToResearch(craftingLevel);
  }

  ///
  static String skill(int nrPoints) {
    final craftingLevel = researchToCrafting(nrPoints);
    if (craftingLevel == 1) return 'Novice';
    if (craftingLevel == 2) return 'Amateur';
    if (craftingLevel == 3) return 'Expert';
    if (craftingLevel == 4) return 'Master';
    return 'Untrained';
  }
}
