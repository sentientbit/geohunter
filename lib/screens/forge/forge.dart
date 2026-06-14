///
import 'dart:async';
import 'dart:math' as math;

import '../../shared/sfx.dart';
import 'package:flutter/material.dart';
import '../../app_localizations.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:go_router/go_router.dart';

///
import '../../fonts/rpg_awesome_icons.dart';
import '../../models/app_error.dart';
import '../../models/forge_result.dart';
import '../../models/user.dart';
import '../../providers/forge_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/forge/blueprints.dart';
import '../../screens/forge/materials.dart';
import '../../shared/app_theme.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';

///
enum PopupMenuChoice { refreshForge, showCoinSheet }

///
class ForgePage extends ConsumerStatefulWidget {
  ///
  final String name = 'forge';

  @override
  _ForgeState createState() => _ForgeState();
}

///
class _ForgeState extends ConsumerState<ForgePage>
    with SingleTickerProviderStateMixin {
  /// Secure Storage for User Data
  final _storage = FlutterSecureStorage();

  StreamSubscription? _subscription;

  bool _showCoinSheet = false;

  int _blueprintId = 0;
  String _blueprintImg = "";
  String _blueprintName = "";

  List<int> _materialsId = [0, 0, 0];
  List<String> _materialsImg = ["", "", ""];
  List<String> _materialsName = ["", "", ""];

  String _craftedItemImg = "";
  String _craftedItemName = "";
  String _craftedItemRarity = "";

  bool _isLoading = false;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Shimmer animation for crafted item reveal
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _getPlacements();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  // ── Slot widgets ─────────────────────────────────────────────────────────────

  Widget _blueprintSlot() {
    final filled = _blueprintId > 0;

    void openPicker() async {
      _clearPlacements();
      final picked = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => BlueprintSelectPage()),
      );
      if ((picked == true) && mounted) _getPlacements();
    }

    // One box, one border — content swaps, container never changes.
    final box = Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: openPicker,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: filled
                    ? kGold.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.18),
                width: filled ? 1.2 : 1.0,
              ),
            ),
            child: filled
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/blueprints/$_blueprintImg',
                      fit: BoxFit.contain,
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: kSilver, size: 32),
                      SizedBox(height: 6),
                      Text(
                        'Select Blueprint',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kSilver,
                          fontSize: 13,
                          fontFamily: 'Cormorant SC',
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        // ✕ badge — only when filled
        if (filled)
          Positioned(
            top: -10,
            right: -10,
            child: GestureDetector(
              onTap: _clearPlacements,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xff1a1a1a),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kGold.withValues(alpha: 0.6),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close, color: kGold, size: 14),
                ),
              ),
            ),
          ),
      ],
    );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          box,
            const SizedBox(height: 8),
          // Always reserve the name row height so empty and filled cards are the same size
          Text(
            filled ? _blueprintName : '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kSilver,
              fontSize: 15,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Four small L-bracket engravings at each corner of a socket.
  Widget _socketCorners(Color color) {
    const len = 9.0;
    const thick = 1.5;
    final c = color.withValues(alpha: 0.55);
    Widget hLine() => Container(width: len, height: thick, color: c);
    Widget vLine() => Container(width: thick, height: len, color: c);
    return Stack(children: [
      Positioned(top: 0, left: 0, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [vLine(), hLine()])),
      Positioned(top: 0, right: 0, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [hLine(), vLine()])),
      Positioned(bottom: 0, left: 0, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [vLine(), hLine()])),
      Positioned(bottom: 0, right: 0, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [hLine(), vLine()])),
    ]);
  }

  Widget _materialSlot(int idx) {
    final filled = _materialsId[idx] > 0;
    var mat0 = 0;
    for (var mat in _materialsId) {
      if (mat > 0) mat0 = mat;
    }

    // Border colours: dark steel when empty, warm gold when occupied.
    final borderColor = filled
        ? kGold.withValues(alpha: 0.75)
        : const Color(0xff484848);

    return Column(
      children: [
        // Socket container
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xff0b0b0b),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  // Outer glow when filled
                  if (filled)
                    BoxShadow(
                      color: kGold.withValues(alpha: 0.22),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  // Deep shadow for depth
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Stack(
                  children: [
                    // Content
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          Sfx.play(
                              'sfx/hammer_${(math.Random.secure().nextInt(3) + 1)}.mp3');
                          if (_blueprintId == 0) {
                            showDialog(
                              context: context,
                              builder: (context) => CustomDialog(
                                title: 'Error',
                                description: 'Please select a blueprint first',
                                buttonText: 'Okay',
                                images: [],
                                callback: () {},
                              ),
                            );
                            return;
                          }
                          final picked = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MaterialSelectPage(
                                  blueprintId: _blueprintId,
                                  placement: idx,
                                  mat0: mat0),
                            ),
                          );
                          if ((picked == true) && mounted) _getPlacements();
                        },
                        splashColor: kGold.withValues(alpha: 0.25),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: filled
                              ? Image.asset(
                                  'assets/images/materials/${_materialsImg[idx]}',
                                  fit: BoxFit.contain,
                                )
                              : Center(
                                  child: Icon(Icons.add,
                                      color: const Color(0xff3a3a3a), size: 26),
                                ),
                        ),
                      ),
                    ),
                    // Inner-shadow vignette (simulates depth/inset)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 1.0,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.35),
                              ],
                              stops: const [0.55, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Engraved corner marks
            Positioned.fill(
              child: IgnorePointer(
                child: _socketCorners(filled ? kGold : const Color(0xff585858)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 88,
          child: Text(
            filled ? _materialsName[idx] : '— empty —',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: filled ? kSilver : const Color(0xff3a3a3a),
              fontSize: 11,
              fontFamily: 'Open Sans',
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  void _clearCraftedItem() {
    setState(() {
      _craftedItemImg    = '';
      _craftedItemName   = '';
      _craftedItemRarity = '';
    });
  }

  Widget _craftedItemSection(User user) {
    final filled = _craftedItemImg.isNotEmpty;
    final rarityInt = int.tryParse(_craftedItemRarity) ?? 0;
    final rarityColor = colorRarity(rarityInt);

    // AnimatedSwitcher handles the filled ↔ empty transition.
    // The key on each child changes when the item changes, so the switcher
    // always animates when the crafted item is set or cleared.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchOutCurve: Curves.easeIn,
      switchInCurve: Curves.easeOut,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.86, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: filled
          ? _craftedItemFilled(rarityInt, rarityColor)
          : _craftedItemEmpty(),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────────
  Widget _craftedItemEmpty() {
    return Padding(
      key: const ValueKey('crafted_empty'),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xff0b0b0b),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xff303030), width: 1),
              ),
              child: Center(
                child: Icon(RPGAwesome.forging,
                    color: const Color(0xff2e2e2e), size: 32),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Result appears\nafter forging',
              style: TextStyle(
                color: const Color(0xff2e2e2e),
                fontSize: 15,
                fontFamily: 'Open Sans',
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

  // ── Filled — dramatic reveal ────────────────────────────────────────────────
  Widget _craftedItemFilled(int rarityInt, Color rarityColor) {
    return GestureDetector(
      key: ValueKey(_craftedItemImg),
      onTap: _clearCraftedItem,
      child: AnimatedBuilder(
        animation: _shimmerAnim,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment(_shimmerAnim.value - 1, -0.3),
            end: Alignment(_shimmerAnim.value + 0.4, 0.3),
            colors: [
              Colors.transparent,
              rarityColor.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.10),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 0.6, 1.0],
          ).createShader(rect),
          child: child!,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Item image with rarity glow ring
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xff0b0b0b),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: rarityColor.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: rarityColor.withValues(alpha: 0.35),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: rarityColor.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/items/$_craftedItemImg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _socketCorners(rarityColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Name + rarity chip + dismiss hint
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _craftedItemName,
                      style: TextStyle(
                        color: rarityColor,
                        fontSize: 24,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                              color: rarityColor.withValues(alpha: 0.8),
                              blurRadius: 14),
                          Shadow(
                              color: rarityColor.withValues(alpha: 0.4),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    _rarityChip(rarityInt, rarityColor),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to dismiss',
                      style: TextStyle(
                        color: kSilverDim.withValues(alpha: 0.45),
                        fontSize: 10,
                        fontFamily: 'Open Sans',
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rarityChip(int rarity, Color color) {
    const labels = {
      0: 'Common',
      1: 'Uncommon',
      2: 'Rare',
      3: 'Epic',
      4: 'Legendary',
      5: 'Mythic',
    };
    final label = labels[rarity] ?? 'Unknown';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.bold,
          letterSpacing: 2.5,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  void choiceAction(BuildContext context, PopupMenuChoice choice) async {
    if (choice == PopupMenuChoice.refreshForge) {
      _clearPlacements();
    } else if (choice == PopupMenuChoice.showCoinSheet) {
      setState(() {
        _showCoinSheet = !_showCoinSheet;
      });
    }
  }

  ///
  Widget leadingIcon(BuildContext context, UserData userDetails) {
    if (!GlobalConstants.menuHasNotification(userDetails)) {
      return IconButton(
        color: Colors.white,
        icon: Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          if (_scaffoldKey.currentState != null) {
            _scaffoldKey.currentState?.openDrawer();
          } else {
            Navigator.of(context).pop();
          }
        },
      );
    }

    return InkWell(
      splashColor: Colors.lightBlue,
      onTap: () {
        if (_scaffoldKey.currentState != null) {
          _scaffoldKey.currentState?.openDrawer();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Center(
        child: Container(
          margin: EdgeInsets.only(left: 10),
          width: 40,
          height: 25,
          child: Stack(
            children: [
              Icon(Icons.menu, color: Colors.white),
              Positioned(
                left: 25,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///
  Widget build(BuildContext context) {
    int currentTabIndex = 0;
    final user = ref.watch(userProvider).valueOrNull ?? User.blank();
    final craftingCost = user.details.costs.crafting.toDouble();

    final topBar = AppBar(
      leading: leadingIcon(context, user.details),
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(AppLocalizations.of(context)!.translate('drawer_forge'),
          style: Style.topBar),
      actions: <Widget>[
        // Coin balance chip
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGold.withValues(alpha: 0.4), width: 0.8),
          ),
          child: Row(
            children: [
              Icon(Icons.monetization_on, color: kGold, size: 14),
              SizedBox(width: 4),
              Text(
                user.details.coins.toStringAsFixed(2),
                style: TextStyle(
                  color: kGold,
                  fontSize: 13,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 4),
        PopupMenuButton<PopupMenuChoice>(
          iconColor: Colors.white,
          onSelected: (onSel) => choiceAction(context, onSel),
          itemBuilder: (context) => <PopupMenuEntry<PopupMenuChoice>>[
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.refreshForge,
              child: Row(
                children: [
                  Icon(Icons.autorenew, size: 24, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Cleanup', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.showCoinSheet,
              child: Row(
                children: [
                  Icon(Icons.monetization_on, size: 24, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Get more coins', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
          color: GlobalConstants.appBg,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ],
    );

    onTapped(int index) {
      setState(() => currentTabIndex = index);
      if (index == 1) context.replace('/research');
    }

    // ── Coin sheet (unchanged layout, kept compact) ──────────────────────────
    final watchAdButton = kStoneButton(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.ondemand_video, color: kGold),
          const SizedBox(width: 6),
          Text(' Watch ad',
              style: TextStyle(
                  color: kGold,
                  fontSize: 16,
                  fontFamily: 'Cormorant SC',
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );

    final coinSheet = Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      decoration: BoxDecoration(color: const Color(0xcc222222)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                onPressed: () => setState(() => _showCoinSheet = false),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('Watch an ad to gain a few coins.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    SizedBox(height: 8),
                    watchAdButton,
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Text('Coming soon',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    SizedBox(height: 8),
                    kStoneButton(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      onTap: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.monetization_on, color: kGold),
                          const SizedBox(width: 6),
                          Text(' 0.0',
                              style: TextStyle(
                                  color: kGold,
                                  fontSize: 16,
                                  fontFamily: 'Cormorant SC',
                                  fontWeight: FontWeight.bold)),
                        ],
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

    // ── Main body ────────────────────────────────────────────────────────────
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.pop();
      },
      child: Scaffold(
        backgroundColor: GlobalConstants.appBg,
        appBar: topBar,
        body: LoadingOverlay(
          isLoading: _isLoading,
          opacity: 0.5,
          color: Colors.black,
          progressIndicator: CircularProgressIndicator(
            backgroundColor: Colors.black,
            valueColor: AlwaysStoppedAnimation<Color>(kGold),
          ),
          child: Stack(
            children: [
              // ── Background with dark overlay ──────────────────────────
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/blacksmith_hammer.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.60),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
              // Vertical gradient — darker at top and bottom for depth
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.50),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.60),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              // ── Content ───────────────────────────────────────────────
              SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Coin sheet
                      if (_showCoinSheet) ...[
                        coinSheet,
                        SizedBox(height: 8),
                      ],

                      // ── BLUEPRINT card ─────────────────────────────────
                      Container(
                        // No padding — slot fills the card edge-to-edge.
                        decoration: kCardDecoration(
                          _blueprintId > 0 ? kGold : kSilverDim,
                          glowAlpha: _blueprintId > 0 ? 0.10 : 0.03,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                              child: Text('BLUEPRINT', style: kSectionLabel),
                            ),
                            _blueprintSlot(),
                          ],
                        ),
                      ),

                      kEldritchDivider(kGold),

                      // ── MATERIALS card ─────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: kCardDecoration(
                          _materialsId.any((id) => id > 0)
                              ? kGold
                              : kSilverDim,
                          glowAlpha:
                              _materialsId.any((id) => id > 0) ? 0.08 : 0.03,
                        ),
                        child: Column(
                          children: [
                            Text('MATERIALS', style: kSectionLabel),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _materialSlot(0),
                                _materialSlot(1),
                                _materialSlot(2),
                              ],
                            ),
                          ],
                        ),
                      ),

                      kEldritchDivider(kGold),

                      // ── CRAFTED ITEM card ──────────────────────────────
                      Container(
                        decoration: kCardDecoration(
                          _craftedItemImg.isNotEmpty
                              ? colorRarity(
                                  int.tryParse(_craftedItemRarity) ?? 0)
                              : kSilverDim,
                          glowAlpha:
                              _craftedItemImg.isNotEmpty ? 0.10 : 0.03,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                              child: Text('CRAFTED ITEM', style: kSectionLabel),
                            ),
                            _craftedItemSection(user),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── CRAFT BUTTON ──────────────────────────────────
                      _craftButton(craftingCost),

                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        key: _scaffoldKey,
        drawer: DrawerPage(),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTapped,
          currentIndex: currentTabIndex,
          backgroundColor: GlobalConstants.appBg,
          selectedItemColor: kGold,
          selectedLabelStyle: const TextStyle(fontSize: 14),
          unselectedItemColor: Colors.white,
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          items: [
            BottomNavigationBarItem(
              icon: Icon(RPGAwesome.forging, color: Colors.white),
              label: 'Forge',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.import_contacts, color: Colors.white),
              label: 'Research',
            ),
          ],
        ),
      ),
    );
  }

  Widget _craftButton(double craftingCost) {
    final costLabel = craftingCost > 0
        ? '  ·  ${craftingCost.toStringAsFixed(craftingCost == craftingCost.truncateToDouble() ? 0 : 2)} coins'
        : '';
    return kStoneButton(
      onTap: _craftItem,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(RPGAwesome.forging, color: kGold, size: 20),
          const SizedBox(width: 8),
          Text(
            'Craft$costLabel',
            style: const TextStyle(
              color: kGold,
              fontSize: 18,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ── Data logic (unchanged) ────────────────────────────────────────────────

  void _getPlacements() async {
    var secureStorage = await _storage.readAll();
    setState(() {
      if (secureStorage.containsKey("forgeBlueprintId")) {
        _blueprintId =
            int.tryParse(secureStorage["forgeBlueprintId"] ?? "") ?? 0;
        _blueprintImg = secureStorage["forgeBlueprintImg"] ?? "nothing.png";
        _blueprintName = secureStorage["forgeBlueprintName"] ?? "Blueprint";
      }
      if (secureStorage.containsKey("forgeMaterial0Id")) {
        _materialsId[0] =
            int.tryParse(secureStorage["forgeMaterial0Id"] ?? "") ?? 0;
        _materialsImg[0] = secureStorage["forgeMaterial0Img"] ?? "nothing.png";
        _materialsName[0] = secureStorage["forgeMaterial0Name"] ?? "Material";
      }
      if (secureStorage.containsKey("forgeMaterial1Id")) {
        _materialsId[1] =
            int.tryParse(secureStorage["forgeMaterial1Id"] ?? "") ?? 0;
        _materialsImg[1] = secureStorage["forgeMaterial1Img"] ?? "nothing.png";
        _materialsName[1] = secureStorage["forgeMaterial1Name"] ?? "Material";
      }
      if (secureStorage.containsKey("forgeMaterial2Id")) {
        _materialsId[2] =
            int.tryParse(secureStorage["forgeMaterial2Id"] ?? "") ?? 0;
        _materialsImg[2] = secureStorage["forgeMaterial2Img"] ?? "nothing.png";
        _materialsName[2] = secureStorage["forgeMaterial2Name"] ?? "Material";
      }
    });
  }

  void _clearPlacements() async {
    await _storage.delete(key: 'forgeBlueprintId');
    await _storage.delete(key: 'forgeBlueprintImg');
    await _storage.delete(key: 'forgeBlueprintName');
    await _storage.delete(key: "forgeMaterial0Id");
    await _storage.delete(key: "forgeMaterial0Img");
    await _storage.delete(key: "forgeMaterial0Name");
    await _storage.delete(key: "forgeMaterial1Id");
    await _storage.delete(key: "forgeMaterial1Img");
    await _storage.delete(key: "forgeMaterial1Name");
    await _storage.delete(key: "forgeMaterial2Id");
    await _storage.delete(key: "forgeMaterial2Img");
    await _storage.delete(key: "forgeMaterial2Name");
    setState(() {
      _blueprintId = 0;
      _blueprintImg = "";
      _blueprintName = "";
      _materialsId = [0, 0, 0];
      _materialsImg = ["", "", ""];
      _materialsName = ["", "", ""];
    });
  }

  void _craftItem() async {
    if (_blueprintId <= 0) {
      _clearPlacements();
      setState(() {
        _craftedItemImg = "";
        _craftedItemName = "";
        _craftedItemRarity = "";
      });
      return;
    }
    setState(() => _isLoading = true);
    ForgeResult result;
    try {
      result = await ref.read(forgeRepositoryProvider).craft(
            _blueprintId,
            _materialsId[0],
            _materialsId[1],
            _materialsId[2],
          );
    } on AppError catch (err) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      err.show(context);
      return;
    } catch (err) {
      debugPrint('_craftItem unexpected error: $err');
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.item.nr > 0) {
      _clearPlacements();
      setState(() {
        _craftedItemImg = result.item.img;
        _craftedItemName = result.item.name;
        _craftedItemRarity = result.item.rarity.toString();
      });
      Sfx.play('sfx/anvil_1.mp3');
    }
    ref.invalidate(userProvider);
    ref.invalidate(inventoryProvider);
  }
}
