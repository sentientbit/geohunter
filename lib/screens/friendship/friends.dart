///
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

///
import '../../app_localizations.dart';
import '../../models/app_error.dart';
import '../../models/user.dart';
import '../../providers/friends_provider.dart';
import '../../providers/friends_repository.dart';
import '../../providers/user_provider.dart';
import '../../screens/friendship/showqr.dart';
import '../../shared/app_theme.dart';
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
  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _scanBarcode;
  bool qrFound = false;

  MobileScannerController? controllerQr;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget camButton() {
    return kStoneButton(
      onTap: () {
        afterScan();
        Navigator.of(context).pop();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.done, color: kGold),
          const SizedBox(width: 6),
          Text(
            "Okay",
            style: const TextStyle(
              color: kGold,
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
    // Dispose any previous controller before creating a fresh one.
    controllerQr?.dispose();
    controllerQr = MobileScannerController();
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
                    mainAxisSize: MainAxisSize.min,
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
                      camButton(),
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
    ).then((_) {
      // Release camera resources when the scanner dialog is dismissed.
      controllerQr?.dispose();
      controllerQr = null;
    });
  }

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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    final friendsState = ref.watch(friendsProvider);
    final user = ref.watch(userProvider).valueOrNull ?? User.blank();

    final friends = friendsState.valueOrNull?.friends ?? [];
    // Map {index: userId} of senders with unread messages — used for raven badge
    final ravens = user.details.unread.asMap();

    /// Application top Bar
    final topBar = AppBar(
      leading: leadingIcon(context, user.details),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text("Friends", style: Style.topBar),
      actions: <Widget>[
        PopupMenuButton<PopupMenuChoice>(
          iconColor: Colors.white,
          onSelected: (choice) {
            if (choice == PopupMenuChoice.scan) {
              showScan(context);
            } else if (choice == PopupMenuChoice.showQR) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShowQRPage(),
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
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ],
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.pop();
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
            if (connectivity.isEmpty ||
                connectivity.contains(ConnectivityResult.none)) {
              return Stack(
                children: <Widget>[
                  child,
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0),
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
                child: friendsState.isLoading
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
                          SizedBox(height: 12),
                          Expanded(
                            child: CustomScrollView(
                              physics: const ClampingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: false,
                              slivers: <Widget>[
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => FriendsSummary(
                                        friends[index],
                                        ravens.containsValue(
                                            friends[index].id),
                                      ),
                                      childCount: friends.length,
                                    ),
                                  ),
                                ),
                              ],
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
    if (_scanBarcode == null) return;
    try {
      await ref.read(friendsRepositoryProvider).addFriend(_scanBarcode!);
      // Refresh friends list and user state (unread count may change)
      ref.invalidate(friendsProvider);
      ref.invalidate(userProvider);
    } on AppError catch (err) {
      ref.invalidate(friendsProvider);
      _scanBarcode = null;
      if (!mounted) return;
      err.show(context);
      return;
    } catch (err) {
      debugPrint('afterScan unexpected error: $err');
      _scanBarcode = null;
      return;
    }

    _scanBarcode = null;
    if (!mounted) return;
    // The PUT succeeded — _unwrap already validated success:true
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: AppLocalizations.of(context)!.translate('congrats'),
        description: "Friend request sent!",
        buttonText: "Okay",
        images: [],
        callback: () {},
      ),
    );
  }
}
