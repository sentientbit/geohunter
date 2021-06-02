///
import 'dart:ui';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
//import 'package:qrscan/qrscan.dart' as scanner;
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qrcode_flutter/qrcode_flutter.dart';

//import 'package:logger/logger.dart';

///
import '../../app_localizations.dart';
import '../../models/friends.dart';
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../providers/stream_userdata.dart';
import '../../screens/friendship/showqr.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';
import '../../widgets/friends_summary.dart';
import '../../widgets/network_status_message.dart';

final _debouncer = Debouncer(milliseconds: 500);

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
  //final Logger log = Logger(
  //    printer: PrettyPrinter(
  //        colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  final _userdata = getIt.get<StreamUserData>();

  /// Curent loggedin user
  User _user = User.blank();

  /// Make sure back button is pressed twice
  bool ifPop = false;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _friends = [];
  bool _isLoading = true;
  final _apiProvider = ApiProvider();

  String _scanBarcode = '';
  bool qrFound = false;

  Map<int, dynamic> ravens = {};

  final QRCaptureController controllerQr = QRCaptureController();

  // Future<void> scanQR() async {
  //   String barcodeScanRes;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //         '#ff6666', 'Cancel', true, ScanMode.QR);
  //   } on Exception catch (err) {
  //     barcodeScanRes = '';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _scanBarcode = barcodeScanRes;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _loadFriends();
    controllerQr.onCapture(iFoundSomething);
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
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed(GlobalConstants.backButtonPage);
    }
    return true;
  }

  /// When a QR Code is found
  void iFoundSomething(String data) {
    if (qrFound == false) {
      //print('--- found ---');
      controllerQr.pause();
      FlameAudio.audioCache.play('sfx/stick_1.mp3');
      //print('--- pause ---');
      setState(() {
        _scanBarcode = data;
        qrFound = true;
      });
    }
  }

  Future _loadFriends() async {
    _friends.clear();
    try {
      final response = await _apiProvider.get('/friends');
      final friends = [];

      var privacy = 0;
      var lat = 51.5;
      var lng = 0.0;
      if (response["success"] == true) {
        for (dynamic elem in response["friends"]) {
          privacy = 0;
          if (elem.containsKey("privacy")) {
            privacy = int.tryParse(elem["privacy"].toString()) ?? 0;
            lat = double.parse(elem["lat"].toString());
            lng = double.parse(elem["lng"].toString());
          }
          friends.add(
            Friend(
              id: (int.tryParse(elem["id"].toString()) ?? 0),
              sex: elem["sex"],
              username: elem["username"],
              status: elem["status"],
              locationPrivacy: privacy,
              xp: (int.tryParse(elem["xp"].toString()) ?? 0),
              thumbnail: elem["thumbnail"],
              isReq: elem["is_req"].toString(),
              lat: lat,
              lng: lng,
            ),
          );
        }
        if (response.containsKey("coins")) {
          // update local data
          _user.details.coins =
              double.tryParse(response["coins"].toString()) ?? 0.0;
          _user.details.xp = response["xp"];
          _user.details.unread = response["unread"];
          _user.details.attack = response["attack"];
          _user.details.defense = response["defense"];
          // log.d(_user.details.unread);
          ravens = _user.details.unread.asMap();

          // update global data
          _userdata.updateUserData(
            _user.details.coins,
            0,
            response["guild"]["id"],
            _user.details.xp,
            _user.details.unread,
            _user.details.attack,
            _user.details.defense,
          );
        }
      }
      setState(() {
        _friends.addAll(friends.toList());
        _isLoading = false;
      });
    } on DioError catch (err) {
      if (err.response != null) {
        print(err.response?.data["message"]);
      } else {
        print(err.response?.statusCode);
        print(err.message);
      }
      setState(() {
        _isLoading = false;
      });
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
    controllerQr.resume();
    //print('--- resume ---');
    setState(() {
      _scanBarcode = "";
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
                        child: QRCaptureView(
                          controller: controllerQr,
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
        onPressed: () => Navigator.of(context).pop(),
      ),
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
    );
  }

  Future afterScan() async {
    //print('--- afterScan ---');
    if (_scanBarcode.length <= 0) {
      //print('f');
      return;
    }
    dynamic response;
    try {
      if (_scanBarcode.length > 0) {
        response = await _apiProvider
            .put('/friends?token=${_scanBarcode.split('/')[5]}', {});
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
            images: [],
            callback: () {},
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: "Error",
            description: err.response?.data["message"],
            buttonText: "Okay",
            images: [],
            callback: () {},
          ),
        );
      }
      _scanBarcode = "";
      return;
    }
    _scanBarcode = "";
    if (response.containsKey("success")) {
      if (response["success"] == true) {
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
