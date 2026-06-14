import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/journal_image.dart';

import '../../models/app_error.dart';
import '../../models/journal_change.dart';
import '../../models/journal_page.dart';
import '../../providers/journal_provider.dart';
import '../../providers/journal_repository.dart';
import '../../providers/user_provider.dart';
import '../../shared/app_theme.dart';
import '../../shared/constants.dart';
import '../../shared/journal_html.dart';
import '../../text_style.dart';

/// Reads a single Journal page: the account prose, then its branches.
///
/// Open branches are playable; locked ones show their requirement strings so
/// the choice is never a mystery. Recovered (already-played, non-repeatable)
/// pages render read-only — the Keeper keeps them for re-reading.
class JournalReadScreen extends ConsumerStatefulWidget {
  final String slug;
  const JournalReadScreen({Key? key, required this.slug}) : super(key: key);

  @override
  ConsumerState<JournalReadScreen> createState() => _JournalReadScreenState();
}

class _JournalReadScreenState extends ConsumerState<JournalReadScreen> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final pageAsync = ref.watch(journalPageProvider(widget.slug));

    return Scaffold(
      backgroundColor: GlobalConstants.appBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Journal', style: Style.topBar),
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/book_candle.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Color(0xd9000000), BlendMode.darken),
            ),
          ),
        ),
        SafeArea(
          child: pageAsync.when(
            loading: () => Center(child: kCompassLoader()),
            error: (e, _) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  e is AppError && e.statusCode == 403
                      ? 'This page is not open to you yet.'
                      : 'Could not open this page.',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => context.pop(),
                  child: const Text('Back'),
                ),
              ]),
            ),
            data: (page) => _buildPage(context, page),
          ),
        ),
        if (_playing)
          Container(
            color: Colors.black54,
            child: Center(child: kCompassLoader(size: 90)),
          ),
      ]),
    );
  }

  Widget _buildPage(BuildContext context, JournalPage page) {
    final imageUrl = journalImageUrl(page.img);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
      children: [
        if (imageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
              placeholder: (_, __) => const SizedBox(height: 180),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(page.title,
            style: TextStyle(
              color: kGold,
              fontSize: 28,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: kGold.withValues(alpha: 0.5), blurRadius: 12)],
            )),
        const SizedBox(height: 16),
        ...renderJournalHtml(page.body),
        const SizedBox(height: 8),

        if (page.recovered) ...[
          _eldritchDivider(),
          Row(children: [
            Icon(Icons.menu_book, size: 16, color: kGold.withValues(alpha: 0.8)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'You have already recovered this page. The Keeper keeps it for you to read again.',
                style: TextStyle(
                    color: kSilverDim, fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
          ]),
        ] else if (page.branches.isNotEmpty) ...[
          _eldritchDivider(),
          for (final b in page.branches) _branch(context, page, b),
        ],
      ],
    );
  }

  Widget _branch(BuildContext context, JournalPage page, JournalBranch b) {
    if (b.open) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: kStoneButton(
          onTap: _playing ? null : () => _play(context, page.slug, b.key),
          child: Text(b.label,
              style: const TextStyle(
                  color: kGold,
                  fontSize: 17,
                  fontFamily: 'Cormorant SC',
                  fontWeight: FontWeight.bold)),
        ),
      );
    }
    // Locked branch — show the requirement so the choice isn't a mystery.
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x66161310),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.lock_outline, size: 15, color: kSilverDim),
          const SizedBox(width: 7),
          Expanded(
            child: Text(b.label,
                style: const TextStyle(color: Color(0xff9a948a), fontSize: 15)),
          ),
        ]),
        for (final r in b.reasons)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 22),
            child: Text('• $r',
                style: const TextStyle(color: kSilverDim, fontSize: 12)),
          ),
      ]),
    );
  }

  Future<void> _play(BuildContext context, String slug, String branch) async {
    setState(() => _playing = true);
    try {
      final result = await ref
          .read(journalRepositoryProvider)
          .play(storylet: slug, branch: branch);
      if (!mounted) return;
      // Refresh everything the play may have changed.
      ref.invalidate(journalProvider);
      ref.invalidate(journalPageProvider(slug));
      ref.invalidate(userProvider);
      setState(() => _playing = false);
      await _showOutcome(context, result);
      if (mounted) context.pop(); // back to the Journal, now advanced
    } on AppError catch (err) {
      if (!mounted) return;
      setState(() => _playing = false);
      err.show(context);
    } catch (err) {
      debugPrint('journal play unexpected error: $err');
      if (mounted) setState(() => _playing = false);
    }
  }

  Future<void> _showOutcome(
      BuildContext context, JournalPlayResult result) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xf2120d07),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: kGold.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (result.title.isNotEmpty)
              Text(result.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: kGold,
                      fontSize: 22,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: renderJournalHtml(result.result, fontSize: 15),
                ),
              ),
            ),
            if (result.changes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final c in result.changes)
                    if (c.label.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0x33e6a04e),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: kGold.withValues(alpha: 0.4)),
                        ),
                        child: Text(c.label,
                            style: const TextStyle(
                                color: kGold, fontSize: 12)),
                      ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            kStoneButton(
              onTap: () => Navigator.of(ctx).pop(),
              child: const Text('Continue',
                  style: TextStyle(
                      color: kGold,
                      fontSize: 16,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _eldritchDivider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(children: [
          Expanded(
              child: Divider(color: kGold.withValues(alpha: 0.35), thickness: 0.6)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text('✦',
                style: TextStyle(color: kGold.withValues(alpha: 0.7), fontSize: 11)),
          ),
          Expanded(
              child: Divider(color: kGold.withValues(alpha: 0.35), thickness: 0.6)),
        ]),
      );
}
