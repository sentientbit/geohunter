///
import 'dart:async';
import 'dart:ui';
import 'package:encrypt/encrypt.dart' as enq;
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:loading_overlay/loading_overlay.dart';

//import 'package:logger/logger.dart';

///
import '../models/app_error.dart';
import '../models/mine.dart';
import '../models/secret.dart';
import '../models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import '../providers/location_provider.dart';
import '../screens/map/map_explore.dart' show PoiMap;
import '../shared/constants.dart';
import '../text_style.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/drawer.dart';
import '../widgets/network_status_message.dart';
import '../widgets/places_summary.dart';

///
enum PopupMenuChoice {
  ///
  noFilter,

  ///
  filterMetal,

  ///
  filterWood,

  ///
  filterLeather,

  ///
  showCoinSheet
}

///
class BodyWidget extends StatelessWidget {
  final Color color;

  BodyWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      color: color,
      alignment: Alignment.center,
    );
  }
}

///
class PlacesPage extends ConsumerStatefulWidget {
  ///
  final String name = 'Places';

  ///
  final int mineTypeFilter;

  ///
  PlacesPage({
    Key? key,
    required this.mineTypeFilter,
  }) : super(key: key);

  @override
  _PlacesState createState() => _PlacesState();
}

class _PlacesState extends ConsumerState<PlacesPage> {
  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showCoinSheet = false;

  /// Curent loggedin user
  User _user = User.blank();

  LtLn _userLocation = LtLn(51.5, 0.0);

  int _mineTypeFilter = 0;

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  Mine mine = Mine.blank();
  final _places = [];
  final _recommandations = [];
  bool _isLoading = false;

  int mineId = 0;
  final _apiProvider = ApiProvider();

  @override
  void initState() {
    super.initState();
    _mineTypeFilter = widget.mineTypeFilter;
    _getUserDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void choiceAction(BuildContext context, PopupMenuChoice choice) async {
    if (choice == PopupMenuChoice.noFilter) {
      _mineTypeFilter = 0;
      loadPlaces();
    } else if (choice == PopupMenuChoice.filterMetal) {
      _mineTypeFilter = 1;
      loadPlaces();
    } else if (choice == PopupMenuChoice.filterWood) {
      _mineTypeFilter = 2;
      loadPlaces();
    } else if (choice == PopupMenuChoice.filterLeather) {
      _mineTypeFilter = 3;
      loadPlaces();
    } else if (choice == PopupMenuChoice.showCoinSheet) {
      setState(() {
        _showCoinSheet = !_showCoinSheet;
      });
    }
  }

  Widget _makeCard(BuildContext context, int index) {
    if (_recommandations.isEmpty) {
      return SizedBox(width: 1);
    }
    return Card(
      color: Color.fromRGBO(19, 21, 20, 0.8),
      elevation: 8.0,
      margin: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 6.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          //color: Color.fromRGBO(19, 21, 20, 0.7),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 33.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: _makeListTile(context, index),
      ),
    );
  }

  Widget _makeListTile(BuildContext context, int index) {
    var netImg = Image(
      image: AssetImage(
          'assets/images/markers/${_recommandations[index].properties.ico.toString()}.png'),
      height: 76.0,
      width: 76.0,
    );

    final showDistanceIn = _recommandations[index].distanceToPoint > 1000
        ? '${(_recommandations[index].distanceToPoint / 1000).toStringAsFixed(2)}km'
        : '${_recommandations[index].distanceToPoint.toStringAsFixed(2)}m';

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      leading: Container(
        padding: EdgeInsets.only(right: 12.0),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              width: 1.0,
              color: Color(0xff333333),
            ),
          ),
        ),
        child: Stack(
          children: <Widget>[
            netImg,
            Positioned(
              right: 0.0,
              bottom: 0.0,
              child: Text(
                '123',
              ),
            ),
          ],
        ),
      ),
      title: Text(
        _recommandations[index].properties.comment,
        style: TextStyle(
          color: Color(0xffe6a04e),
          fontFamily: "Cormorant SC",
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10.0),
          Text(
            "${_recommandations[index].geometry.coordinates[1].toString()} ${_recommandations[index].geometry.coordinates[0].toString()}",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10.0),
          Text(
            "Distance $showDistanceIn",
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
      trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoiMap(
              goToRemoteLocation: true,
              latitude: _recommandations[index].geometry.coordinates[1],
              longitude: _recommandations[index].geometry.coordinates[0],
            ),
          ),
        );
      },
    );
  }

  Widget leadingIcon(BuildContext context) {
    // print(" ${_user.details.daily}");
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
    // Keep _userLocation in sync with GPS via locationProvider
    ref.listen<AsyncValue<LtLn>>(locationProvider, (_, next) {
      next.whenData(_updateUserLocation);
    });

    /// Application top Bar
    final topBar = AppBar(
      leading: leadingIcon(context),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text(
        "Places",
        style: Style.topBar,
      ),
      actions: <Widget>[
        PopupMenuButton<PopupMenuChoice>(
          onSelected: (onSel) {
            choiceAction(context, onSel);
          },
          itemBuilder: (context) => <PopupMenuEntry<PopupMenuChoice>>[
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.noFilter,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.all_inclusive,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'All',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.filterMetal,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.terrain,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Metal',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.filterWood,
              child: Row(
                children: <Widget>[
                  Icon(
                    // Icons https://api.flutter.dev/flutter/material/Icons-class.html
                    Icons.nature,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Wood',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.filterLeather,
              child: Row(
                children: <Widget>[
                  Icon(
                    // Icons https://api.flutter.dev/flutter/material/Icons-class.html
                    Icons.category,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Leather',
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
      ],
    );

    final watchAdButton = Padding(
      padding: EdgeInsets.all(0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
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

    Widget purchaseCoinsButton(int idx) {
      return Padding(
        padding: EdgeInsets.all(0),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
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
              Icon(Icons.shopping_cart, color: Color(0xffe6a04e)),
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

    final trainingGrounds = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: () {
        getTutorialBattleGround();
      },
      child: Text(
        "Battle Tutorial",
        style: TextStyle(
            color: Color(0xffe6a04e),
            fontSize: 18,
            fontFamily: 'Cormorant SC',
            fontWeight: FontWeight.bold),
      ),
    );

    // final deviceSize = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/poi-map');
      },
      child: Scaffold(
        backgroundColor: GlobalConstants.appBg,
        //resizeToAvoidBottomPadding: false,
        appBar: topBar,
      //extendBodyBehindAppBar: true,
      body: OfflineBuilder(
        connectivityBuilder: (
          context,
          connectivity,
          child,
        ) {
          if (connectivity.isEmpty || connectivity.contains(ConnectivityResult.none)) {
            return Stack(children: <Widget>[
              child,
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                    color: Colors.black.withValues(alpha: 0),
                    // child: child,
                    child: NetworkStatusMessage()),
              )
            ]);
          } else {
            return child;
          }
        },
        child: LoadingOverlay(
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
                    image: AssetImage('assets/images/moon_light.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  _showCoinSheet ? coinSheet : SizedBox(height: 1),
                  Expanded(
                    child: Container(
                      child: CustomScrollView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: false,
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    (_recommandations.length > 0)
                                        ? 'Nearby recommendations'
                                        : 'No nearby recommendations',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Color(0xffe6a04e),
                                      fontSize: 24,
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
                                for (var i = 0;
                                    i <
                                        ((_recommandations.length > 5)
                                            ? 5
                                            : _recommandations.length);
                                    i++)
                                  _makeCard(context, i),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Visited Places',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Color(0xffe6a04e),
                                      fontSize: 24,
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
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0),
                            // https://medium.com/swlh/flutter-slivers-and-customscrollview-1aaadf96e35a
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Stack(
                                  children: [
                                    PlanetSummary(_places[index]),
                                    Positioned(
                                      bottom: 20,
                                      right: 45,
                                      child: GestureDetector(
                                        onTap: () => {
                                          if (remoteClaimTextWidget(
                                              _places[index])["status"])
                                            {
                                              setState(() {
                                                _isLoading = true;
                                                mine = _places[index];
                                              }),
                                              _remoteMine()
                                            }
                                        },
                                        child: remoteClaimTextWidget(
                                            _places[index])["payload"],
                                      ),
                                    ),
                                  ],
                                ),
                                childCount: _places.length,
                              ),
                            ),
                          ),
                          if (_places.length == 0)
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        trainingGrounds,
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
        key: _scaffoldKey,
        drawer: DrawerPage(),
      ),
    );
  }

  Future loadPlaces() async {
    //print(' --- log. loadPlaces() ---');
    //print(_userLocation.latitude);
    //print(_userLocation.longitude);
    String url;
    if (_userLocation.latitude == 51.5 && _userLocation.longitude == 0.0) {
      url = '/places/$_mineTypeFilter';
    } else {
      url =
          '/places/$_mineTypeFilter/${_userLocation.latitude}/${_userLocation.longitude}';
    }
    dynamic response;
    try {
      response = await _apiProvider.get(url);
    } on Exception catch (_) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description: 'The place is nowhere to be seen',
          buttonText: "Okay",
          images: [],
          callback: () {},
        ),
      );
      return;
    }

    var tmp = <Mine>[];
    var places = <dynamic>[];

    if (response is Map && response.containsKey("success")) {
      if (response["success"] == true) {
        if (response.containsKey("places")) {
          response["places"].forEach(
            (elem) => places.add(Mine.fromJson(elem, 1, _userLocation)),
          );
        }

        if (response.containsKey("recommandations")) {
          if (response["recommandations"].isNotEmpty) {
            response["recommandations"].forEach((elem) {
              tmp.add(
                Mine.fromJson(elem, 1, _userLocation),
              );
              tmp.sort(
                (a, b) => a.distanceToPoint.compareTo(b.distanceToPoint),
              );
            });
          }
        }
      }
    }

    setState(() {
      _places.clear();
      _recommandations.clear();
      _isLoading = false;
      _places.addAll(places.toList());
      _recommandations.addAll(tmp.toList());
    });
  }

  Future _remoteMine() async {
    //ignore: omit_local_variable_types
    List<Image> imagesArr = [];
    _getReward(mine.id, "", 0).then((mineResponse) {
      if (mineResponse == null || mineResponse["success"] != true) {
        // Already showed message, just return
        return;
      }

      // Image.network("https://${GlobalConstants.apiHostUrl}/img/items/${value['img']}"),
      if (mineResponse["items"].isNotEmpty) {
        for (dynamic value in mineResponse["items"]) {
          if (value.containsKey("img") && value["img"] != "") {
            mine.addItem(value);
            imagesArr.add(
              Image.asset("assets/images/items/${value['img']}"),
            );
          }
        }
      }

      for (dynamic value in mineResponse["materials"]) {
        if (value.containsKey("img") && value["img"] != "") {
          mine.addMaterial(value);
          imagesArr.add(
            Image.asset("assets/images/materials/${value['img']}"),
          );
        }
      }

      for (dynamic value in mineResponse["blueprints"]) {
        if (value.containsKey("img") && value["img"] != "") {
          mine.addBlueprint(value);
          imagesArr.add(
            Image.asset("assets/images/blueprints/${value['img']}"),
          );
        }
      }

      if (mineResponse.containsKey("coins")) {
        //print('Treasury is now ${mineResponse["coins"]}');
        _user.details.coins =
            double.tryParse(mineResponse["coins"].toString()) ?? 0.0;
      }

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: "Congrats",
          description: 'You mined succesfully Point ${mine.id}',
          buttonText: "Okay",
          images: imagesArr,
          callback: () {
            loadPlaces();
          },
        ),
      );
    });
  }

  Future _getReward(int mineId, String admobType, int admobAmount) async {
    final plainText =
        '{"mine_id":$mineId,"type":"$admobType","amount":$admobAmount}';
    final secret = await SecretLoader(secretPath: "assets/secrets.json").load();
    final key = enq.Key.fromBase64(secret.enqKey);

    /// iv doesn't necessarily have to be SECRET (it's just a salt),
    /// but it MUST be cryptographically random AND different EACH TIME
    /// you begin a round of AES encryption
    final rnd = enq.IV.fromSecureRandom(32);

    final rndstr = rnd.base64;
    final ivstr = rndstr
        .replaceAll('+', 'p')
        .replaceAll('=', 'e')
        .replaceAll('/', 's')
        .substring(0, 16);
    final iv = enq.IV.fromUtf8(ivstr);

    final encrypter = enq.Encrypter(enq.AES(key, mode: enq.AESMode.cbc));
    final encryptedpay = encrypter.encrypt(plainText, iv: iv);
    final enc = encryptedpay.base64;
    //log.d(plainText);
    //print(ivstr);
    //print(enc);

    dynamic response;
    try {
      response = await _apiProvider
          .get("/mine?mine_id=$mineId&enc=${Uri.encodeComponent(ivstr + enc)}");
    } on AppError catch (err) {
      if (mounted) err.show(context);
      if (mounted) setState(() => _isLoading = false);
      return response;
    } catch (err) {
      debugPrint('_getReward unexpected error: $err');
      if (mounted) setState(() => _isLoading = false);
      return response;
    }

    if (mounted) setState(() => _isLoading = false);
    return response;
  }

  dynamic remoteClaimTextWidget(Mine mine) {
    // print(mine.properties.comment);
    final now =
        DateTime.parse(DateTime.now().toUtc().toIso8601String()).toLocal();

    if (mine.lastVisited != "") {
      if (mine.properties.ico == "0") {
        return {
          "status": false,
          "payload": Text(
            "Not validated yet",
            style: TextStyle(color: Colors.orange),
          )
        };
      }

      var timeDiff = now.difference(DateTime.parse(mine.lastVisited)).inSeconds;

      if (timeDiff < 3600) {
        return {
          "status": false,
          "payload": Text(
            "Next claim in ${(3600 - timeDiff).toString()}s",
            style: TextStyle(color: Colors.orange),
          )
        };
      }
    }

    return {
      "status": true,
      "payload": Text(
        "Revisit for 1 Coin",
        style: TextStyle(color: Colors.orange),
      )
    };
  }

  void _getUserDetails() async {
    final user = await _apiProvider.getStoredUser();
    setState(() {
      _user = user;
      _userLocation = LtLn(_user.details.lat, _user.details.lng);
      // load Places after we get the current position
      loadPlaces();
    });
  }

  void getTutorialBattleGround() async {
    try {
      await _apiProvider.post("/places", {"mine_id": "13"});
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: "Congrats",
          description: 'You are now a fighter in the Battle grounds',
          buttonText: "Okay",
          images: [],
          callback: () {
            loadPlaces();
          },
        ),
      );
    } on AppError catch (err) {
      if (!mounted) return;
      err.show(context);
    } catch (err) {
      debugPrint('getTutorialBattleGround unexpected error: $err');
    }
  }

  void _updateUserLocation(LtLn ltln) async {
    //ltln.latitude.toString()
    //ltln.longitude.toString()
    setState(() {
      _userLocation = ltln;
    });
  }
}
