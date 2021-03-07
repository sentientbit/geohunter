///
import 'dart:ui';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:flutter_offline/flutter_offline.dart';

///
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../screens/friendship/showqr.dart';
import '../../models/friends.dart';
import '../../providers/api_provider.dart';
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
  // bool _isQrGenerated = false;
  String _qrEndpoint = "";
  final _apiProvider = ApiProvider();

  Future _loadFriends() async {
    setState(() {
      _isLoading = true;
    });
    _friends.clear();
    try {
      final qrFriendshipResponse = await _apiProvider.post('/friends', {});
      final response = await _apiProvider.get('/friends');
      final friends = [];

      //print(response);

      if (response["success"] == true) {
        for (dynamic elem in response["friends"]) {
          friends.add(Friend(
            id: elem["id"],
            sex: elem["sex"],
            username: elem["username"],
            xp: elem["xp"],
            thumbnail: elem["thumbnail"],
            isReq: elem["is_req"].toString(),
          ));
        }
      }
      setState(() {
        _friends.addAll(friends.toList());
        _qrEndpoint = qrFriendshipResponse["friendship_qr"];
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
          builder: (context) => ShowQRPage(qr: _qrEndpoint),
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
            return Stack(children: <Widget>[
              child,
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                    color: Colors.black.withOpacity(0),
                    // child: child,
                    child: NetworkStatusMessage()),
              )
            ]);
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
    try {
      final barcode = await scanner.scan();

      await _apiProvider.put('/friends?token=${barcode.split('/')[5]}', {});
      _loadFriends();
    } on DioError catch (err) {
      _loadFriends();
      if (err.runtimeType == RangeError) {
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: "Error",
            description: "This is not a valid qr ",
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
    // setState(() => qrText = barcode);
  }
}
