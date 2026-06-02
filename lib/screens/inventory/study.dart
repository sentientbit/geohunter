///
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

///
import '../../app_localizations.dart';
import '../../models/app_error.dart';
import '../../fonts/rpg_awesome_icons.dart';
import '../../models/player_stats.dart';
import '../../models/research.dart';
import '../../models/user.dart';
import '../../shared/app_theme.dart';
import '../../shared/constants.dart';
import '../../providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/research_provider.dart';
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
  int _currentPoints = 0;
  int _neededPoints = 1;
  int _lowerPoints = 0;
  int _nrAvailBlueprints = 0;
  int _maxNr = 0;

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

    // Live volume count — drives the invest card immediately after library visit
    final int nrAvailBlueprints = liveTech.volumesOwned;
    // Live max investable = min(volumes, remaining points to next level)
    final int liveMaxNr = nrAvailBlueprints > (_neededPoints - _currentPoints)
        ? (_neededPoints - _currentPoints)
        : nrAvailBlueprints;

    // Derived values — use server-supplied crafting bonus
    final int currentLevel = liveTech.craftingLevel;
    final String skillLabel = liveTech.levelLabel;
    final String bonusLabel = widget.research.craftingBonusLabel;
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
                  '$_currentPoints / $_neededPoints', kSilver),
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
                      color: kSilverDim, fontSize: 10)),
              Text(skillLabel,
                  style: const TextStyle(
                      color: _gold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              Text('$_neededPoints pts',
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
          const Text('Invest volumes to advance your mastery.',
              style: TextStyle(color: kSilverDim, fontSize: 12,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: 16),
          // Volumes available
          Row(children: [
            const Icon(RPGAwesome.book, color: _gold, size: 16),
            const SizedBox(width: 8),
            Text(
              '$nrAvailBlueprints volume${nrAvailBlueprints == 1 ? '' : 's'} available',
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
                    'Invest Volume  ${_nrInvBlueprints.toInt()}',
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
                          ? 'No volumes available.\nVisit a Library mine.'
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
          builder: (context) => CustomDialog(
            title:
                AppLocalizations.of(context)!.translate('congrats'),
            description: AppLocalizations.of(context)!
                .translate('research_success'),
            buttonText: 'Okay',
            images: [],
            callback: () {
              Navigator.of(context).pop();
              context.pop();
            },
          ),
        );
      }
    }
  }
}
