///
import 'dart:async';
import 'dart:math' as math;

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:go_router/go_router.dart';

//import 'package:logger/logger.dart';

///
import '../../fonts/rpg_awesome_icons.dart';
import '../../models/app_error.dart';
import '../../models/forge_result.dart';
import '../../models/user.dart';
import '../../providers/forge_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../screens/forge/blueprints.dart';
import '../../screens/forge/materials.dart';
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
class _ForgeState extends ConsumerState<ForgePage> {
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

  @override
  void initState() {
    super.initState();
    _getPlacements();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  Widget blueprintPlace() {
    return Ink(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: (_blueprintImg == "")
              ? ExactAssetImage("assets/images/items/nothing.png")
              : ExactAssetImage("assets/images/blueprints/$_blueprintImg"),
          fit: BoxFit.contain,
        ),
      ),
      child: InkWell(
        onTap: () async {
          _clearPlacements();
          final picked = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => BlueprintSelectPage(),
            ),
          );
          if ((picked == true) && mounted) _getPlacements();
        },
        splashColor: Colors.brown.withValues(alpha: 0.5),
      ),
    );
  }

  Widget materialPlace(int idx) {
    var mat0 = 0;
    for (var mat in _materialsId) {
      if (mat > 0) {
        mat0 = mat;
      }
    }

    return Ink(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: (_materialsImg[idx] == "")
              ? ExactAssetImage("assets/images/items/nothing.png")
              : ExactAssetImage(
                  "assets/images/materials/${_materialsImg[idx]}"),
          fit: BoxFit.contain,
        ),
      ),
      child: InkWell(
        onTap: () async {
          FlameAudio.play(
              'sfx/hammer_${(math.Random.secure().nextInt(3) + 1).toString()}.mp3');
          if (_blueprintId == 0) {
            showDialog(
              context: context,
              builder: (context) => CustomDialog(
                title: 'Error',
                description: "Please select a blueprint first",
                buttonText: "Okay",
                images: [],
                callback: () {},
              ),
            );
            return;
          }
          final picked = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => MaterialSelectPage(
                  blueprintId: _blueprintId, placement: idx, mat0: mat0),
            ),
          );
          if ((picked == true) && mounted) _getPlacements();
        },
        splashColor: Colors.brown.withValues(alpha: 0.5),
      ),
    );
  }

  Widget itemLogo() {
    return Ink(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: (_craftedItemImg == "")
              ? ExactAssetImage("assets/images/items/nothing.png")
              : ExactAssetImage("assets/images/items/$_craftedItemImg"),
          fit: BoxFit.contain,
        ),
      ),
      child: InkWell(
        onTap: () async {
          _craftItem();
        },
        splashColor: Colors.brown.withValues(alpha: 0.5),
      ),
    );
  }

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
        icon: Icon(
          Icons.menu,
          color: Colors.white,
        ),
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
              Icon(
                Icons.menu,
                color: Colors.white,
              ),
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
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 10,
                      height: 10,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  ///
  Widget build(BuildContext context) {
    //ignore: omit_local_variable_types
    int currentTabIndex = 0;
    final user = ref.watch(userProvider).valueOrNull ?? User.blank();

    /// Application top Bar
    final topBar = AppBar(
      leading: leadingIcon(context, user.details),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text(
        "Forge",
        style: Style.topBar,
      ),
      actions: <Widget>[
        PopupMenuButton<PopupMenuChoice>(
          iconColor: Colors.white,
          onSelected: (onSel) {
            choiceAction(context, onSel);
          },
          itemBuilder: (context) => <PopupMenuEntry<PopupMenuChoice>>[
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.refreshForge,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.autorenew,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Cleanup',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.showCoinSheet,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.monetization_on,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Get more coins',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
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

    /// What happens when clicking the Bottom Navbar
    onTapped(int index) {
      setState(() {
        currentTabIndex = index;
      });
      /* if index == 0 We are here: Forge */
      if (index == 1) {
        //Navigator.of(context).pop();
        context.replace('/research');
      }
    }

    final cleanButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(2),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: () async {
        _clearPlacements();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.autorenew, color: Color(0xffe6a04e)),
          Text(
            " Clean",
            style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    final craftButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(2),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: () async {
        _craftItem();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(RPGAwesome.forging, color: Color(0xffe6a04e)),
          Text(
            " Craft",
            style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    final watchAdButton = Padding(
      padding: EdgeInsets.all(0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding:
              EdgeInsets.only(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0),
          backgroundColor: GlobalConstants.appBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(width: 1, color: Colors.white),
        ),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.ondemand_video, color: Color(0xffe6a04e)),
            Text(
              " Watch ad",
              style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 16,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    ///
    Color itemColorRarity(String rarity) {
      if (rarity == "") {
        return Colors.white;
      }
      return colorRarity(int.tryParse(rarity) ?? 0);
    }

    Widget purchaseCoinsButton(int idx) {
      return Padding(
        padding: EdgeInsets.all(0),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding:
                EdgeInsets.only(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0),
            backgroundColor: GlobalConstants.appBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            side: BorderSide(width: 1, color: Colors.white),
          ),
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.ondemand_video, color: Color(0xffe6a04e)),
              Text(
                " 0.0",
                style: TextStyle(
                  color: Color(0xffe6a04e),
                  fontSize: 16,
                  fontFamily: 'Cormorant SC',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final coinSheet = Stack(
      children: <Widget>[
        Container(
          height: 170,
          padding: EdgeInsets.only(top: 0.0, left: 30.0, right: 30.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Color(0xcc222222)),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _showCoinSheet = !_showCoinSheet;
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Watch an ad to gain a few coins.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10),
                          watchAdButton,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(width: 1),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Coming soon",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10),
                          purchaseCoinsButton(0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.pop();
      },
      child: Scaffold(
        backgroundColor: GlobalConstants.appBg,
        appBar: topBar,
        //extendBodyBehindAppBar: true,
        body: LoadingOverlay(
        isLoading: _isLoading,
        opacity: 0.5,
        color: Colors.black,
        progressIndicator: CircularProgressIndicator(
          backgroundColor: Colors.black,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xffe6a04e)),
        ),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/blacksmith_hammer.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _showCoinSheet ? coinSheet : SizedBox(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Text(""),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(7.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.black,
                            ),
                            child: Text(
                              "No bonus",
                              style: TextStyle(
                                color: GlobalConstants.appFg,
                                fontSize: 16.0,
                                backgroundColor: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Card(
                            color: Colors.transparent,
                            child: SizedBox(
                                child: blueprintPlace(),
                                width: 110,
                                height: 110),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: cleanButton,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(""),
                        ),
                      ],
                    ),
                    Card(
                      color: Color.fromARGB(140, 0, 0, 0),
                      child: Text(
                        (_blueprintName == "")
                            ? " Select Blueprint "
                            : _blueprintName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Cormorant SC',
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Color.fromARGB(255, 0, 0, 0))
                          ],
                        ),
                      ),
                    ),
                    Card(
                      color: Color.fromARGB(140, 0, 0, 0),
                      child: SizedBox(
                          child: Icon(
                            Icons.add,
                            color: GlobalConstants.appFg,
                          ),
                          width: 30,
                          height: 30),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 4,
                          child: Card(
                            color: Colors.transparent,
                            child: SizedBox(
                                child: materialPlace(0),
                                width: 110,
                                height: 110),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Card(
                            color: Colors.transparent,
                            child: SizedBox(
                                child: materialPlace(1),
                                width: 110,
                                height: 110),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Card(
                            color: Colors.transparent,
                            child: SizedBox(
                                child: materialPlace(2),
                                width: 110,
                                height: 110),
                          ),
                        ),
                      ],
                    ),
                    Card(
                      color: Color.fromARGB(140, 0, 0, 0),
                      child: Text(
                        " Materials ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Cormorant SC',
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Color.fromARGB(255, 0, 0, 0))
                          ],
                        ),
                      ),
                    ),
                    Card(
                      color: Color.fromARGB(140, 0, 0, 0),
                      child: SizedBox(
                          child: Icon(
                            Icons.arrow_downward,
                            color: GlobalConstants.appFg,
                          ),
                          width: 30,
                          height: 30),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Text(""),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(7.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.black,
                            ),
                            child: Text(
                              "${user.details.costs.crafting.toString()} Coins",
                              style: TextStyle(
                                color: GlobalConstants.appFg,
                                fontSize: 16.0,
                                backgroundColor: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Card(
                            color: Colors.transparent,
                            child: SizedBox(
                                child: itemLogo(), width: 110, height: 110),
                          ),
                        ),
                        Expanded(flex: 3, child: craftButton),
                        Expanded(
                          flex: 1,
                          child: Text(""),
                        ),
                      ],
                    ),
                    Card(
                      color: Color.fromARGB(140, 0, 0, 0),
                      child: Text(
                        (_craftedItemName == "") ? " Item " : _craftedItemName,
                        style: TextStyle(
                          color: itemColorRarity(_craftedItemRarity),
                          fontSize: 18,
                          fontFamily: 'Cormorant SC',
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Color.fromARGB(255, 0, 0, 0))
                          ],
                        ),
                      ),
                    ),
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
          selectedItemColor: Color(0xfffeb53b),
          selectedLabelStyle: TextStyle(fontSize: 14),
          unselectedItemColor: Colors.white,
          unselectedLabelStyle: TextStyle(fontSize: 14),
          items: [
            BottomNavigationBarItem(
              icon: Icon(RPGAwesome.forging, color: Colors.white),
              label: 'Forge',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.import_contacts, color: Colors.white),
              label: 'Research',
            ),
          ],
        ),
      ),
    );
  }

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
      err.show(context);
      return;
    } catch (err) {
      debugPrint('_craftItem unexpected error: $err');
      return;
    }

    if (result.item.nr > 0) {
      _clearPlacements();
      setState(() {
        _craftedItemImg = result.item.img;
        _craftedItemName = result.item.name;
        _craftedItemRarity = result.item.rarity.toString();
      });
      FlameAudio.play('sfx/anvil_1.mp3');
    }
    ref.invalidate(userProvider);
  }
}
