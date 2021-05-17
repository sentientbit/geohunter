///
import 'dart:ui';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
//import 'package:qrscan/qrscan.dart' as scanner;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_offline/flutter_offline.dart';

///
import '../../app_localizations.dart';
import '../../models/friends.dart';
import '../../providers/api_provider.dart';
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
class FriendsPage extends StatefulWidget {
  ///
  final String name = 'friends';
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  /// Make sure back button is pressed twice
  bool ifPop = false;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _friends = [];
  bool _isLoading = true;
  final _apiProvider = ApiProvider();

  String _scanBarcode = '';

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
    } on Exception catch (err) {
      barcodeScanRes = '';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future _loadFriends() async {
    setState(() {
      _isLoading = true;
    });
    _friends.clear();
    try {
      final response = await _apiProvider.get('/friends');
      final friends = [];

      var privacy = 0;
      var lat = 0.0;
      var lng = 0.0;
      if (response["success"] == true) {
        for (dynamic elem in response["friends"]) {
          privacy = 0;
          if (elem.containsKey("privacy")) {
            privacy = int.tryParse(elem["privacy"].toString()) ?? 0;
            lat = double.parse(elem["lat"].toString()) ?? 0.0;
            lng = double.parse(elem["lng"].toString()) ?? 0.0;
          }
          friends.add(
            Friend(
              id: elem["id"],
              sex: elem["sex"],
              username: elem["username"],
              status: elem["status"],
              locationPrivacy: privacy,
              xp: elem["xp"],
              thumbnail: elem["thumbnail"],
              isReq: elem["is_req"].toString(),
              lat: lat,
              lng: lng,
            ),
          );
        }
      }
      setState(() {
        _friends.addAll(friends.toList());
        _isLoading = false;
      });
    } on DioError catch (err) {
      if (err.response != null) {
        print(err.response.data["message"]);
      } else {
        print(err.request);
        print(err.message);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFriends();
    BackButtonInterceptor.add(myInterceptor,
        name: widget.name, context: context);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  // ignore: avoid_positional_boolean_parameters
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (stopDefaultButtonEvent) return false;
    if (ifPop) {
      return false;
    } else {
      setState(() => ifPop = true);
      if (_scaffoldKey != null) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(GlobalConstants.backButtonPage);
      }
    }
    return true;
  }

  void choiceAction(PopupMenuChoice choice) {
    if (choice == PopupMenuChoice.scan) {
      _scan();
    } else if (choice == PopupMenuChoice.showQR) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShowQRPage(latitude: 51.5, longitude: 0.0),
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    // final deviceSize = MediaQuery.of(context).size;

    /// Application top Bar
    final topBar = AppBar(
      leading: IconButton(
        color: GlobalConstants.appFg,
        icon: Icon(
          Icons.menu,
          // size: 32,
        ),
        onPressed: () => _scaffoldKey != null
            ? _scaffoldKey.currentState.openDrawer()
            : Navigator.of(context).pop(),
      ),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text("Friends", style: Style.topBar),
      actions: <Widget>[
        PopupMenuButton<PopupMenuChoice>(
          onSelected: choiceAction,
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

    return Scaffold(
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
          if (connectivity == ConnectivityResult.none) {
            return Stack(
              children: <Widget>[
                child,
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0),
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
                                      (context, index) =>
                                          FriendsSummary(_friends[index]),
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
    );
  }

  Future _scan() async {
    var response;
    try {
      await scanQR();
      if (_scanBarcode.length > 0) {
        final r = await _apiProvider
            .put('/friends?token=${_scanBarcode.split('/')[5]}', {});
        response = r;
        _loadFriends();
      }
    } on DioError catch (err) {
      _loadFriends();
      if (err.runtimeType == RangeError) {
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: "Error",
            description: "This is not a valid QR Code",
            buttonText: "Okay",
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: "Error",
            description: err.response.data["message"],
            buttonText: "Okay",
          ),
        );
      }
    }
    if (response.containsKey("success")) {
      if (response["success"] == true) {
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: AppLocalizations.of(context).translate('congrats'),
            description: response["message"],
            buttonText: "Okay",
          ),
        );
      }
    }
  }
}
