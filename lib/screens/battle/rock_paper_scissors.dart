import 'dart:async';
import 'dart:math' as math;

import '../../shared/sfx.dart';
import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:geohunter/models/visitevent.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../fonts/rpg_awesome_icons.dart';
import '../../models/app_error.dart';
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../shared/app_theme.dart';
import '../../shared/equipment_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../providers/visit_provider.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

class RockPaperScissorsPage extends ConsumerStatefulWidget {
  final String name = 'battle';
  final int rndMap;
  final int mineId;

  RockPaperScissorsPage({
    Key? key,
    required this.rndMap,
    required this.mineId,
  }) : super(key: key);

  @override
  _RockPaperScissorsState createState() => _RockPaperScissorsState();
}

class _RockPaperScissorsState extends ConsumerState<RockPaperScissorsPage> {
  math.Random rndBattleNumber = math.Random.secure();

  final ApiProvider _apiProvider = ApiProvider();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  User _user = User.blank();

  // ── Game state ──────────────────────────────────────────────────────────────
  double playerHealth = 100.0;
  double enemyHealth  = 100.0;

  String playerString = '';
  String enemyString  = '';
  String resultString = '';

  int currentLevel          = 0;
  int nextExperienceLevel   = 1;
  int currentExperience     = 0;

  double myAtk = 0.0;
  double myDef = 0.0;

  String monsterName = 'Giant Rat';
  bool   isWinner    = false;
  bool   isLooser    = false;
  bool   tap         = false;

  List<String> consoleStrings = [];
  ScrollController _scrollController = ScrollController();

  // ── UI state (new) ──────────────────────────────────────────────────────────
  int _round          = 0;
  static const int _maxRounds = 10;

  /// Which button the player last pressed (for highlight + description).
  int _selectedAction = 1; // default: Defend shown in description

  int    _lastPlayerAction  = -1;
  int    _lastEnemyAction   = -1;
  double _lastDmgToEnemy    = 0;
  double _lastDmgToPlayer   = 0;
  String _playerResultLabel = '';
  String _enemyResultLabel  = '';

  // ── Static data ─────────────────────────────────────────────────────────────
  static const _actionLabels = ['Attack', 'Defend', 'Grab'];
  static const _actionIcons  = [
    RPGAwesome.broadsword,
    RPGAwesome.shield,
    RPGAwesome.hand,
  ];
  static const _actionColors = [
    Color(0xffe05c5c), // red   — Attack
    Color(0xff5ba0d0), // blue  — Defend
    Color(0xffe6a04e), // gold  — Grab
  ];
  static const _actionCounters = [
    'Strong vs Grab',
    'Strong vs Attack',
    'Strong vs Defend',
  ];
  static const _actionDescriptions = [
    'Strike with full force.\nBreaks through a Grab attempt.',
    'Raise your guard.\nReduces damage from Attack.',
    'Seize the moment.\nOverpowers a Defend stance.',
  ];

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Game logic (preserved exactly) ─────────────────────────────────────────

  String dp(double val, int places) {
    var mod = double.tryParse(math.pow(10.0, places).toString()) ?? 0.0;
    return ((val * mod).round().toDouble() / mod).toString();
  }

  /// 1 = win, 0 = draw, -1 = loss
  int hitOrMiss(int playerAction, int enemyAction) {
    if (playerAction == 0) {
      if (enemyAction == 1) return -1;
      if (enemyAction == 2) return 1;
      return 0;
    } else if (playerAction == 1) {
      if (enemyAction == 0) return 1;
      if (enemyAction == 2) return -1;
      return 0;
    } else {
      if (enemyAction == 0) return -1;
      if (enemyAction == 1) return 1;
      return 0;
    }
  }

  void loadUser() async {
    final tmp = await _apiProvider.getStoredUser();
    _getUserDetails();
    _user = tmp;
    setState(() {
      _user = tmp;
      _user.details.coins   = tmp.details.coins;
      _user.details.xp      = tmp.details.xp;
      _user.details.unread  = tmp.details.unread;
      _user.details.attack  = tmp.details.attack;
      _user.details.defense = tmp.details.defense;
      _user.details.daily   = tmp.details.daily;
    });
  }

  void actionGo(int playerAction) {
    if (isWinner || isLooser) return;

    setState(() { tap = true; });

    final enemyAction = rndBattleNumber.nextInt(300).remainder(3);
    final result      = hitOrMiss(playerAction, enemyAction);

    if (result == 1)       Sfx.play('sfx/sword_1.mp3');
    else if (result == -1) Sfx.play('sfx/bookOpen_1.mp3');
    else                   Sfx.play('sfx/cloth_3.mp3');

    if (_user.details.attack.max > 0) {
      myAtk = rndBattleNumber.nextDouble() *
              (_user.details.attack.max - _user.details.attack.min) +
          _user.details.attack.min;
    }
    if (_user.details.defense.max > 0) {
      myDef = rndBattleNumber.nextDouble() *
              (_user.details.defense.max - _user.details.defense.min) +
          _user.details.defense.min;
    }

    final theirDef = rndBattleNumber.nextDouble() * 5 + 5.0;
    final theirAtk = rndBattleNumber.nextDouble() * 5 + 5.0;

    setState(() {
      _round             = (_round + 1).clamp(0, _maxRounds);
      _selectedAction    = playerAction;
      _lastPlayerAction  = playerAction;
      _lastEnemyAction   = enemyAction;
      playerString       = _actionLabels[playerAction];
      enemyString        = _actionLabels[enemyAction];

      if (result == 1) {
        resultString       = 'Hit';
        _playerResultLabel = 'Strong!';
        _enemyResultLabel  = 'Blocked';
        _lastDmgToEnemy    = damageHealth(myAtk, theirDef);
        _lastDmgToPlayer   = 0;
        enemyHealth        = enemyHealth - _lastDmgToEnemy;
        if (enemyHealth <= 0) isWinner = true;
        consoleStrings.add('${_user.details.username}: $playerString vs $monsterName: $enemyString');
        consoleStrings.add('${_user.details.username}: Hit for ${dp(myAtk, 2)} against ${dp(theirDef, 2)} armor');
      } else if (result == -1) {
        resultString       = 'Miss';
        _playerResultLabel = 'Blocked';
        _enemyResultLabel  = 'Strong!';
        _lastDmgToPlayer   = damageHealth(theirAtk, myDef);
        _lastDmgToEnemy    = 0;
        playerHealth       = playerHealth - _lastDmgToPlayer;
        if (playerHealth <= 0) isLooser = true;
        consoleStrings.add('${_user.details.username}: $playerString vs $monsterName: $enemyString');
        consoleStrings.add(enemyAction == 1
            ? '$monsterName: Bash for ${dp(theirAtk, 2)} against ${dp(myDef, 2)} armor'
            : '$monsterName: Hit for ${dp(theirAtk, 2)} against ${dp(myDef, 2)} armor');
      } else {
        resultString       = 'Draw';
        _playerResultLabel = 'Draw';
        _enemyResultLabel  = 'Draw';
        _lastDmgToEnemy    = 0;
        _lastDmgToPlayer   = 0;
        consoleStrings.add('${_user.details.username}: $playerString vs $monsterName: $enemyString');
        consoleStrings.add('Draw');
      }

      // Time-out: if max rounds reached and no one is dead,
      // whoever has more HP wins.
      if (!isWinner && !isLooser && _round >= _maxRounds) {
        if (playerHealth > enemyHealth) {
          isWinner = true;
        } else {
          isLooser = true;
        }
      }
    });

    Timer(Duration(milliseconds: 200), () {
      setState(() { tap = false; });
      Sfx.play('sfx/rat_${(rndBattleNumber.nextInt(3) + 1)}.mp3');
    });
  }

  // ── Widget helpers ──────────────────────────────────────────────────────────

  // barWidth must be supplied by the caller (from LayoutBuilder).
  Widget _healthBar(double current, double max, bool alignRight, double barWidth) {
    double pct = (current / max).clamp(0.0, 1.0);
    final int cur = current.round().clamp(0, max.round());
    final color = pct > 0.5
        ? const Color(0xffcc2200)
        : pct > 0.25
            ? Colors.orange
            : Colors.red;

    final bar = Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        LinearPercentIndicator(
          width: barWidth,
          lineHeight: 10,
          percent: pct,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white12,
          progressColor: color,
          barRadius: const Radius.circular(5),
        ),
        const SizedBox(height: 2),
        Text(
          '$cur / ${max.round()}',
          style: const TextStyle(
            color: kSilverDim,
            fontSize: 11,
            fontFamily: 'Open Sans',
          ),
        ),
      ],
    );
    return bar;
  }

  Widget _combatantsRow() {
    final playerName =
        _user.details.username.isNotEmpty ? _user.details.username : 'You';
    const nameStyle = TextStyle(
      color: kSilver,
      fontSize: 12,
      fontFamily: 'Open Sans',
      fontWeight: FontWeight.bold,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: LayoutBuilder(builder: (context, constraints) {
        // Two bars share available width minus a small gap.
        final barW = (constraints.maxWidth - 8) / 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Names row
            Row(
              children: [
                Icon(RPGAwesome.shield, color: kGold, size: 13),
                const SizedBox(width: 4),
                Expanded(child: Text(playerName, style: nameStyle, overflow: TextOverflow.ellipsis)),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(monsterName, style: nameStyle, overflow: TextOverflow.ellipsis),
                      const SizedBox(width: 4),
                      const Text('🐾', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Bars row
            Row(
              children: [
                _healthBar(playerHealth, 100, false, barW),
                const SizedBox(width: 8),
                _healthBar(enemyHealth, 100, true, barW),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _arenaSection() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage('assets/images/fight_${widget.rndMap}.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.25),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Player action result — left: damage player dealt to enemy.
          if (_lastPlayerAction >= 0)
            Positioned(
              left: 16,
              top: 20,
              child: _damageOverlay(
                _actionLabels[_lastPlayerAction],
                _playerResultLabel,
                _lastDmgToEnemy,  // >0 on hit, 0 on miss/draw
                _actionColors[_lastPlayerAction],
                false, // shown in white/gold (player dealt it)
              ),
            ),

          // Enemy action result — right: damage enemy dealt to player.
          if (_lastEnemyAction >= 0)
            Positioned(
              right: 16,
              top: 20,
              child: _damageOverlay(
                _actionLabels[_lastEnemyAction],
                _enemyResultLabel,
                _lastDmgToPlayer,  // >0 on miss, 0 on hit/draw
                _actionColors[_lastEnemyAction],
                true, // shown in red (player takes it)
              ),
            ),

          // Enemy / monster image — center
          Center(
            child: isWinner
                ? const SizedBox.shrink()
                : Image.asset(
                    'assets/images/enemies/rat.png',
                    height: 160,
                    color: tap ? const Color(0x80FFFFFF) : null,
                  ),
          ),

          // Shield icon bottom-center
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Icon(RPGAwesome.shield,
                  color: kGold.withValues(alpha: 0.6), size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _damageOverlay(
    String action,
    String label,
    double dmg,
    Color color,
    bool negative,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(action,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            )),
        Text(label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            )),
        if (dmg > 0)
          Text(
            '${negative ? '-' : '-'}${dmg.toStringAsFixed(2)}',
            style: TextStyle(
              color: negative ? const Color(0xffff4444) : Colors.white,
              fontSize: 26,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 6),
              ],
            ),
          ),
      ],
    );
  }

  Widget _moveButton(int action) {
    final bool selected = _selectedAction == action;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedAction = action);
        actionGo(action);
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff1a1208),
              border: Border.all(
                color: selected
                    ? kGold
                    : Colors.white.withValues(alpha: 0.15),
                width: selected ? 2.5 : 1.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: kGold.withValues(alpha: 0.35),
                        blurRadius: 18,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Icon(
                _actionIcons[action],
                color: selected
                    ? _actionColors[action]
                    : _actionColors[action].withValues(alpha: 0.6),
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _actionLabels[action],
            style: TextStyle(
              color: selected ? _actionColors[action] : kSilver,
              fontSize: 14,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            _actionCounters[action],
            style: const TextStyle(
              color: kSilverDim,
              fontSize: 10,
              fontFamily: 'Open Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _chooseYourMove() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: kCardDecoration(kGold, radius: 12, glowAlpha: 0.06),
      child: Column(
        children: [
          _sectionLabel('CHOOSE YOUR MOVE'),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _moveButton(0),
              _moveButton(1),
              _moveButton(2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moveDescriptionCard() {
    if (_selectedAction < 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: kCardDecoration(
        _actionColors[_selectedAction],
        radius: 12,
        glowAlpha: 0.08,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _actionLabels[_selectedAction],
                  style: TextStyle(
                    color: _actionColors[_selectedAction],
                    fontSize: 20,
                    fontFamily: 'Cormorant SC',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _actionDescriptions[_selectedAction],
                  style: const TextStyle(
                    color: kSilverDim,
                    fontSize: 13,
                    fontFamily: 'Open Sans',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(_actionIcons[_selectedAction],
              color: _actionColors[_selectedAction].withValues(alpha: 0.7),
              size: 40),
        ],
      ),
    );
  }

  Widget _turnResultCard() {
    if (_lastPlayerAction < 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: kCardDecoration(kSilverDim, radius: 12, glowAlpha: 0.04),
      child: Column(
        children: [
          _sectionLabel('TURN RESULT'),
          const SizedBox(height: 12),
          Row(
            children: [
              // Player icon circle
              _resultCircle(
                _actionIcons[_lastPlayerAction],
                _actionColors[_lastPlayerAction],
                filled: true,
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: kSilverDim, size: 18),
              const SizedBox(width: 8),
              // Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'You ${_actionLabels[_lastPlayerAction]}',
                      style: const TextStyle(
                        color: kSilver,
                        fontSize: 16,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$monsterName ${_actionLabels[_lastEnemyAction]}s',
                      style: const TextStyle(
                        color: kSilverDim,
                        fontSize: 13,
                        fontFamily: 'Cormorant SC',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: kSilverDim, size: 18),
              const SizedBox(width: 8),
              // Enemy icon circle
              _resultCircle(
                _actionIcons[_lastEnemyAction],
                _actionColors[_lastEnemyAction],
                filled: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultCircle(IconData icon, Color color, {required bool filled}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled
            ? color.withValues(alpha: 0.18)
            : Colors.transparent,
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Center(child: Icon(icon, color: color, size: 22)),
    );
  }

  Widget _roundProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Text(
            'ROUND $_round OF $_maxRounds',
            style: kSectionLabel,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: List.generate(_maxRounds, (i) {
                final done   = i < _round;
                final active = i == _round - 1;
                return Expanded(
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: active
                          ? kGold
                          : done
                              ? kGold.withValues(alpha: 0.4)
                              : Colors.white12,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _endScreen() {
    final won = isWinner && !isLooser;
    final color = won ? kGold : Colors.red.shade400;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: kStoneButton(
        onTap: () {
          ref.read(visitEventProvider.notifier).update(
            VisitEvent(won ? 1 : -1, '3', widget.mineId),
          );
          context.pop();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(won ? RPGAwesome.horn_call : RPGAwesome.skull, color: color),
            const SizedBox(width: 8),
            Text(
              won ? 'Victory' : 'Defeat',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(children: [
      Expanded(
          child: Divider(
              color: kGold.withValues(alpha: 0.3), thickness: 0.6)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(text, style: kSectionLabel),
      ),
      Expanded(
          child: Divider(
              color: kGold.withValues(alpha: 0.3), thickness: 0.6)),
    ]);
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topBar = AppBar(
      leading: IconButton(
        color: GlobalConstants.appFg,
        icon: const Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(AppLocalizations.of(context)!.translate('drawer_battle'),
          style: Style.topBar),
      actions: [
        // Coin chip
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: kGold.withValues(alpha: 0.5), width: 0.8),
          ),
          child: Row(children: [
            const Icon(Icons.monetization_on, color: kGold, size: 14),
            const SizedBox(width: 4),
            Text(
              _user.details.coins.toStringAsFixed(2),
              style: const TextStyle(
                color: kGold,
                fontSize: 13,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ]),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: GlobalConstants.appBg,
      resizeToAvoidBottomInset: false,
      appBar: topBar,
      body: Stack(
        children: [
          // Background (subtle, darkened)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/fight_${widget.rndMap}.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.82),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Round ──────────────────────────────────────────────
                  if (_round > 0) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _sectionLabel('ROUND $_round'),
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                  ],

                  // ── Health bars ────────────────────────────────────────
                  _combatantsRow(),

                  // ── Arena ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _arenaSection(),
                  ),
                  const SizedBox(height: 12),

                  // ── Move picker ────────────────────────────────────────
                  if (!isWinner && !isLooser)
                    _chooseYourMove()
                  else
                    _endScreen(),
                  const SizedBox(height: 10),

                  // ── Move description ───────────────────────────────────
                  if (!isWinner && !isLooser) ...[
                    _moveDescriptionCard(),
                    const SizedBox(height: 10),
                  ],

                  // ── Turn result ────────────────────────────────────────
                  if (_lastPlayerAction >= 0) ...[
                    _turnResultCard(),
                    const SizedBox(height: 10),
                  ],

                  // ── Round progress ─────────────────────────────────────
                  if (_round > 0) _roundProgress(),

                  SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }

  // ── Data methods (unchanged) ─────────────────────────────────────────────────

  void _getUserDetails() async {
    _user = await ApiProvider().getStoredUser();

    dynamic response;
    try {
      response = await _apiProvider.get('/equipment');
    } on AppError catch (err) {
      err.show(context);
      return;
    } catch (err) {
      debugPrint('_getUserDetails unexpected error: $err');
      return;
    }

    applyEquipmentResponse(_user, response as Map<String, dynamic>);

    if (_user.details.attack.max > 0) {
      myAtk = rndBattleNumber.nextDouble() *
              (_user.details.attack.max - _user.details.attack.min) +
          _user.details.attack.min;
    }
    if (_user.details.defense.max > 0) {
      myDef = rndBattleNumber.nextDouble() *
              (_user.details.defense.max - _user.details.defense.min) +
          _user.details.defense.min;
    }

    ref.invalidate(userProvider);

    setState(() {
      currentExperience     = _user.details.xp;
      currentLevel          = expToLevel(currentExperience);
      nextExperienceLevel   = levelToExp(currentLevel + 1);
    });
  }
}
