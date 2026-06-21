import '../../shared/sfx.dart';
import '../../shared/item_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geohunter/fonts/rpg_awesome_icons.dart';

import '../../app_localizations.dart';
import '../../models/app_error.dart';
import '../../models/item.dart';
import '../../models/materialmodel.dart';
import '../../providers/api_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/inventory_repository.dart';
import '../../providers/user_provider.dart';
import '../../shared/app_theme.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';

// ── Design tokens — from app_theme.dart ───────────────────────────────────────
// Local aliases so existing code below compiles unchanged.
const _cardBg    = kCardBg;
const _silver    = kSilver;
const _silverDim = kSilverDim;
const _sectionLbl = kSectionLabel;

class ItemDetailPage extends ConsumerStatefulWidget {
  final Item item;
  const ItemDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  _ItemDetailState createState() => _ItemDetailState();
}

class _ItemDetailState extends ConsumerState<ItemDetailPage> {
  double _nrDisItems = 0;
  bool   _isDeleting      = false;
  bool   _isTogglingLock  = false;
  late bool _locked;

  String _description  = '';
  String _blueprintImg = '';
  String _blueprintName = '';
  final _misc = <String>[];

  /// Disassembly components from /itemdetails (empty = no recorded recipe).
  final _components = <Materialmodel>[];

  final _inventoryRepo = InventoryRepository();
  final _apiProvider   = ApiProvider();
  final _scaffoldKey   = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _locked = widget.item.locked;
    _getItemDetails(widget.item.id);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Color get _accent => colorRarity(widget.item.rarity);

  /// Thin ornamental divider: ─── ✦ ───
  Widget _eldritchDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(children: [
        Expanded(child: Divider(color: _accent.withValues(alpha: 0.35), thickness: 0.6)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('✦',
              style: TextStyle(color: _accent.withValues(alpha: 0.7), fontSize: 11)),
        ),
        Expanded(child: Divider(color: _accent.withValues(alpha: 0.35), thickness: 0.6)),
      ]),
    );
  }

  /// Dark card with rarity-tinted border
  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _accent.withValues(alpha: 0.22), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.08),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text.toUpperCase(), style: _sectionLbl),
  );

  // ── Hero section ─────────────────────────────────────────────────────────────

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(children: [
        // Rarity glow behind item — fx image clipped to a soft circle
        Stack(alignment: Alignment.center, children: [
          // Rarity fx image as localized glow
          ClipOval(
            child: Image.asset(
              rarityBackground(widget.item.rarity),
              width: 260,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),
          // Soft vignette so glow fades at edges
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                ],
                stops: const [0.55, 1.0],
              ),
            ),
          ),
          // Item image on top
          Image(
            image: itemImageProvider(widget.item.img),
            height: 180,
            width:  180,
            fit: BoxFit.contain,
          ),
        ]),
        const SizedBox(height: 16),

        // Item name
        Text(
          widget.item.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _accent,
            fontSize: 30,
            fontFamily: 'Cormorant SC',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: _accent.withValues(alpha: 0.6),
                blurRadius: 14,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Stars + level + quantity row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Filled stars in rarity colour
            for (var i = 0; i < widget.item.rarity; i++)
              Icon(Icons.star, color: _accent, size: 22),

            const SizedBox(width: 14),

            // Level chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Lvl ${widget.item.level}',
                style: const TextStyle(color: _silver, fontSize: 15),
              ),
            ),

            const SizedBox(width: 10),

            // Quantity chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.10),
                border: Border.all(color: _accent.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${widget.item.nr} pcs',
                style: TextStyle(
                  color: _accent,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  // ── Lore section ─────────────────────────────────────────────────────────────

  Widget _buildLore() {
    if (_description.isEmpty && _misc.isEmpty) return const SizedBox.shrink();
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Lore'),
        if (_description.isNotEmpty)
          Text(
            _description,
            style: const TextStyle(
              color: _silver,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        if (_misc.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...(_misc.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              Text('✦ ', style: TextStyle(color: _accent, fontSize: 11)),
              Expanded(
                child: Text(m,
                    style: const TextStyle(color: _silver, fontSize: 15)),
              ),
            ]),
          ))),
        ],
      ]),
    );
  }

  // ── Origin section ───────────────────────────────────────────────────────────

  Widget _buildOrigin() {
    if (_blueprintImg.isEmpty) return const SizedBox.shrink();
    return _card(
      child: Row(children: [
        // Blueprint image
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _accent.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            'assets/images/blueprints/$_blueprintImg',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 16),

        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Origin'),
            Text(
              _blueprintName,
              style: TextStyle(
                color: _accent,
                fontSize: 19,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Knowledge bound into form',
              style: TextStyle(color: _silverDim, fontSize: 14,
                  fontStyle: FontStyle.italic),
            ),
          ],
        )),
      ]),
    );
  }

  // ── Components section ───────────────────────────────────────────────────────
  /// Disassembly components — what this item breaks down into.
  /// Hidden when the item has no recorded recipe (empty array from the API).
  Widget _buildComponents() {
    if (_components.isEmpty) return const SizedBox.shrink();
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Components'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _components.map((m) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _accent.withValues(alpha: 0.3)),
                ),
                padding: const EdgeInsets.all(6),
                child: m.img != 'nothing.png'
                    ? Image.asset(
                        'assets/images/materials/${m.img}',
                        fit: BoxFit.contain,
                      )
                    : const Icon(Icons.help_outline,
                        color: Colors.white24, size: 28),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 72,
                child: Text(
                  '${m.name} ×${m.nr}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _silverDim, fontSize: 12),
                ),
              ),
            ],
          )).toList(),
        ),
      ]),
    );
  }

  // ── Disassemble section ──────────────────────────────────────────────────────────

  Widget _buildDisassemble(BuildContext context) {
    const _red = Color(0xff8b1a1a);
    final canAct = !_locked && widget.item.nr > 0;

    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _sectionLabel('Disassemble'),
          const Spacer(),
          if (_locked)
            Row(children: [
              Icon(Icons.lock, color: _accent, size: 12),
              const SizedBox(width: 4),
              Text('Sealed', style: TextStyle(color: _accent, fontSize: 11)),
            ]),
        ]),

        const Text(
          'Break down this item to reclaim the materials from which it was forged.',
          style: TextStyle(
            color: _silverDim,
            fontSize: 14,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),

        // Quantity slider
        if (widget.item.nr > 1) ...[
          Row(children: [
            Text(
              '${_nrDisItems.toInt()}',
              style: TextStyle(
                color: canAct ? Colors.redAccent : Colors.white24,
                fontSize: 22,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(' / ${widget.item.nr}',
                style: const TextStyle(color: Colors.white24, fontSize: 14)),
          ]),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: canAct ? Colors.redAccent : Colors.white12,
              inactiveTrackColor: Colors.white12,
              trackHeight: 3.0,
              thumbColor: canAct ? Colors.redAccent : Colors.white24,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayColor: Colors.red.withAlpha(24),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
            ),
            child: Slider(
              min: 0,
              max: widget.item.nr.toDouble(),
              value: _nrDisItems,
              divisions: widget.item.nr,
              onChanged: _locked
                  ? null
                  : (v) => setState(() => _nrDisItems = v),
            ),
          ),
          const SizedBox(height: 16),
        ] else ...[
          // Single item — auto-set to 1
          const SizedBox(height: 8),
        ],

        // Disassemble button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: canAct
                  ? _red.withValues(alpha: 0.25)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              side: BorderSide(
                color: canAct
                    ? Colors.redAccent.withValues(alpha: 0.7)
                    : Colors.white12,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: canAct && (_nrDisItems > 0 || widget.item.nr == 1)
                ? () {
                    if (widget.item.nr == 1) {
                      setState(() => _nrDisItems = 1);
                    }
                    _deleteItem(context, widget.item.id);
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(RPGAwesome.recycle,
                    color: canAct ? Colors.redAccent : Colors.white24,
                    size: 18),
                const SizedBox(width: 10),
                Text(
                  _isDeleting ? 'Disassembling…' : 'Disassemble',
                  style: TextStyle(
                    color: canAct ? Colors.redAccent : Colors.white24,
                    fontSize: 20,
                    fontFamily: 'Cormorant SC',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  // ── Main build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text('Details', style: Style.topBar),
      actions: [
        _isTogglingLock
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
              )
            : IconButton(
                tooltip: _locked ? 'Unlock item' : 'Lock item',
                icon: Icon(
                  _locked ? Icons.lock : Icons.lock_open,
                  color: _locked ? const Color(0xffe6a04e) : _silver,
                ),
                onPressed: _toggleLock,
              ),
        IconButton(
          icon: const Icon(Icons.arrow_back, color: _silver),
          onPressed: () => context.pop(),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBar,
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        // Static dark backdrop
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/friend_campfire.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Color(0xcc000000),
                BlendMode.darken,
              ),
            ),
          ),
        ),

        // Scrollable content
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(children: [
              const SizedBox(height: 12),
              _buildHero(),
              _eldritchDivider(),
              _buildLore(),
              if (_blueprintImg.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildOrigin(),
              ],
              if (_components.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildComponents(),
              ],
              const SizedBox(height: 4),
              _buildDisassemble(context),
            ]),
          ),
        ),
      ]),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────────

  Future<void> _toggleLock() async {
    if (_isTogglingLock) return;
    setState(() => _isTogglingLock = true);
    try {
      final newLocked =
          await _inventoryRepo.setLocked(widget.item.id, locked: !_locked);
      if (mounted) setState(() => _locked = newLocked);
    } on AppError catch (err) {
      if (mounted) err.show(context);
    } catch (err) {
      debugPrint('_toggleLock unexpected error: $err');
    } finally {
      if (mounted) setState(() => _isTogglingLock = false);
    }
  }

  void _deleteItem(BuildContext context, int itemId) async {
    if (_isDeleting) return;
    final nrItems = widget.item.nr == 1 ? 1 : _nrDisItems.toInt();
    if (nrItems <= 0) return;

    setState(() => _isDeleting = true);

    dynamic response;
    try {
      response = await _apiProvider.delete('/inventory/$itemId/$nrItems', {});
    } on AppError catch (err) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      err.show(context);
      return;
    } catch (err) {
      debugPrint('_deleteItem unexpected error: $err');
      if (mounted) setState(() => _isDeleting = false);
      return;
    }

    if (!mounted) return;
    setState(() => _isDeleting = false);

    final List<Image> imagesArr = [];
    if (response['materials']?.isNotEmpty == true) {
      for (final v in response['materials']) {
        if (v['img'] != null && v['img'] != '') {
          imagesArr.add(Image.asset('assets/images/materials/${v['img']}'));
        }
      }
    }
    if (response['blueprints']?.isNotEmpty == true) {
      for (final v in response['blueprints']) {
        if (v['img'] != null && v['img'] != '' && (v['id'] ?? 0) > 0) {
          imagesArr.add(Image.asset('assets/images/blueprints/${v['img']}'));
        }
      }
    }

    if (response['success'] == true) {
      ref.invalidate(inventoryProvider);
      ref.invalidate(userProvider);
      Sfx.play('sfx/break_1.mp3');
      showDialog(
        context: context,
        builder: (ctx) => CustomDialog(
          title: AppLocalizations.of(context)!.translate('congrats'),
          description: response['message'],
          buttonText: 'Okay',
          images: imagesArr,
          callback: () {
            Navigator.of(ctx).pop();
            context.go('/inventory');
          },
        ),
      );
    }
  }

  void _getItemDetails(int itemId) async {
    if (itemId <= 0) return;
    try {
      final response = await _apiProvider.get('/itemdetails/$itemId');
      final miscMap = response['misc'] as Map<String, dynamic>;
      setState(() {
        _misc.clear();
        _misc.addAll(miscMap.values.map((v) => v.toString()));
        _description  = response['description']['en'] ?? '';
        _blueprintName = response['blueprint']['name'] ?? '';
        _blueprintImg  = response['blueprint']['img'] ?? '';
        _components.clear();
        for (final m in (response['materials'] as List? ?? [])) {
          _components.add(Materialmodel.fromJson(m));
        }
      });
    } on AppError catch (err) {
      debugPrint(err.toString());
    } catch (err) {
      debugPrint('_getItemDetails unexpected error: $err');
    }
  }
}
