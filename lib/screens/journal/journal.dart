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
/// Layout, top to bottom (matching the redesign):
///   The Trail Ahead — a hero card per reachable-but-gated page, the gate made
///                     apparent (requirement + progress + a jump to the map).
///                     This is the "what do I do next" answer.
///   Open now        — pages you can play immediately (when any exist)
///   Recovered Pages — the re-readable archive, as numbered planks
///   The Record      — three themed panels over the same trait data:
///                       Marginalia   ← discovery traits (lore breadcrumbs)
///                       Favors owed  ← reputation traits (standing, with bars)
///                       Evidence     ← mark traits (countable tallies, a grid)
class JournalPageScreen extends ConsumerWidget {
  const JournalPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journal = ref.watch(journalProvider);

    final appBar = AppBar(
      elevation: 0.1,
      centerTitle: true,
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
                      data.recovered.isEmpty &&
                      data.record.isEmpty)
                    _emptyHint()
                  else ...[
                    // Trail Ahead first — its own label lives inside each card.
                    for (final c in data.locked) _TrailAheadCard(card: c),

                    if (data.available.isNotEmpty) ...[
                      _OrnamentHeader(
                          leading: Icons.auto_stories, label: 'OPEN NOW'),
                      for (final c in data.available) _OpenCard(card: c),
                    ],

                    if (data.recovered.isNotEmpty) ...[
                      _OrnamentHeader(
                        leading: Icons.menu_book,
                        label: 'RECOVERED PAGES',
                        ornament: Icons.visibility_outlined,
                      ),
                      _RecoveredPlanks(cards: data.recovered),
                    ],

                    if (!data.record.isEmpty) ...[
                      const SizedBox(height: 18),
                      _RecordPanels(record: data.record),
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
}

// ── Section header: leading icon + label + ornamented rule ───────────────────────

class _OrnamentHeader extends StatelessWidget {
  final IconData leading;
  final String label;
  final IconData? ornament;
  const _OrnamentHeader({required this.leading, required this.label, this.ornament});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 20, 2, 10),
      child: Row(children: [
        Icon(leading, size: 16, color: kGold.withValues(alpha: 0.85)),
        const SizedBox(width: 9),
        Text(label,
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
            child: Divider(color: kGold.withValues(alpha: 0.30), thickness: 0.6)),
        if (ornament != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(ornament, size: 13, color: kGold.withValues(alpha: 0.6)),
          ),
          SizedBox(
              width: 26,
              child: Divider(color: kGold.withValues(alpha: 0.30), thickness: 0.6)),
        ],
      ]),
    );
  }
}

// ── Trail-ahead hero card — the gate made apparent ───────────────────────────────

class _TrailAheadCard extends StatelessWidget {
  final JournalCard card;
  const _TrailAheadCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _JournalThumb(img: card.img, locked: true, size: 104),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('THE TRAIL AHEAD',
                  style: TextStyle(
                      color: kGold.withValues(alpha: 0.9),
                      fontSize: 11,
                      letterSpacing: 2.5,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(card.title.toUpperCase(),
                  style: const TextStyle(
                      color: Color(0xfff0e6d2),
                      fontSize: 23,
                      height: 1.05,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold)),
              if (card.teaser.isNotEmpty) ...[
                const SizedBox(height: 7),
                Text(card.teaser,
                    style: const TextStyle(
                        color: Color(0xffb0a999), fontSize: 14, height: 1.4)),
              ],
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        kEldritchDivider(kGold),
        for (final gate in card.gates) _GateRow(gate: gate),
        // If a reason arrives without a structured gate, still show the string.
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
                        style: const TextStyle(color: kSilverDim, fontSize: 13))),
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
    return Column(children: [
      Row(children: [
        Icon(_gateIcon(gate.ico), size: 18, color: kGold),
        const SizedBox(width: 9),
        Expanded(
          child: Text(gate.label,
              style: const TextStyle(color: kSilver, fontSize: 14.5)),
        ),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: gate.progress,
              minHeight: 7,
              backgroundColor: const Color(0xff2a2620),
              valueColor: const AlwaysStoppedAnimation(kGold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('${gate.have} / ${gate.need}',
            style: const TextStyle(color: kSilverDim, fontSize: 12)),
      ]),
      if (gate.isActionable) ...[
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            // /places filters POIs by the LOC_TYPE int (= ico). For materials
            // (ico 0) there's no specific pin — open the full nearby list.
            onTap: () => context.push('/places?filter=${gate.ico}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kGold.withValues(alpha: 0.45)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.map_outlined, size: 15, color: kGold),
                const SizedBox(width: 6),
                Text(
                    gate.ico > 0
                        ? 'Show ${gate.poi} nearby'
                        : 'Find somewhere to mine',
                    style: const TextStyle(color: kGold, fontSize: 13)),
              ]),
            ),
          ),
        ),
      ],
    ]);
  }
}

// ── Open-now card ────────────────────────────────────────────────────────────────

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
          _JournalThumb(img: card.img, locked: false, size: 52),
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

// ── Recovered archive — numbered planks ──────────────────────────────────────────

class _RecoveredPlanks extends StatelessWidget {
  final List<JournalCard> cards;
  const _RecoveredPlanks({required this.cards});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < cards.length; i++)
          _Plank(index: i + 1, card: cards[i]),
      ],
    );
  }
}

class _Plank extends StatelessWidget {
  final int index;
  final JournalCard card;
  const _Plank({required this.index, required this.card});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: GestureDetector(
        onTap: () => context.push('/journal/${card.slug}'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            // Faux-plank: a faint left-to-right warmth + bevelled edges.
            gradient: const LinearGradient(
              colors: [Color(0xcc241d14), Color(0xcc2e2519), Color(0xcc241d14)],
            ),
            border: Border.all(color: const Color(0x33000000)),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Row(children: [
            SizedBox(
              width: 26,
              child: Text(index.toString().padLeft(2, '0'),
                  style: TextStyle(
                      color: kGold.withValues(alpha: 0.75),
                      fontSize: 14,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.menu_book,
                size: 17, color: kSilverDim.withValues(alpha: 0.7)),
            const SizedBox(width: 11),
            Expanded(
              child: Text(card.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xffcabfae),
                      fontSize: 15,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.chevron_right,
                size: 18, color: kGold.withValues(alpha: 0.4)),
          ]),
        ),
      ),
    );
  }
}

// ── The Record: Marginalia | Favors owed, then Evidence ──────────────────────────

class _RecordPanels extends StatelessWidget {
  final JournalRecord record;
  const _RecordPanels({required this.record});

  @override
  Widget build(BuildContext context) {
    final hasMarginalia = record.discovery.isNotEmpty;
    final hasFavors = record.reputation.isNotEmpty;

    return Column(children: [
      if (hasMarginalia || hasFavors)
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (hasMarginalia)
              Expanded(child: _MarginaliaPanel(traits: record.discovery)),
            if (hasMarginalia && hasFavors) const SizedBox(width: 12),
            if (hasFavors)
              Expanded(child: _FavorsPanel(traits: record.reputation)),
          ]),
        ),
      if (record.mark.isNotEmpty) ...[
        const SizedBox(height: 12),
        _EvidencePanel(traits: record.mark),
      ],
    ]);
  }
}

/// Shared panel chrome: a small icon+title header inside a bordered box.
class _PanelBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final bool parchment;
  const _PanelBox({
    required this.icon,
    required this.title,
    required this.child,
    this.parchment = false,
  });

  @override
  Widget build(BuildContext context) {
    final headColor = parchment ? const Color(0xff5a4528) : kGold;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // Marginalia reads as aged paper; the rest stay dark.
        gradient: parchment
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xf0e7d9bb), Color(0xf0d8c49c)],
              )
            : null,
        color: parchment ? null : const Color(0xcc161310),
        border: Border.all(
            color: parchment
                ? const Color(0x665a4528)
                : kGold.withValues(alpha: 0.22)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 15, color: headColor),
          const SizedBox(width: 7),
          Text(title,
              style: TextStyle(
                  color: headColor,
                  fontSize: 12.5,
                  letterSpacing: 1.5,
                  fontFamily: 'Cormorant SC',
                  fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }
}

/// Marginalia ← discovery traits: lore breadcrumbs on aged paper.
class _MarginaliaPanel extends StatelessWidget {
  final List<TraitRecord> traits;
  const _MarginaliaPanel({required this.traits});

  @override
  Widget build(BuildContext context) {
    return _PanelBox(
      icon: Icons.history_edu,
      title: 'MARGINALIA',
      parchment: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final t in traits)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text('✦',
                    style: TextStyle(color: Color(0xff8a6d3b), fontSize: 11)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(t.name,
                    style: const TextStyle(
                        color: Color(0xff3a2f1e),
                        fontSize: 13.5,
                        height: 1.25,
                        fontStyle: FontStyle.italic)),
              ),
            ]),
          ),
      ]),
    );
  }
}

/// Favors owed ← reputation traits: standing with the world, drawn as bars.
///
/// Reputation has no fixed maximum, so the bar is relative to the strongest
/// standing the player holds — the highest favor reads as full, the rest scale
/// against it. The numeric value is always shown so nothing is lost.
class _FavorsPanel extends StatelessWidget {
  final List<TraitRecord> traits;
  const _FavorsPanel({required this.traits});

  @override
  Widget build(BuildContext context) {
    final maxVal = traits.fold<int>(1, (m, t) => t.value > m ? t.value : m);
    return _PanelBox(
      icon: Icons.balance,
      title: 'FAVORS OWED',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final t in traits)
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(children: [
              _TraitIcon(img: t.img, fallback: Icons.account_circle, size: 34),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(t.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xffcfcabf), fontSize: 13)),
                        ),
                        const SizedBox(width: 6),
                        Text('${t.value}',
                            style: const TextStyle(
                                color: kGold,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 5),
                      _PipBar(filled: (t.value / maxVal * 10).round().clamp(1, 10)),
                    ]),
              ),
            ]),
          ),
      ]),
    );
  }
}

/// A discrete 10-segment regard bar.
class _PipBar extends StatelessWidget {
  final int filled;
  const _PipBar({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 10; i++) ...[
          Expanded(
            child: Container(
              height: 7,
              decoration: BoxDecoration(
                color: i < filled ? kGold : const Color(0xff2a2620),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
          if (i < 9) const SizedBox(width: 2),
        ],
      ],
    );
  }
}

/// Evidence ← mark traits: countable tallies in a two-column grid.
class _EvidencePanel extends StatelessWidget {
  final List<TraitRecord> traits;
  const _EvidencePanel({required this.traits});

  @override
  Widget build(BuildContext context) {
    return _PanelBox(
      icon: Icons.visibility_outlined,
      title: 'EVIDENCE',
      child: Column(children: [
        for (var i = 0; i < traits.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _EvidenceCell(trait: traits[i])),
              const SizedBox(width: 10),
              Expanded(
                child: i + 1 < traits.length
                    ? _EvidenceCell(trait: traits[i + 1])
                    : const SizedBox.shrink(),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _EvidenceCell extends StatelessWidget {
  final TraitRecord trait;
  const _EvidenceCell({required this.trait});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        _TraitIcon(img: trait.img, fallback: Icons.label_important_outline, size: 30),
        const SizedBox(width: 9),
        Expanded(
          child: Text(trait.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Color(0xffb8b2a6), fontSize: 13, height: 1.15)),
        ),
        const SizedBox(width: 6),
        Text('${trait.value}',
            style: const TextStyle(
                color: kGold, fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

/// A round trait emblem: server image if present, else a themed fallback icon.
class _TraitIcon extends StatelessWidget {
  final String img;
  final IconData fallback;
  final double size;
  const _TraitIcon({required this.img, required this.fallback, required this.size});

  @override
  Widget build(BuildContext context) {
    final fb = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xff241d12),
        border: Border.all(color: kGold.withValues(alpha: 0.3)),
      ),
      child: Icon(fallback, size: size * 0.5, color: kGold.withValues(alpha: 0.8)),
    );

    final url = journalImageUrl(img);
    if (url == null) return fb;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => fb,
        errorWidget: (_, __, ___) => fb,
      ),
    );
  }
}

// ── Shared thumbnail ─────────────────────────────────────────────────────────────

class _JournalThumb extends StatelessWidget {
  final String img;
  final bool locked;
  final double size;
  const _JournalThumb({required this.img, required this.locked, this.size = 46});

  @override
  Widget build(BuildContext context) {
    // Storylet art is server-hosted and rendered over the network (it grows
    // arc-by-arc without app releases). Until a loadable URL is available the
    // themed icon stands in — and also serves as placeholder/error fallback.
    final icon = Icon(Icons.auto_stories,
        color: locked ? const Color(0xff7a705f) : kGold, size: size * 0.45);
    final url = journalImageUrl(img);

    final box = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: locked ? const Color(0xff1b1814) : const Color(0xff2a2113),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? icon
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: size,
              height: size,
              placeholder: (_, __) => icon,
              errorWidget: (_, __, ___) => icon,
            ),
    );

    return box;
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
