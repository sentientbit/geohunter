///
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

//import 'package:logger/logger.dart';

///
import '../../app_localizations.dart';
import '../../models/app_error.dart';
import '../../models/friends.dart';
import '../../models/player_stats.dart';
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../screens/friendship/showqr.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';
import '../../widgets/friends_summary.dart';
import '../../widgets/network_status_message.dart';

///
enum PopupMenuChoice {
  ///
  scan,

  ///
  showQR
}

///
class FriendsPage extends ConsumerStatefulWidget {
  ///
  final String name = 'friends';
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends ConsumerState<FriendsPage> {
  //final Logger log = Logger(
  //    printer: PrettyPrinter(
  //        colors: true, printEmojis: true, printTime: true, lineLength: 80));

  /// Curent loggedin user
  User _user = User.blank();

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _friends = [];
  bool _isLoading = true;
  final _apiProvider = ApiProvider();

  String? _scanBarcode = null;
  bool qrFound = false;

  MobileScannerController? controllerQr = null;

  Map<int, dynamic> ravens = {};

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///
  Future _loadFriends() async {
    /// populate initial data from cookies
    _user = await ApiProvider().getStoredUser();
    _friends.clear();
    try {
      final response = await _apiProvider.get('/friends');
      final friends = [];

      var privacy = 0;
      var lat = 51.5;
      var lng = 0.0;
      for (dynamic elem in response["friends"]) {
        privacy = 0;
        if (elem.containsKey("privacy")) {
          privacy = int.tryParse(elem["privacy"].toString()) ?? 0;
          lat = double.tryParse(elem["lat"].toString()) ?? 51.5;
          lng = double.tryParse(elem["lng"].toString()) ?? 0.0;
        }
        friends.add(
          Friend(
            id: (int.tryParse(elem["id"].toString()) ?? 0),
            sex: elem["sex"].toString(),
            username: elem["username"].toString(),
            status: elem["status"]?.toString() ?? "",
            locationPrivacy: privacy,
            xp: (int.tryParse(elem["xp"].toString()) ?? 0),
            thumbnail: elem["thumbnail"].toString(),
            isReq: elem["is_req"].toString(),
            lat: lat,
            lng: lng,
          ),
        );
      }

      // update local data
      _user.details.coins =
          double.tryParse(response["coins"].toString()) ?? 0.0;
      _user.details.guildId = response["guild"]["id"].toString();
      _user.details.mining = response["mining"];
      _user.details.xp = response["xp"];
      _user.details.unread = ((response["unread"] ?? []) as List).map((e) => (e as num).toInt()).toList();
      _user.details.attack = StatRange.fromList((response["attack"] ?? []) as List);
      _user.details.defense = StatRange.fromList((response["defense"] ?? []) as List);
      _user.details.daily = response["daily"];
      if (response.containsKey("settings")) {
        _user.details.settings = PlayerSettings.fromList((response["settings"] ?? [0, 0, 0]) as List);
      }
      _user.details.costs = ActionCosts.fromList((response["costs"] ?? [0.1, 0.1, 0.1]) as List);
      // log.d(_user.details.unread);
      ravens = _user.details.unread.asMap();

      ref.invalidate(userProvider);
      setState(() {
        _friends.addAll(friends.toList());
        _isLoading = false;
      });
    } on AppError catch (err) {
      debugPrint(err.toString());
      if (mounted) setState(() => _isLoading = false);
    } catch (err) {
      debugPrint('_loadFriends unexpected error: $err');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget camButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: () {
        afterScan();
        Navigator.of(context).pop();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.done, color: Color(0xffe6a04e)),
          Text(
            " Okay",
            style: TextStyle(
              color: Color(0xffe6a04e),
              fontSize: 16,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// When pressing Start Scan
  void showScan(BuildContext context) async {
    MobileScannerController controllerQr = MobileScannerController(
        //torchEnabled: true,
        // formats: [BarcodeFormat.qrCode]
        // facing: CameraFacing.front,
        );
    // controllerQr auto-starts when passed to MobileScanner widget (mobile_scanner 3.x+)
    //print('--- resume ---');
    setState(() {
      _scanBarcode = null;
      qrFound = false;
    });
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlobalConstants.padding),
        ),
        //elevation: 0.0,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 0,
                ),
                child: Container(
                  padding: EdgeInsets.only(
                    top: GlobalConstants.avatarRadius + GlobalConstants.padding,
                    bottom: GlobalConstants.padding,
                    left: GlobalConstants.padding,
                    right: GlobalConstants.padding,
                  ),
                  margin: EdgeInsets.only(top: GlobalConstants.avatarRadius),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.rectangle,
                    borderRadius:
                        BorderRadius.circular(GlobalConstants.padding),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // To make the card compact
                    children: <Widget>[
                      Container(
                        width: 300,
                        height: 300,
                        child: MobileScanner(
                          controller: controllerQr,
                          fit: BoxFit.contain,
                          onDetect: (capture) {
                            final rawValue = capture.barcodes.isNotEmpty
                                ? capture.barcodes.first.rawValue
                                : null;
                            if (rawValue == null) {
                              _scanBarcode = null;
                              qrFound = false;
                            } else {
                              _scanBarcode = rawValue;
                              qrFound = true;
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: <Widget>[
                          camButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: GlobalConstants.padding,
              right: GlobalConstants.padding,
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: GlobalConstants.avatarRadius,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget leadingIcon(BuildContext context) {
    //print(" ${_user.details.daily}");
    if (!GlobalConstants.menuHasNotification(_user.details)) {
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

  Widget build(BuildContext context) {
    // final deviceSize = MediaQuery.of(context).size;

    /// Application top Bar
    final topBar = AppBar(
      leading: leadingIcon(context),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text("Friends", style: Style.topBar),
      actions: <Widget>[
        PopupMenuButton<PopupMenuChoice>(
          onSelected: (choice) {
            if (choice == PopupMenuChoice.scan) {
              showScan(context);
            } else if (choice == PopupMenuChoice.showQR) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ShowQRPage(latitude: 51.5, longitude: 0.0),
                ),
              );
            }
          },
          itemBuilder: (context) => <PopupMenuEntry<PopupMenuChoice>>[
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.scan,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.camera_alt,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Scan',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.showQR,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.blur_linear,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Show QR',
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
      ],
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/poi-map');
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: topBar,
        extendBodyBehindAppBar: true,
      body: OfflineBuilder(
        connectivityBuilder: (
          context,
          connectivity,
          child,
        ) {
          if (connectivity.isEmpty || connectivity.contains(ConnectivityResult.none)) {
            return Stack(
              children: <Widget>[
                child,
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0),
                    // child: child,
                    child: NetworkStatusMessage(),
                  ),
                )
              ],
            );
          } else {
            return child;
          }
        },
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/starry_night.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(top: 68.0),
              child: (_isLoading)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Image.asset(
                            'assets/images/compass.gif',
                            width: 150,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        SizedBox(
                          height: 12,
                        ),
                        Expanded(
                          child: Container(
                            child: CustomScrollView(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: false,
                              slivers: <Widget>[
                                SliverPadding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 1.0),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => FriendsSummary(
                                        _friends[index],
                                        ravens
                                            .containsValue(_friends[index].id),
                                      ),
                                      childCount: _friends.length,
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
          ],
        ),
      ),
        key: _scaffoldKey,
        drawer: DrawerPage(),
      ),
    );
  }

  Future afterScan() async {
    //print('--- afterScan ---');
    if (_scanBarcode == null) {
      //print('f');
      return;
    }
    dynamic response;
    try {
      response = await _apiProvider
          .put('/friends/${_scanBarcode?.split('/')[5]}', {});
      _loadFriends();
    } on AppError catch (err) {
      if (!mounted) return;
      _loadFriends();
      err.show(context);
      _scanBarcode = null;
      return;
    } catch (err) {
      debugPrint('afterScan unexpected error: $err');
      _scanBarcode = null;
      return;
    }
    _scanBarcode = null;
    if (response is Map && response.containsKey("success")) {
      if (response["success"] == true) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: AppLocalizations.of(context)!.translate('congrats'),
            description: response["message"],
            buttonText: "Okay",
            images: [],
            callback: () {},
          ),
        );
      }
    }
  }
}
