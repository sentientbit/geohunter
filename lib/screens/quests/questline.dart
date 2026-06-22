import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app_localizations.dart';
import '../../models/app_error.dart';
import '../../models/dailyreward.dart';
import '../../providers/api_provider.dart';
import '../../providers/daily_rewards_provider.dart';
import '../../providers/user_provider.dart';
import '../../shared/app_theme.dart';
import '../../shared/constants.dart';
import '../../shared/item_image.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';

/// The Archivist's Offering — the daily-reward cycle.
///
/// Each day the Archive offers up to three gifts (a blueprint, a material, an
/// item); the player chooses exactly ONE, claims it, and earns a coin. A
/// cooldown then runs until the next day unlocks; miss too long and the cycle
/// resets to day one.
///
/// Portrait adaptation of the web altar: hero → the day's choice cards
/// (choose-one) → Claim / cooldown → the cycle as a horizontal day-strip with
/// future previews and lock states → stats → recent offerings.
///
/// (Class/route still named "questline" for historical reasons — it is the
/// daily-rewards screen the drawer's "Rewards" item opens.)
class QuestLinePage extends ConsumerStatefulWidget {
  final String name = 'questline';
  QuestLinePage({Key? key}) : super(key: key);

  @override
  _QuestLinePageState createState() => _QuestLinePageState();
}

/// Which of the day's three gifts the player has selected.
enum _Pick { blueprint, material, item }

class _QuestLinePageState extends ConsumerState<QuestLinePage> {
  final _api = ApiProvider();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isClaiming = false;
  _Pick? _pick;

  /// Flipped true when the cooldown countdown reaches zero, so the claim UI
  /// appears without waiting for a refetch.
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(dailyRewardsProvider);
      ref.invalidate(userProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rewardsState = ref.watch(dailyRewardsProvider);

    final rewards = rewardsState.valueOrNull;
    final next = rewards?.nextReward ?? DailyReward.blank();
    final schedule = rewards?.schedule ?? const <DailyReward>[];
    final past = rewards?.pastRewards ?? const <DailyReward>[];
    final elapsed = rewards?.secondsElapsed ?? 0;
    final freq = rewards?.dailyRewardFreq ?? GlobalConstants.dailyGiftFreq;
    final cycleTotal = rewards?.cycleTotal ?? 9;
    final streak = rewards?.consecutiveRecoveries ?? 0;

    final claimable = elapsed >= freq || _ready;
    final remainingMs =
        DateTime.now().millisecondsSinceEpoch + (freq - elapsed) * 1000;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: GlobalConstants.appBg,
      extendBodyBehindAppBar: true,
      drawer: DrawerPage(),
      appBar: AppBar(
        elevation: 0.1,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.of(context)!.translate('drawer_rewards'),
          style: Style.topBar,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/book_candle.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Color(0xd1000000), BlendMode.darken),
            ),
          ),
        ),
        SafeArea(
          child: rewardsState.when(
            loading: () => Center(child: kCompassLoader()),
            error: (e, _) => _errorView(),
            data: (_) => RefreshIndicator(
              color: kGold,
              backgroundColor: const Color(0xff1a1408),
              onRefresh: () async {
                ref.invalidate(dailyRewardsProvider);
                await ref.read(dailyRewardsProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  _hero(),
                  const SizedBox(height: 18),
                  _sectionLabel("TODAY'S OFFERING"),
                  _offeringCard(next, claimable, remainingMs),
                  const SizedBox(height: 22),
                  if (schedule.isNotEmpty) ...[
                    _sectionLabel('THE CYCLE'),
                    _cycleStrip(schedule, next.day),
                    const SizedBox(height: 8),
                    _statsRow(next.day, cycleTotal, streak),
                    const SizedBox(height: 22),
                  ],
                  if (past.isNotEmpty) ...[
                    _sectionLabel('RECENT OFFERINGS'),
                    for (final r in past.take(5)) _recentRow(r),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (_isClaiming)
          Container(
            color: Colors.black54,
            child: Center(child: kCompassLoader(size: 90)),
          ),
      ]),
    );
  }

  // ── Hero ───────────────────────────────────────────────────────────────────

  Widget _hero() => Column(children: [
        Text(
          "THE ARCHIVIST'S OFFERING",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xfff0e6d2),
            fontSize: 26,
            height: 1.1,
            fontFamily: 'Cormorant SC',
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: kGold.withValues(alpha: 0.4), blurRadius: 14)],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'The Archive remembers those who return.\nAccept today’s offering before the cycle turns.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xffb0a999), fontSize: 13, height: 1.4),
        ),
      ]);

  // ── Today's offering: choice cards + claim / cooldown ────────────────────────

  Widget _offeringCard(DailyReward next, bool claimable, int remainingMs) {
    final options = <_Pick>[
      if (next.blueprintId > 0) _Pick.blueprint,
      if (next.materialId > 0) _Pick.material,
      if (next.itemId > 0) _Pick.item,
    ];

    // With a single gift there's nothing to choose — pre-select it.
    final effectivePick =
        _pick ?? (options.length == 1 ? options.first : null);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xcc1a140d),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGold.withValues(alpha: 0.40)),
        boxShadow: [
          BoxShadow(
              color: kGold.withValues(alpha: 0.10),
              blurRadius: 18,
              spreadRadius: 1),
        ],
      ),
      child: Column(children: [
        if (options.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('The Archive has nothing for you today.',
                style: TextStyle(color: kSilverDim, fontSize: 14)),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < options.length; i++) ...[
                Expanded(
                  child: _choiceCard(
                    next,
                    options[i],
                    selected: effectivePick == options[i],
                    selectable: claimable && options.length > 1,
                    onTap: claimable
                        ? () => setState(() => _pick = options[i])
                        : null,
                  ),
                ),
                if (i < options.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
        const SizedBox(height: 14),
        if (claimable)
          kStoneButton(
            onTap: (effectivePick == null || _isClaiming)
                ? null
                : () => _claim(next, effectivePick),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.auto_awesome, size: 17, color: kGold),
              const SizedBox(width: 8),
              Text(
                  effectivePick == null
                      ? 'Choose an offering'
                      : 'Claim Offering',
                  style: const TextStyle(
                      color: kGold,
                      fontSize: 16,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold)),
            ]),
          )
        else
          _cooldown(remainingMs),
      ]),
    );
  }

  Widget _choiceCard(
    DailyReward next,
    _Pick kind, {
    required bool selected,
    required bool selectable,
    required VoidCallback? onTap,
  }) {
    final (provider, name, tag) = switch (kind) {
      _Pick.blueprint => (
          AssetImage('assets/images/blueprints/${next.blueprint.img}')
              as ImageProvider,
          next.blueprint.name,
          'Blueprint'
        ),
      _Pick.material => (
          AssetImage('assets/images/materials/${next.material.img}')
              as ImageProvider,
          next.material.name,
          'Material'
        ),
      _Pick.item => (itemImageProvider(next.item.img), next.item.name, 'Item'),
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0x33e6a04e) : const Color(0x55000000),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? kGold
                : Colors.white.withValues(alpha: 0.10),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(children: [
          Image(image: provider, height: 60, width: 60),
          const SizedBox(height: 8),
          Text(name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Color(0xffe8dfce), fontSize: 12.5, height: 1.2)),
          const SizedBox(height: 3),
          Text(tag.toUpperCase(),
              style: TextStyle(
                  color: kGold.withValues(alpha: 0.75),
                  fontSize: 9,
                  letterSpacing: 1.2)),
          if (selectable) ...[
            const SizedBox(height: 6),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 15,
              color: selected ? kGold : Colors.white24,
            ),
          ],
        ]),
      ),
    );
  }

  Widget _cooldown(int remainingMs) => Column(children: [
        CountdownTimer(
          endTime: remainingMs,
          onEnd: () {
            if (mounted) setState(() => _ready = true);
          },
          widgetBuilder: (_, time) {
            if (time == null) {
              return const Text('The offering is ready.',
                  style: TextStyle(color: kGold, fontSize: 15));
            }
            return Column(children: [
              const Text('NEXT OFFERING IN',
                  style: TextStyle(
                      color: kSilverDim, fontSize: 10, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(_fmt(time),
                  style: const TextStyle(
                      color: Color(0xfff0e6d2),
                      fontSize: 30,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold)),
            ]);
          },
        ),
      ]);

  String _fmt(CurrentRemainingTime t) {
    final h = (t.hours ?? 0).toString().padLeft(2, '0');
    final m = (t.min ?? 0).toString().padLeft(2, '0');
    final s = (t.sec ?? 0).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ── The cycle: horizontal day-strip ──────────────────────────────────────────

  Widget _cycleStrip(List<DailyReward> schedule, int currentDay) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: schedule.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final d = schedule[i];
          final state = d.day < currentDay
              ? _DayState.claimed
              : (d.day == currentDay ? _DayState.current : _DayState.locked);
          return _dayChip(d, state);
        },
      ),
    );
  }

  Widget _dayChip(DailyReward d, _DayState state) {
    final isCurrent = state == _DayState.current;
    final isLocked = state == _DayState.locked;
    return Container(
      width: 78,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0x33e6a04e) : const Color(0x55000000),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrent
              ? kGold
              : Colors.white.withValues(alpha: 0.08),
          width: isCurrent ? 1.6 : 1,
        ),
        boxShadow: isCurrent
            ? [BoxShadow(color: kGold.withValues(alpha: 0.20), blurRadius: 12)]
            : null,
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('DAY ${d.day}',
            style: TextStyle(
                color: isCurrent ? kGold : kSilverDim,
                fontSize: 9,
                letterSpacing: 1.0,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Opacity(
          opacity: isLocked ? 0.45 : 1.0,
          child: Image(image: _primaryImage(d), height: 38, width: 38),
        ),
        const SizedBox(height: 6),
        Icon(
          state == _DayState.claimed
              ? Icons.check_circle
              : (isLocked ? Icons.lock_outline : Icons.brightness_1),
          size: 13,
          color: state == _DayState.claimed
              ? kGold
              : (isLocked ? Colors.white24 : kGold),
        ),
      ]),
    );
  }

  // ── Stats ────────────────────────────────────────────────────────────────────

  Widget _statsRow(int day, int cycleTotal, int streak) => Row(children: [
        Expanded(
            child: _statCard('CYCLE', '$day / $cycleTotal', Icons.calendar_today)),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard(
                'CONSECUTIVE', '$streak ${streak == 1 ? "day" : "days"}',
                Icons.local_fire_department)),
      ]);

  Widget _statCard(String label, String value, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xcc161310),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kGold.withValues(alpha: 0.22)),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: kGold),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    color: kSilverDim, fontSize: 9, letterSpacing: 1.2)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: Color(0xfff0e6d2),
                    fontSize: 16,
                    fontFamily: 'Cormorant SC',
                    fontWeight: FontWeight.bold)),
          ]),
        ]),
      );

  // ── Recent offerings ─────────────────────────────────────────────────────────

  Widget _recentRow(DailyReward r) {
    final (provider, name) = _claimed(r);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xaa161310),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(children: [
        Image(image: provider, height: 38, width: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Day ${r.day} — $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color(0xffcabfae),
                    fontSize: 14,
                    fontFamily: 'Cormorant SC',
                    fontWeight: FontWeight.w600)),
            if (r.date.isNotEmpty && r.date != '2000-01-01 01:01:01Z')
              Text(_fmtDate(r.date),
                  style: const TextStyle(color: kSilverDim, fontSize: 11)),
          ]),
        ),
        Icon(Icons.check_circle, size: 16, color: kGold.withValues(alpha: 0.7)),
      ]),
    );
  }

  String _fmtDate(String iso) {
    try {
      return DateFormat('dd MMM, HH:mm')
          .format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return '';
    }
  }

  // ── Image helpers ────────────────────────────────────────────────────────────

  /// The single gift a past claim actually granted.
  (ImageProvider, String) _claimed(DailyReward r) {
    if (r.blueprintId > 0) {
      return (
        AssetImage('assets/images/blueprints/${r.blueprint.img}'),
        r.blueprint.name
      );
    }
    if (r.materialId > 0) {
      return (
        AssetImage('assets/images/materials/${r.material.img}'),
        r.material.name
      );
    }
    if (r.itemId > 0) return (itemImageProvider(r.item.img), r.item.name);
    return (const AssetImage('assets/images/calendar_day.png'), 'Reward');
  }

  /// A schedule day's representative art (first gift it offers).
  ImageProvider _primaryImage(DailyReward d) {
    if (d.blueprintId > 0) {
      return AssetImage('assets/images/blueprints/${d.blueprint.img}');
    }
    if (d.materialId > 0) {
      return AssetImage('assets/images/materials/${d.material.img}');
    }
    if (d.itemId > 0) return itemImageProvider(d.item.img);
    return const AssetImage('assets/images/calendar_day.png');
  }

  // ── Claim ────────────────────────────────────────────────────────────────────

  Future<void> _claim(DailyReward next, _Pick pick) async {
    final bp = pick == _Pick.blueprint ? next.blueprint.id : 0;
    final mat = pick == _Pick.material ? next.material.id : 0;
    final item = pick == _Pick.item ? next.item.id : 0;

    setState(() => _isClaiming = true);
    try {
      final response =
          await _api.post('/dailyrewards/${next.day}/$bp/$mat/$item', {});

      // Surface exactly the gift that was granted.
      final images = <Image>[];
      for (final v in (response['blueprints'] ?? [])) {
        if (v?['img'] != null && v['img'] != '') {
          images.add(Image.asset('assets/images/blueprints/${v['img']}'));
        }
      }
      for (final v in (response['materials'] ?? [])) {
        if (v?['img'] != null && v['img'] != '') {
          images.add(Image.asset('assets/images/materials/${v['img']}'));
        }
      }
      for (final v in (response['items'] ?? [])) {
        if (v?['img'] != null && v['img'] != '') {
          images.add(Image(image: itemImageProvider(v['img'].toString())));
        }
      }

      ref.invalidate(dailyRewardsProvider);
      ref.invalidate(userProvider);

      if (!mounted) return;
      setState(() {
        _isClaiming = false;
        _pick = null;
        _ready = false;
      });
      showDialog<void>(
        context: context,
        builder: (_) => CustomDialog(
          title: AppLocalizations.of(context)!.translate('congrats'),
          description: 'The Archive grants its offering. +1 coin.',
          buttonText: 'Okay',
          images: images,
          callback: () {},
        ),
      );
    } on AppError catch (err) {
      if (!mounted) return;
      setState(() => _isClaiming = false);
      err.show(context, title: 'The Archivist’s Offering');
    } catch (err) {
      debugPrint('daily reward claim error: $err');
      if (mounted) setState(() => _isClaiming = false);
    }
  }

  Widget _errorView() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('The Archive could not be reached',
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: () => ref.invalidate(dailyRewardsProvider),
          ),
        ]),
      );

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 4, 2, 10),
        child: Row(children: [
          Text(text,
              style: TextStyle(
                  color: const Color(0xffd8cdb8),
                  fontSize: 12.5,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Cormorant SC',
                  shadows: [
                    Shadow(color: kGold.withValues(alpha: 0.25), blurRadius: 8)
                  ])),
          const SizedBox(width: 12),
          Expanded(
              child:
                  Divider(color: kGold.withValues(alpha: 0.30), thickness: 0.6)),
        ]),
      );
}

enum _DayState { claimed, current, locked }
