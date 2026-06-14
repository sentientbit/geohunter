import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/journal_image.dart';

import '../../models/journal_card.dart';
import '../../models/journal_gate.dart';
import '../../models/trait_record.dart';
import '../../providers/journal_provider.dart';
import '../../shared/app_theme.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

/// The Keeper's Journal — player-facing storylet screen.
///
/// Three sections, in the order a lost player needs them:
///   Open now      — pages you can play immediately
///   The trail ahead — reachable pages blocked only by a world-action, with the
///                     gate made apparent (requirement + progress + a jump to
///                     the map). This is the "what do I do next" answer.
///   Recovered     — the re-readable archive
/// Plus the Record: the Discoveries / Reputation / Marks you've gathered.
class JournalPageScreen extends ConsumerWidget {
  const JournalPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journal = ref.watch(journalProvider);

    final appBar = AppBar(
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text(AppLocalizations.of(context)!.translate('drawer_journal'),
          style: Style.topBar),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/poi-map'),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: GlobalConstants.appBg,
      appBar: appBar,
      extendBodyBehindAppBar: true,
      drawer: DrawerPage(),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/book_candle.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Color(0xcc000000), BlendMode.darken),
            ),
          ),
        ),
        SafeArea(
          child: journal.when(
            loading: () => Center(child: kCompassLoader()),
            error: (e, _) => _errorView(ref),
            data: (data) => RefreshIndicator(
              color: kGold,
              backgroundColor: const Color(0xff1a1408),
              onRefresh: () async {
                ref.invalidate(journalProvider);
                await ref.read(journalProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 40),
                children: [
                  if (data.available.isEmpty &&
                      data.locked.isEmpty &&
                      data.recovered.isEmpty)
                    _emptyHint()
                  else ...[
                    if (data.available.isNotEmpty) ...[
                      _sectionLabel('OPEN NOW'),
                      for (final c in data.available)
                        _OpenCard(card: c),
                    ],
                    if (data.locked.isNotEmpty) ...[
                      _sectionLabel('THE TRAIL AHEAD'),
                      for (final c in data.locked)
                        _LockedCard(card: c),
                    ],
                    if (data.recovered.isNotEmpty) ...[
                      _sectionLabel('RECOVERED'),
                      _RecoveredList(cards: data.recovered),
                    ],
                    if (!data.record.isEmpty) ...[
                      _sectionLabel('THE RECORD'),
                      _RecordPanel(record: data.record),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _errorView(WidgetRef ref) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('The Keeper could not be reached',
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: () => ref.invalidate(journalProvider),
          ),
        ]),
      );

  Widget _emptyHint() => Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(children: [
          Icon(Icons.menu_book, color: kGold.withValues(alpha: 0.4), size: 48),
          const SizedBox(height: 14),
          const Text(
            'The Keeper has nothing for you yet.\nWalk the world, and accounts will find you.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kSilverDim, fontSize: 14, height: 1.5),
          ),
        ]),
      );

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 18, 2, 8),
        child: Text(text,
            style: const TextStyle(
                color: kSilverDim, fontSize: 11, letterSpacing: 1.5)),
      );
}

// ── Open-now card ──────────────────────────────────────────────────────────────

class _OpenCard extends StatelessWidget {
  final JournalCard card;
  const _OpenCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xcc1d1812),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
              color: kGold.withValues(alpha: 0.08),
              blurRadius: 14,
              spreadRadius: 1),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _JournalThumb(img: card.img, locked: false),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(card.title,
                  style: const TextStyle(
                      color: Color(0xfff0e6d2),
                      fontSize: 16,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold)),
              if (card.teaser.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(card.teaser,
                    style: const TextStyle(
                        color: Color(0xff9a948a), fontSize: 13, height: 1.4)),
              ],
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => context.push('/journal/${card.slug}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                  color: kGold, borderRadius: BorderRadius.circular(8)),
              child: const Text('Read on',
                  style: TextStyle(
                      color: Color(0xff2a1c08),
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Locked "trail ahead" card — the gate made apparent ──────────────────────────

class _LockedCard extends StatelessWidget {
  final JournalCard card;
  const _LockedCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xcc161310),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _JournalThumb(img: card.img, locked: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(card.title,
                  style: const TextStyle(
                      color: Color(0xff9a948a),
                      fontSize: 16,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold)),
              if (card.teaser.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(card.teaser,
                    style: const TextStyle(
                        color: Color(0xff6f6a61), fontSize: 13, height: 1.4)),
              ],
            ]),
          ),
        ]),
        const SizedBox(height: 11),
        for (final gate in card.gates) _GateRow(gate: gate),
        // If the backend ever sends a reason without a structured gate, still
        // show the human string so the player is never left guessing.
        if (card.gates.isEmpty)
          for (final reason in card.reasons)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                Icon(Icons.lock_outline,
                    size: 15, color: kGold.withValues(alpha: 0.8)),
                const SizedBox(width: 7),
                Expanded(
                    child: Text(reason,
                        style: const TextStyle(
                            color: kSilverDim, fontSize: 13))),
              ]),
            ),
      ]),
    );
  }
}

class _GateRow extends StatelessWidget {
  final JournalGate gate;
  const _GateRow({required this.gate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xcc13110e),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kGold.withValues(alpha: 0.18)),
      ),
      child: Column(children: [
        Row(children: [
          Icon(_gateIcon(gate.ico), size: 16, color: kGold),
          const SizedBox(width: 7),
          Expanded(
            // Backend-provided, localized, self-describing label.
            child: Text(gate.label,
                style: const TextStyle(color: kSilver, fontSize: 13)),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: gate.progress,
                minHeight: 5,
                backgroundColor: const Color(0xff2a2620),
                valueColor: const AlwaysStoppedAnimation(kGold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${gate.have} of ${gate.need}',
              style: const TextStyle(color: kSilverDim, fontSize: 11)),
        ]),
        if (gate.isActionable) ...[
          const SizedBox(height: 9),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              // /places filters POIs by the LOC_TYPE int (= ico). For materials
              // (ico 0) there's no specific pin — open the full nearby list.
              onTap: () => context.push('/places?filter=${gate.ico}'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kGold.withValues(alpha: 0.45)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.map_outlined, size: 14, color: kGold),
                  const SizedBox(width: 5),
                  Text(
                      gate.ico > 0
                          ? 'Show ${gate.poi} nearby'
                          : 'Find somewhere to mine',
                      style: const TextStyle(color: kGold, fontSize: 12)),
                ]),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

// ── Recovered archive ──────────────────────────────────────────────────────────

class _RecoveredList extends StatelessWidget {
  final List<JournalCard> cards;
  const _RecoveredList({required this.cards});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < cards.length; i++)
          GestureDetector(
            onTap: () => context.push('/journal/${cards[i].slug}'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: i == cards.length - 1
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Row(children: [
                Icon(Icons.menu_book,
                    size: 16, color: kSilverDim.withValues(alpha: 0.8)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(cards[i].title,
                      style: const TextStyle(
                          color: Color(0xffb8b2a6), fontSize: 14)),
                ),
                Icon(Icons.chevron_right,
                    size: 16, color: Colors.white.withValues(alpha: 0.3)),
              ]),
            ),
          ),
      ],
    );
  }
}

// ── The Record (traits) ────────────────────────────────────────────────────────

class _RecordPanel extends StatelessWidget {
  final JournalRecord record;
  const _RecordPanel({required this.record});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _shelf('Discoveries', record.discovery),
      _shelf('Reputation', record.reputation),
      _shelf('Marks', record.mark),
    ]);
  }

  Widget _shelf(String label, List<TraitRecord> traits) {
    if (traits.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: kSilverDim,
                fontSize: 12,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final t in traits) _TraitChip(trait: t)],
        ),
      ]),
    );
  }
}

class _TraitChip extends StatelessWidget {
  final TraitRecord trait;
  const _TraitChip({required this.trait});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: trait.description,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x33000000),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kGold.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(trait.name,
              style: const TextStyle(color: Color(0xffcfcabf), fontSize: 12)),
          if (trait.value > 1) ...[
            const SizedBox(width: 5),
            Text('${trait.value}',
                style: const TextStyle(
                    color: kGold, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ]),
      ),
    );
  }
}

// ── Shared thumbnail ───────────────────────────────────────────────────────────

class _JournalThumb extends StatelessWidget {
  final String img;
  final bool locked;
  const _JournalThumb({required this.img, required this.locked});

  @override
  Widget build(BuildContext context) {
    // Storylet art is server-hosted and rendered over the network (it grows
    // arc-by-arc without app releases). Until a loadable URL is available the
    // themed icon stands in — and also serves as placeholder/error fallback.
    final icon = Icon(Icons.auto_stories,
        color: locked ? const Color(0xff55504a) : kGold, size: 22);
    final url = journalImageUrl(img);

    final box = Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: locked ? const Color(0xff1b1814) : const Color(0xff2a2113),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? icon
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: 46,
              height: 46,
              color: locked ? const Color(0x99000000) : null,
              colorBlendMode: locked ? BlendMode.darken : null,
              placeholder: (_, __) => icon,
              errorWidget: (_, __, ___) => icon,
            ),
    );

    if (!locked) return box;
    return Stack(clipBehavior: Clip.none, children: [
      box,
      Positioned(
        right: -4,
        bottom: -4,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
              color: Color(0xff161310), shape: BoxShape.circle),
          child: const Icon(Icons.lock, size: 13, color: kSilverDim),
        ),
      ),
    ]);
  }
}

/// Maps a gate's LOC_TYPE ico to a representative icon.
IconData _gateIcon(int ico) {
  switch (ico) {
    case 1:
      return Icons.hardware; // forge / metal
    case 2:
      return Icons.forest; // woodland
    case 3:
      return Icons.checkroom; // tannery
    case 6:
      return Icons.account_balance; // ruin
    case 7:
      return Icons.local_library; // library
    case 8:
      return Icons.storefront; // market / trader
    default:
      return Icons.terrain; // mine anywhere / materials
  }
}

