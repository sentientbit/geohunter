///
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

///
import '../../app_localizations.dart';
import '../../models/app_error.dart';
import '../../fonts/rpg_awesome_icons.dart';
import '../../models/player_stats.dart';
import '../../models/research.dart';
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/disassemble_result.dart';
import '../../providers/blueprint_pages_repository.dart';
import '../../providers/blueprint_pages_provider.dart';
import '../../providers/research_provider.dart';
import '../../providers/user_provider.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _gold = Color(0xffe6a04e);
const _cardColor = Color(0xee1c1c1c);
const _sectionLabel = TextStyle(
  color: _gold,
  fontSize: 11,
  fontFamily: 'Open Sans',
  fontWeight: FontWeight.bold,
  letterSpacing: 2.0,
);

/// Rarity colours: Common / Uncommon / Rare / Epic / Legendary
const _rarityColors = [
  Color(0xff888888),
  Color(0xff4caf50),
  Color(0xff2196f3),
  Color(0xff9c27b0),
  Color(0xffff8c00),
];
const _rarityLabels = ['Common', 'Uncommon', 'Rare', 'Epic', 'Legendary'];

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

// ── Yield table (matches server Research.php yield brackets) ──────────────────
/// Manuscripts received when disassembling one volume of the given tier.
int _manuscriptsPerVolume(int pagesRequired) {
  if (pagesRequired <= 4) return 2;
  if (pagesRequired <= 13) return 5;
  if (pagesRequired <= 28) return 10;
  return 17; // T4 ≤ 48 pages
}

///
class _StudyDetailState extends ConsumerState<StudyDetailPage> {
  double _nrInvBlueprints = 0;
  String _blueprintName = '';
  int _currentPoints = 0;
  int _neededPoints = 1;
  int _lowerPoints = 0;
  int _nrAvailBlueprints = 0;
  int _maxNr = 0;

  /// Whether to supplement missing pages with manuscripts when assembling.
  bool _useManuscripts = false;

  /// How many volumes to disassemble (1 … volumesOwned).
  int _nrToDisassemble = 1;

  User _user = User.blank();
  final ApiProvider _apiProvider = ApiProvider();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Thresholds come from the Research model — backend is the single source of truth.
    // nextLevelThreshold / currentLevelFloor fall back to the local formula only
    // while the API transitions (see Research.fromJson).
    _currentPoints = widget.research.nrInvested;
    _neededPoints = widget.research.nextLevelThreshold;
    _lowerPoints = widget.research.currentLevelFloor;

    for (final blp in widget.blueprints) {
      if (widget.research.blueprint.id == blp.id) {
        _nrAvailBlueprints = blp.nr;
      }
    }
    _maxNr = _nrAvailBlueprints > (_neededPoints - _currentPoints)
        ? (_neededPoints - _currentPoints)
        : _nrAvailBlueprints;

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
                color: Colors.white54, fontSize: 10, letterSpacing: 1.2)),
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
      Container(height: 36, width: 1, color: Colors.white12);

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).valueOrNull ?? User.blank();
    final int manuscripts = ref.watch(manuscriptsProvider);

    // Pages data now comes directly from the tech node — no second provider needed
    final int pagesNr = widget.research.pagesOwned;
    final int pagesRequired = widget.research.blueprint.pagesRequired;
    final int? assemblePageId = widget.research.pageId;

    // Full assembly: all pages in hand.
    final bool canAssembleFull =
        pagesRequired > 0 && pagesNr >= pagesRequired && assemblePageId != null;
    // Hybrid: player flipped the toggle AND has manuscripts AND meets 50% page floor.
    final bool canAssembleHybrid = _useManuscripts &&
        pagesRequired > 0 &&
        assemblePageId != null &&
        manuscripts > 0 &&
        (pagesNr * 2 >= pagesRequired); // ≥ 50% pages
    final bool canAssemble = canAssembleFull || canAssembleHybrid;

    // Derived values — use server-supplied crafting bonus
    final int currentLevel = researchToCrafting(_currentPoints);
    final String skillLabel = Research.skill(_currentPoints);
    final String bonusLabel = widget.research.craftingBonusLabel;
    final double pageRatio = pagesRequired > 0
        ? (pagesNr / pagesRequired).clamp(0.0, 1.0)
        : 0.0;
    final double levelProgress =
        (_neededPoints > _lowerPoints)
            ? ((_currentPoints - _lowerPoints) /
                    (_neededPoints - _lowerPoints))
                .clamp(0.0, 1.0)
            : 1.0;
    final String coinCost =
        (_nrInvBlueprints * user.details.costs.research).toStringAsFixed(2);

    // ── AppBar ─────────────────────────────────────────────────────────────
    final appBar = AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(widget.research.name, style: Style.topBar),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ],
    );

    // ── Hero card ──────────────────────────────────────────────────────────
    final heroCard = Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
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
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _blueprintName.isNotEmpty
                          ? _blueprintName
                          : 'Knowledge Discipline',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13),
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
                  '$_currentPoints / $_neededPoints', Colors.white),
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
              Text('$_currentPoints pts',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 10)),
              Text(skillLabel,
                  style: const TextStyle(
                      color: _gold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              Text('$_neededPoints pts',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );

    // ── Volume Assembly card ───────────────────────────────────────────────
    Widget? assemblyCard;
    if (pagesRequired > 0) {
      // Hybrid mode: available when player has manuscripts and ≥ 50% pages.
      final bool hybridAvailable =
          manuscripts > 0 && (pagesNr * 2 >= pagesRequired);

      assemblyCard = Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading + manuscripts count
            Row(children: [
              const Icon(Icons.auto_stories, color: _gold, size: 14),
              const SizedBox(width: 8),
              const Expanded(
                  child: Text('VOLUME ASSEMBLY', style: _sectionLabel)),
              if (manuscripts > 0) ...[
                const Icon(Icons.history_edu, color: _gold, size: 14),
                const SizedBox(width: 4),
                Text('$manuscripts',
                    style: const TextStyle(
                        color: _gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ]),
            const SizedBox(height: 4),
            const Text('Collect pages to bind a new volume.',
                style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 20),
            // Ring + next reward
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circular page progress
                Expanded(
                  child: Column(
                    children: [
                      CircularPercentIndicator(
                        radius: 66.0,
                        lineWidth: 7.0,
                        animation: true,
                        animateFromLastPercent: true,
                        percent: pageRatio,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$pagesNr',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontFamily: 'Cormorant SC',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '/ $pagesRequired',
                              style: const TextStyle(
                                  color: _gold, fontSize: 13),
                            ),
                          ],
                        ),
                        progressColor: _gold,
                        backgroundColor: Colors.white10,
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                      const SizedBox(height: 8),
                      const Text('Pages Collected',
                          style: TextStyle(
                              color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Next reward panel
                Expanded(
                  child: Column(
                    children: [
                      const Text('NEXT REWARD',
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                              letterSpacing: 1.5)),
                      const SizedBox(height: 10),
                      const Icon(RPGAwesome.book, color: _gold, size: 36),
                      const SizedBox(height: 6),
                      const Text('+1 Volume',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Cormorant SC',
                              fontWeight: FontWeight.bold)),
                      if (_blueprintName.isNotEmpty)
                        Text(_blueprintName,
                            style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11),
                            textAlign: TextAlign.center),
                      const SizedBox(height: 14),
                      // Use manuscripts toggle — only shown when viable
                      if (hybridAvailable && !canAssembleFull)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.history_edu,
                                  color: Colors.white54, size: 14),
                              const SizedBox(width: 6),
                              const Text('Use manuscripts',
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12)),
                              const SizedBox(width: 6),
                              Switch.adaptive(
                                value: _useManuscripts,
                                onChanged: (v) =>
                                    setState(() => _useManuscripts = v),
                                activeColor: _gold,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: canAssemble
                                ? const Color(0xff3a2800)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            side: BorderSide(
                                color: canAssemble
                                    ? _gold
                                    : Colors.white24),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: canAssemble
                              ? () => _assemble(assemblePageId)
                              : null,
                          child: Column(
                            children: [
                              Text(
                                'Bind Volume',
                                style: TextStyle(
                                  color: canAssemble
                                      ? _gold
                                      : Colors.white30,
                                  fontSize: 14,
                                  fontFamily: 'Cormorant SC',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _useManuscripts
                                    ? 'Pages + manuscripts'
                                    : 'Requires $pagesRequired pages',
                                style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // ── Invest Knowledge card ──────────────────────────────────────────────
    final investCard = Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.school, color: _gold, size: 14),
            const SizedBox(width: 8),
            const Text('INVEST KNOWLEDGE', style: _sectionLabel),
          ]),
          const SizedBox(height: 4),
          const Text('Invest volumes to advance your mastery.',
              style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 16),
          // Volumes available
          Row(children: [
            const Icon(RPGAwesome.book, color: _gold, size: 16),
            const SizedBox(width: 8),
            Text(
              '$_nrAvailBlueprints volume${_nrAvailBlueprints == 1 ? '' : 's'} available',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ]),
          const SizedBox(height: 12),
          if (_maxNr > 0) ...[
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
                                    .clamp(0, _maxNr.toDouble());
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
                      max: _maxNr.toDouble(),
                      value: _nrInvBlueprints,
                      divisions: _maxNr,
                      onChanged: (v) =>
                          setState(() => _nrInvBlueprints = v),
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _nrInvBlueprints < _maxNr
                      ? () => setState(() {
                            _nrInvBlueprints =
                                (_nrInvBlueprints + 1)
                                    .clamp(0, _maxNr.toDouble());
                          })
                      : null,
                  icon: Icon(Icons.add_circle_outline,
                      color: _nrInvBlueprints < _maxNr
                          ? Colors.white
                          : Colors.white24),
                ),
              ],
            ),
            // Investment preview
            Center(
              child: Text(
                'New investment: ${_currentPoints + _nrInvBlueprints.toInt()} / $_neededPoints',
                style: const TextStyle(
                    color: Colors.white54, fontSize: 13),
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
                      color: Colors.white60, fontSize: 13)),
            ]),
            const SizedBox(height: 14),
            // Invest button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: _nrInvBlueprints > 0
                      ? const Color(0xff3a2800)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(
                      color: _nrInvBlueprints > 0
                          ? _gold
                          : Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _nrInvBlueprints > 0
                    ? () =>
                        _studyResearch(context, widget.research.id)
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload,
                        color: _nrInvBlueprints > 0
                            ? _gold
                            : Colors.white30),
                    const SizedBox(width: 8),
                    Text(
                      'Invest Volume  ${_nrInvBlueprints.toInt()}',
                      style: TextStyle(
                        color: _nrInvBlueprints > 0
                            ? _gold
                            : Colors.white30,
                        fontSize: 16,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  widget.research.isMaxLevel
                      ? 'Mastery complete. This discipline is fully unlocked.'
                      : _nrAvailBlueprints == 0
                          ? 'No volumes available.\nAssemble pages first.'
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
        backgroundColor: const Color(0xff121212),
        appBar: appBar,
        extendBodyBehindAppBar: true,
        body: Stack(children: [
          // Background with darkening overlay
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    const AssetImage('assets/images/research_study.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.65), BlendMode.darken),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  heroCard,
                  if (assemblyCard != null) assemblyCard,
                  investCard,
                  _buildDisassembleCard(
                      widget.research, manuscripts),
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
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
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
                    color: Colors.white38,
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
                              color: _rarityColors[i], fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: tech.rarityPcts[i] / 100.0,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation(
                                _rarityColors[i]),
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
                    color: Colors.white38,
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
                          child: Image.asset(
                            'assets/images/items/${recipe.img}',
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
                    color: Colors.white38,
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
                            color: Colors.white70, fontSize: 13),
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

  // ── Disassemble card ─────────────────────────────────────────────────────────

  Widget _buildDisassembleCard(Research tech, int manuscripts) {
    final int volumesOwned = tech.volumesOwned;
    final int pagesRequired = tech.blueprint.pagesRequired;
    if (volumesOwned <= 0 || pagesRequired == 0) return const SizedBox.shrink();

    final int yieldPerVolume = _manuscriptsPerVolume(pagesRequired);
    final int previewGain = _nrToDisassemble * yieldPerVolume;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.history_edu, color: _gold, size: 14),
            const SizedBox(width: 8),
            const Text('DISASSEMBLE VOLUMES', style: _sectionLabel),
          ]),
          const SizedBox(height: 4),
          Text(
            'Break down volumes into manuscripts. '
            'Each volume yields $yieldPerVolume manuscripts.',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 16),
          // Volumes owned + yield preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statCell('VOLUMES', '$volumesOwned', Colors.white),
              _vDivider(),
              _statCell('WILL GAIN',
                  '$previewGain manuscripts', const Color(0xff66bb6a)),
              _vDivider(),
              _statCell('MANUSCRIPTS', '$manuscripts', _gold),
            ],
          ),
          const SizedBox(height: 16),
          // Quantity slider (only if >1 volume)
          if (volumesOwned > 1) ...[
            Row(children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _nrToDisassemble > 1
                    ? () => setState(() => _nrToDisassemble--)
                    : null,
                icon: Icon(Icons.remove_circle_outline,
                    color: _nrToDisassemble > 1
                        ? Colors.white
                        : Colors.white24),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.redAccent,
                    inactiveTrackColor: Colors.white12,
                    trackHeight: 4.0,
                    thumbColor: Colors.redAccent,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 10),
                    overlayColor: Colors.red.withAlpha(30),
                  ),
                  child: Slider(
                    min: 1,
                    max: volumesOwned.toDouble(),
                    value: _nrToDisassemble.toDouble(),
                    divisions: volumesOwned > 1 ? volumesOwned - 1 : 1,
                    onChanged: (v) =>
                        setState(() => _nrToDisassemble = v.toInt()),
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _nrToDisassemble < volumesOwned
                    ? () => setState(() => _nrToDisassemble++)
                    : null,
                icon: Icon(Icons.add_circle_outline,
                    color: _nrToDisassemble < volumesOwned
                        ? Colors.white
                        : Colors.white24),
              ),
            ]),
            Center(
              child: Text(
                'Disassemble $_nrToDisassemble volume${_nrToDisassemble == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xff280000),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                side: const BorderSide(color: Colors.redAccent, width: 0.8),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _disassemble(
                  tech.blueprint.id, _nrToDisassemble),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_delete_outlined,
                      color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Disassemble  $_nrToDisassemble',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 15,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _assemble(int? pageId) async {
    if (pageId == null) return;
    try {
      await ref
          .read(blueprintPagesRepositoryProvider)
          .assemble(pageId, useManuscripts: _useManuscripts);
      ref.invalidate(blueprintPagesProvider);
      ref.invalidate(researchProvider);
      ref.invalidate(userProvider);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => CustomDialog(
          title: AppLocalizations.of(context)!.translate('congrats'),
          description: 'Blueprint volume assembled!',
          buttonText: 'Okay',
          images: [],
          callback: () {},
        ),
      );
    } on AppError catch (err) {
      if (!mounted) return;
      err.show(context);
    } catch (err) {
      debugPrint('_assemble unexpected error: $err');
    }
  }

  Future<void> _disassemble(int blueprintId, int qty) async {
    DisassembleResult result;
    try {
      result = await ref
          .read(blueprintPagesRepositoryProvider)
          .disassemble(blueprintId, qty);
    } on AppError catch (err) {
      if (!mounted) return;
      err.show(context);
      return;
    } catch (err) {
      debugPrint('_disassemble unexpected error: $err');
      return;
    }

    ref.invalidate(researchProvider);
    ref.invalidate(userProvider);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(
        title: AppLocalizations.of(context)!.translate('congrats'),
        description:
            '+${result.manuscriptsGained} manuscripts gained!\n'
            'Total: ${result.manuscriptsTotal} manuscripts.',
        buttonText: 'Okay',
        images: [],
        callback: () {
          Navigator.of(ctx).pop();
          context.go('/research');
        },
      ),
    );
  }

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

        ref.invalidate(userProvider);

        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title:
                AppLocalizations.of(context)!.translate('congrats'),
            description: AppLocalizations.of(context)!
                .translate('research_success'),
            buttonText: 'Okay',
            images: [],
            callback: () {
              Navigator.of(context).pop();
              context.go('/research');
            },
          ),
        );
      }
    }
  }
}
