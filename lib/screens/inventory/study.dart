///
import 'dart:math' as math;
import '../../shared/item_image.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

///
import '../../app_localizations.dart';
import '../../models/app_error.dart';
import '../../fonts/rpg_awesome_icons.dart';
import '../../models/player_stats.dart';
import '../../models/research.dart';
import '../../models/swap_record.dart';
import '../../models/swap_response.dart';
import '../../models/swap_volume.dart';
import '../../models/user.dart';
import '../../shared/app_theme.dart';
import '../../shared/constants.dart';
import '../../providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/blueprint_swap_repository.dart';
import '../../providers/research_provider.dart';
import '../../providers/swap_provider.dart';
import '../../providers/user_provider.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';

// ── Design tokens — from app_theme.dart ───────────────────────────────────────
const _gold         = kGold;        // warm gold accent
// Section label: silverDim, uppercase, generous letter-spacing
const _sectionLabel = kSectionLabel;

/// Rarity labels — index matches rarity int (0=Common … 4=Legendary).
/// Colours come from [colorRarity()] in constants.dart (single source of truth).
const _rarityLabels = ['Common', 'Uncommon', 'Rare', 'Epic', 'Legendary', 'Mythic'];

///
class StudyDetailPage extends ConsumerStatefulWidget {
  final String name = 'Study';
  final Research research;
  final List<dynamic> blueprints;

  StudyDetailPage({
    Key? key,
    required this.research,
    required this.blueprints,
  }) : super(key: key);

  @override
  _StudyDetailState createState() => _StudyDetailState();
}


///
class _StudyDetailState extends ConsumerState<StudyDetailPage> {
  double _nrInvBlueprints = 0;
  String _blueprintName = '';

  // ── Blueprint Swap card state ────────────────────────────────────────────────
  int _swapCount = 0;
  SwapVolume? _selectedVolume;

  User _user = User.blank();
  final ApiProvider _apiProvider = ApiProvider();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Thresholds come from the Research model — backend is the single source of truth.
    // nextLevelThreshold / currentLevelFloor fall back to the local formula only
    // while the API transitions (see Research.fromJson).
    _blueprintName = widget.research.blueprint.name;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _statCell(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: kSilverDim, fontSize: 10, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  Widget _vDivider() =>
      Container(height: 36, width: 1, color: kGold.withValues(alpha: 0.18));

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).valueOrNull ?? User.blank();

    // Live tech data: watch researchProvider so counts update immediately after
    // assemble / invest actions without requiring the user to navigate away.
    final liveResearch = ref
        .watch(researchProvider)
        .valueOrNull
        ?.techs
        .firstWhere((t) => t.id == widget.research.id,
            orElse: () => widget.research);
    final liveTech = liveResearch ?? widget.research;

    // Live blueprint count — drives the invest card immediately after library visit
    final int nrAvailBlueprints = liveTech.volumesOwned;

    // pagesRequired is the span for this mastery level (same formula used by swap).
    // All three elements — mastery bar, invest slider, swap circle — share it as the max.
    final int levelSpan       = liveTech.pagesRequired;          // e.g. 29
    final int investedInLevel = liveTech.nrInvested - liveTech.currentLevelFloor; // e.g. 5
    final int remaining       = (levelSpan - investedInLevel).clamp(0, levelSpan); // e.g. 24
    // Invest slider max = owned blueprints, capped by remaining to fill the level
    final int liveMaxNr = nrAvailBlueprints < remaining ? nrAvailBlueprints : remaining;

    // Derived values — use server-supplied crafting bonus
    final int currentLevel = liveTech.craftingLevel;
    final String skillLabel = liveTech.levelLabel;
    final String bonusLabel = widget.research.craftingBonusLabel;
    final double levelProgress = levelSpan > 0
        ? (investedInLevel / levelSpan).clamp(0.0, 1.0)
        : 1.0;
    final String coinCost =
        (_nrInvBlueprints * user.details.costs.research).toStringAsFixed(2);

    // ── AppBar ─────────────────────────────────────────────────────────────
    final appBar = AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text('Details', style: Style.topBar),
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ],
    );

    // ── Hero card ──────────────────────────────────────────────────────────
    final heroCard = Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: kCardDecoration(kGold),
      child: Column(
        children: [
          Row(
            children: [
              // Tech image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  image: AssetImage(widget.research.nrInvested > 0
                      ? 'assets/images/research/${widget.research.img}'
                      : 'assets/images/research/unknown.png'),
                  height: 76,
                  width: 76,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.research.name,
                      style: const TextStyle(
                        color: kGold,
                        fontSize: 22,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Color(0x66e6a04e), blurRadius: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _blueprintName.isNotEmpty
                          ? _blueprintName
                          : 'Knowledge Discipline',
                      style: const TextStyle(
                          color: kSilverDim, fontSize: 13,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statCell('MASTERY', '$currentLevel', _gold),
              _vDivider(),
              _statCell('INVESTED',
                  '$investedInLevel / $levelSpan', kSilver),
              _vDivider(),
              _statCell('BONUS', bonusLabel, const Color(0xff66bb6a)),
            ],
          ),
          const SizedBox(height: 14),
          // Level progress bar
          LinearPercentIndicator(
            lineHeight: 7.0,
            percent: levelProgress,
            backgroundColor: Colors.white12,
            progressColor: _gold,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$investedInLevel pts',
                  style: const TextStyle(
                      color: kSilverDim, fontSize: 10)),
              Text(skillLabel,
                  style: const TextStyle(
                      color: _gold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              Text('$levelSpan pts',
                  style: const TextStyle(
                      color: kSilverDim, fontSize: 10)),
            ],
          ),
        ],
      ),
    );

    // ── Invest Knowledge card ──────────────────────────────────────────────
    final investCard = Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: kCardDecoration(kGold),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.school, color: _gold, size: 14),
            const SizedBox(width: 8),
            const Text('INVEST KNOWLEDGE', style: _sectionLabel),
          ]),
          const SizedBox(height: 4),
          const Text('Invest blueprints to advance your mastery.',
              style: TextStyle(color: kSilverDim, fontSize: 12,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: 16),
          // Volumes available
          Row(children: [
            const Icon(RPGAwesome.book, color: _gold, size: 16),
            const SizedBox(width: 8),
            Text(
              '$nrAvailBlueprints blueprint${nrAvailBlueprints == 1 ? '' : 's'} available',
              style: const TextStyle(color: kSilver, fontSize: 15),
            ),
          ]),
          const SizedBox(height: 12),
          if (liveMaxNr > 0) ...[
            // Slider row with −/+ buttons
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _nrInvBlueprints > 0
                      ? () => setState(() {
                            _nrInvBlueprints =
                                (_nrInvBlueprints - 1)
                                    .clamp(0, liveMaxNr.toDouble());
                          })
                      : null,
                  icon: Icon(Icons.remove_circle_outline,
                      color: _nrInvBlueprints > 0
                          ? Colors.white
                          : Colors.white24),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _gold,
                      inactiveTrackColor: Colors.white12,
                      trackHeight: 4.0,
                      thumbColor: _gold,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10),
                      overlayColor: _gold.withAlpha(30),
                      overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 22),
                    ),
                    child: Slider(
                      min: 0,
                      max: liveMaxNr.toDouble(),
                      value: _nrInvBlueprints.clamp(0, liveMaxNr.toDouble()),
                      divisions: liveMaxNr,
                      onChanged: (v) =>
                          setState(() => _nrInvBlueprints = v),
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _nrInvBlueprints < liveMaxNr
                      ? () => setState(() {
                            _nrInvBlueprints =
                                (_nrInvBlueprints + 1)
                                    .clamp(0, liveMaxNr.toDouble());
                          })
                      : null,
                  icon: Icon(Icons.add_circle_outline,
                      color: _nrInvBlueprints < liveMaxNr
                          ? Colors.white
                          : Colors.white24),
                ),
              ],
            ),
            // Investment preview
            Center(
              child: Text(
                'New investment: ${investedInLevel + _nrInvBlueprints.toInt()} / $levelSpan',
                style: const TextStyle(
                    color: kSilverDim, fontSize: 13),
              ),
            ),
            const SizedBox(height: 10),
            // Coin cost
            Row(children: [
              const Icon(Icons.monetization_on,
                  color: _gold, size: 16),
              const SizedBox(width: 6),
              Text('$coinCost coins',
                  style: const TextStyle(
                      color: kSilver, fontSize: 13)),
            ]),
            const SizedBox(height: 14),
            // Invest button
            kStoneButton(
              onTap: _nrInvBlueprints > 0
                  ? () => _studyResearch(context, widget.research.id)
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload,
                      color: _nrInvBlueprints > 0 ? _gold : Colors.white30),
                  const SizedBox(width: 8),
                  Text(
                    'Invest  ${_nrInvBlueprints.toInt()}  Blueprint${_nrInvBlueprints.toInt() == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: _nrInvBlueprints > 0 ? _gold : Colors.white30,
                      fontSize: 16,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  widget.research.isMaxLevel
                      ? 'Mastery complete. This discipline is fully unlocked.'
                      : nrAvailBlueprints == 0
                          ? 'No blueprints available.\nVisit a Library mine.'
                          : 'Already at maximum level for current tier.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.research.isMaxLevel
                        ? _gold
                        : Colors.white38,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: appBar,
        extendBodyBehindAppBar: true,
        body: Stack(children: [
          // Background with heavy darkening — matches item detail atmosphere
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/research_study.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Color(0xcc000000), BlendMode.darken),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  heroCard,
                  kEldritchDivider(kGold),
                  investCard,
                  const SizedBox(height: 4),
                  if (widget.research.blueprint.id > 0)
                    _buildSwapCard(liveTech, nrAvailBlueprints),
                  const SizedBox(height: 4),
                  _buildDisciplineCard(widget.research),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ]),
        key: _scaffoldKey,
        drawer: DrawerPage(),
    );
  }

  // ── Discipline Effects card ───────────────────────────────────────────────────

  Widget _buildDisciplineCard(Research tech) {
    final hasRarity = tech.rarityPcts.any((p) => p > 0);
    final hasRecipes = tech.recipes.isNotEmpty;
    final hasAffinity = tech.affinityMats.isNotEmpty;

    if (!hasRarity && !hasRecipes && !hasAffinity) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: kCardDecoration(kGold),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Row(children: [
            const Icon(Icons.auto_awesome, color: _gold, size: 14),
            const SizedBox(width: 8),
            const Text('DISCIPLINE EFFECTS', style: _sectionLabel),
          ]),
          const SizedBox(height: 16),

          // ── Rarity Influence ─────────────────────────────────────────
          if (hasRarity) ...[
            const Text('RARITY INFLUENCE',
                style: TextStyle(
                    color: kSilverDim,
                    fontSize: 10,
                    letterSpacing: 1.5)),
            const SizedBox(height: 10),
            for (int i = 0; i < 5; i++)
              if (tech.rarityPcts.length > i)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text(
                          _rarityLabels[i],
                          style: TextStyle(
                              color: colorRarity(i), fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: tech.rarityPcts[i] / 100.0,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation(
                                colorRarity(i)),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${tech.rarityPcts[i]}%',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
            if (hasRecipes || hasAffinity)
              const Divider(color: Colors.white12, height: 24),
          ],

          // ── Unlocked Recipes ─────────────────────────────────────────
          if (hasRecipes) ...[
            const Text('UNLOCKED RECIPES',
                style: TextStyle(
                    color: kSilverDim,
                    fontSize: 10,
                    letterSpacing: 1.5)),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: tech.recipes.length.clamp(0, 6),
              itemBuilder: (ctx, i) {
                final recipe = tech.recipes[i];
                return Container(
                  decoration: BoxDecoration(
                    color: recipe.unlocked
                        ? const Color(0xff1e2800)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: recipe.unlocked
                          ? const Color(0xff4caf50).withValues(alpha: 0.6)
                          : Colors.white12,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (recipe.unlocked && recipe.img.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image(
                            image: itemImageProvider(recipe.img),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.help_outline,
                                color: Colors.white24,
                                size: 28),
                          ),
                        )
                      else
                        const Icon(Icons.lock_outline,
                            color: Colors.white24, size: 28),
                      if (recipe.unlocked)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Color(0xff4caf50),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                size: 10, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            if (hasAffinity)
              const Divider(color: Colors.white12, height: 24),
          ],

          // ── Material Affinities ──────────────────────────────────────
          if (hasAffinity) ...[
            const Text('MATERIAL AFFINITIES',
                style: TextStyle(
                    color: kSilverDim,
                    fontSize: 10,
                    letterSpacing: 1.5)),
            const SizedBox(height: 10),
            for (int i = 0; i < tech.affinityMats.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    if (tech.affinityMats[i].img.isNotEmpty)
                      Image.asset(
                        'assets/images/materials/${tech.affinityMats[i].img}',
                        width: 20,
                        height: 20,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox(width: 20, height: 20),
                      )
                    else
                      const SizedBox(width: 20, height: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tech.affinityMats[i].name,
                        style: const TextStyle(
                            color: kSilver, fontSize: 13),
                      ),
                    ),
                    Text(
                      i < tech.affinityPcts.length
                          ? '+${tech.affinityPcts[i]}% Yield'
                          : '',
                      style: const TextStyle(
                          color: _gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ── Blueprint Swap card ───────────────────────────────────────────────────────

  Widget _buildSwapCard(Research liveTech, int nrOwned) {
    final wantedId = widget.research.blueprint.id;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: kCardDecoration(kGold),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.swap_horiz, color: _gold, size: 14),
            const SizedBox(width: 8),
            const Text('BLUEPRINT SWAP', style: _sectionLabel),
          ]),
          const SizedBox(height: 4),
          const Text(
            'Trade surplus blueprints at a Library.',
            style: TextStyle(
                color: kSilverDim, fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          ref.watch(swapProvider(wantedId)).when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(
                    color: kGold, strokeWidth: 2),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                err is AppError ? err.message : 'Could not load swap data.',
                style: const TextStyle(
                    color: Colors.redAccent, fontSize: 13),
              ),
            ),
            data: (swapData) => _buildSwapBody(swapData, wantedId, liveTech, nrOwned),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapBody(SwapResponse swapData, int wantedId,
      Research liveTech, int nrOwned) {
    final active = swapData.activeSwap;

    // State 3 — active swap for a different discipline
    if (active != null && active.wantedBlueprintId != wantedId) {
      return _buildOtherActiveSwap(active);
    }

    // State 2 — active swap for this discipline
    if (active != null) {
      return _buildThisActiveSwap(active, wantedId);
    }

    // State 1 — no active swap
    return _buildEmptySwap(swapData, wantedId, liveTech, nrOwned);
  }

  // State 1 — empty swap form
  Widget _buildEmptySwap(SwapResponse swapData, int wantedId,
      Research liveTech, int nrOwned) {
    final int investedInLevel =
        liveTech.nrInvested - liveTech.currentLevelFloor;
    // Blueprints swap can cover = what player still needs AFTER investing everything they own
    final int maxSwap =
        (swapData.maxCount - investedInLevel - nrOwned).clamp(0, swapData.maxCount);

    // Clamp swap count if it exceeds the effective max (e.g. player just invested)
    if (_swapCount > maxSwap) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => setState(() => _swapCount = maxSwap));
    }

    // Sacrifice dropdown: filter to blueprints the player owns enough of
    final eligibleVolumes = swapData.volumes
        .where((v) => v.qty >= _swapCount && v.blueprintId != wantedId)
        .toList();

    if (_selectedVolume != null &&
        !eligibleVolumes.any((v) => v.blueprintId == _selectedVolume!.blueprintId)) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => setState(() => _selectedVolume = null));
    }

    final bool canAgree = _swapCount >= 1 && _selectedVolume != null;

    // ── Tri-arc circle ──────────────────────────────────────────────────────
    // Grey  = already invested this level
    // White = owned (can invest directly)
    // Gold  = swap count (what the player is asking the swap to provide)
    final arcWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 110,
          height: 110,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(110, 110),
                painter: _TriArcPainter(
                  invested: investedInLevel,
                  owned: nrOwned,
                  swapCount: _swapCount,
                  total: swapData.maxCount,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_swapCount',
                    style: const TextStyle(
                      color: kGold,
                      fontSize: 24,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/ $maxSwap',
                    style: const TextStyle(
                        color: kSilverDim, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // +/− buttons below the circle
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _stepperButton(
              icon: Icons.remove_circle_outline,
              enabled: _swapCount > 0,
              onTap: () {
                final next = _swapCount - 1;
                setState(() {
                  _swapCount = next;
                  if (_selectedVolume != null &&
                      _selectedVolume!.qty < next) {
                    _selectedVolume = null;
                  }
                });
              },
            ),
            const SizedBox(width: 16),
            _stepperButton(
              icon: Icons.add_circle_outline,
              enabled: _swapCount < maxSwap,
              onTap: () => setState(() => _swapCount++),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'via swap',
          style: TextStyle(
              color: kSilverDim, fontSize: 10, letterSpacing: 1.2),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            arcWidget,
            const SizedBox(width: 20),
            // Controls column — "I want" + sacrifice dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('I WANT',
                      style: TextStyle(
                          color: kSilverDim,
                          fontSize: 10,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.research.blueprint.name.isNotEmpty
                          ? widget.research.blueprint.name
                          : 'Blueprint',
                      style: const TextStyle(
                          color: kSilver, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('SACRIFICE',
                      style: TextStyle(
                          color: kSilverDim,
                          fontSize: 10,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  eligibleVolumes.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'No eligible blueprints',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 13),
                          ),
                        )
                      : _buildSacrificeDropdown(eligibleVolumes, wantedId),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        kStoneButton(
          onTap: canAgree
              ? () => _agreeSwap(context, wantedId)
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.handshake_outlined,
                  color: canAgree ? _gold : Colors.white30, size: 18),
              const SizedBox(width: 8),
              Text(
                'Agree Swap',
                style: TextStyle(
                  color: canAgree ? _gold : Colors.white30,
                  fontSize: 16,
                  fontFamily: 'Cormorant SC',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSacrificeDropdown(
      List<SwapVolume> eligible, int wantedId) {
    final current = eligible.any(
            (v) => v.blueprintId == _selectedVolume?.blueprintId)
        ? _selectedVolume
        : null;

    return DropdownButton<SwapVolume>(
      value: current,
      hint: const Text('Choose ▾',
          style: TextStyle(color: kSilverDim, fontSize: 13)),
      dropdownColor: const Color(0xff1a1a1a),
      underline: Container(height: 1, color: kGold.withValues(alpha: 0.3)),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down, color: kGold),
      items: eligible
          .map((v) => DropdownMenuItem<SwapVolume>(
                value: v,
                child: Text(
                  '${v.name}  ×${v.qty}',
                  style: const TextStyle(color: kSilver, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedVolume = v),
    );
  }

  // State 2 — active swap, this discipline
  Widget _buildThisActiveSwap(SwapRecord active, int wantedId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _swapInfoRow('Seeking',
            '${active.wantedName}  ×${active.count}', kGold),
        const SizedBox(height: 8),
        _swapInfoRow('Offered',
            '${active.blueprintName}  ×${active.count}', kSilver),
        const SizedBox(height: 12),
        const Text(
          'Visit any Library mine to collect.',
          style: TextStyle(
              color: kSilverDim, fontSize: 12, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 16),
        kStoneButton(
          onTap: () => _cancelSwap(context, wantedId),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.cancel_outlined,
                  color: Color(0xffef5350), size: 18),
              SizedBox(width: 8),
              Text(
                'Cancel Swap',
                style: TextStyle(
                  color: Color(0xffef5350),
                  fontSize: 16,
                  fontFamily: 'Cormorant SC',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // State 3 — active swap, different discipline
  Widget _buildOtherActiveSwap(SwapRecord active) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You have an active swap for\n'
          '${active.wantedName} ×${active.count}.\n'
          'Visit a Library or cancel it first.',
          style: const TextStyle(color: kSilverDim, fontSize: 13),
        ),
        const SizedBox(height: 16),
        kStoneButton(
          onTap: null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.handshake_outlined,
                  color: Colors.white30, size: 18),
              SizedBox(width: 8),
              Text(
                'Agree Swap',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 16,
                  fontFamily: 'Cormorant SC',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Swap card helpers ────────────────────────────────────────────────────────

  /// Label + value text row used in the active-swap display.
  Widget _swapInfoRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label,
              style: const TextStyle(
                  color: kSilverDim, fontSize: 12)),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 15,
                  fontFamily: 'Cormorant SC',
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  /// +/− stepper icon button.
  Widget _stepperButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, color: enabled ? Colors.white : Colors.white24),
    );
  }

  // ── Swap actions ─────────────────────────────────────────────────────────────

  Future<void> _agreeSwap(BuildContext context, int wantedId) async {
    final vol = _selectedVolume;
    if (vol == null) return;

    try {
      await ref.read(blueprintSwapRepositoryProvider).agreeSwap(
            wantedBlueprintId: wantedId,
            blueprintId: vol.blueprintId,
            count: _swapCount,
          );
      if (!mounted) return;
      ref.invalidate(swapProvider(wantedId));
      ref.invalidate(researchProvider); // volumes_owned updated
      setState(() {
        _selectedVolume = null;
        _swapCount = 0;
      });
    } on AppError catch (err) {
      if (!mounted) return;
      err.show(context);
    }
  }

  Future<void> _cancelSwap(BuildContext context, int wantedId) async {
    try {
      await ref.read(blueprintSwapRepositoryProvider).cancelSwap(wantedId);
      if (!mounted) return;
      ref.invalidate(swapProvider(wantedId));
      ref.invalidate(researchProvider);
    } on AppError catch (err) {
      if (!mounted) return;
      err.show(context);
    }
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  void _studyResearch(context, researchId) async {
    _user = await ApiProvider().getStoredUser();
    final nrBlp = _nrInvBlueprints.toInt();
    if (nrBlp <= 0) return;

    dynamic response;
    try {
      response = await _apiProvider.post('/research/$researchId/$nrBlp', {});
    } on AppError catch (err) {
      if (!mounted) return;
      err.show(context);
      return;
    } catch (err) {
      debugPrint('_studyResearch unexpected error: $err');
      return;
    }

    if (response is Map && response.containsKey('success')) {
      if (response['success'] == true) {
        _user.details.coins =
            double.tryParse(response['coins'].toString()) ?? 0.0;
        _user.details.guildId =
            response['guild']['id'].toString();
        _user.details.mining = response['mining'];
        _user.details.xp = response['xp'];
        _user.details.unread =
            ((response['unread'] ?? []) as List)
                .map((e) => (e as num).toInt())
                .toList();
        _user.details.attack = StatRange.fromList(
            (response['attack'] ?? []) as List);
        _user.details.defense = StatRange.fromList(
            (response['defense'] ?? []) as List);
        _user.details.daily = response['daily'];
        if (response.containsKey('settings')) {
          _user.details.settings = PlayerSettings.fromList(
              (response['settings'] ?? [0, 0, 0]) as List);
        }
        _user.details.costs = ActionCosts.fromList(
            (response['costs'] ?? [0.1, 0.1, 0.1]) as List);

        // Refresh all providers that depend on invest outcome:
        // - researchProvider: updates nr_invested, crafting_level
        // - userProvider: coins, XP, stats
        ref.invalidate(researchProvider);
        ref.invalidate(userProvider);

        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => CustomDialog(
            title:
                AppLocalizations.of(ctx)!.translate('congrats'),
            description: AppLocalizations.of(ctx)!
                .translate('research_success'),
            buttonText: 'Okay',
            images: [],
            callback: () {
              Navigator.of(ctx).pop();
              if (mounted) context.pop();
            },
          ),
        );
      }
    }
  }
}

// ── Tri-arc painter ───────────────────────────────────────────────────────────
//
// Three concentric arc segments on a single ring, all sharing [total] as the
// common denominator so every element on the Study Detail screen speaks the
// same language:
//
//   Grey  — blueprints already invested this mastery level
//   White — blueprints owned (can be invested directly without a swap)
//   Gold  — blueprints the swap will provide (set by the +/− stepper)
//
// The ring fills clockwise from the top.
class _TriArcPainter extends CustomPainter {
  final int invested;  // already invested this level
  final int owned;     // in player inventory
  final int swapCount; // chosen swap offer
  final int total;     // pagesRequired — the shared denominator

  const _TriArcPainter({
    required this.invested,
    required this.owned,
    required this.swapCount,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 7.0;
    final radius = size.width / 2 - strokeWidth / 2;
    const startAngle = -math.pi / 2.0;
    const fullCircle = 2 * math.pi;

    // Background ring
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (total <= 0) return;

    double cursor = startAngle;

    void arc(int count, Color color) {
      if (count <= 0) return;
      final sweep = (count / total) * fullCircle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        cursor, sweep, false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
      cursor += sweep;
    }

    arc(invested,  Colors.white38);  // grey  — already done
    arc(owned,     Colors.white70);  // white — owned, ready to invest
    arc(swapCount, kGold);           // gold  — swap territory
  }

  @override
  bool shouldRepaint(_TriArcPainter old) =>
      old.invested  != invested  ||
      old.owned     != owned     ||
      old.swapCount != swapCount ||
      old.total     != total;
}
