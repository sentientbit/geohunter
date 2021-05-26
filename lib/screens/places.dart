// @dart=2.11
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:encrypt/encrypt.dart' as enq;

// import 'package:logger/logger.dart';

///
import '../app_localizations.dart';
import '../models/mine.dart';
import '../models/secret.dart';
import '../models/user.dart';
import '../providers/api_provider.dart';
import '../providers/custom_interceptors.dart';
import '../providers/stream_location.dart';
import '../screens/map_explore.dart' show PoiMap;
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
class PlacesPage extends StatefulWidget {
  ///
  final String name = 'Places';

  ///
  int mineTypeFilter = 0;

  ///
  PlacesPage({
    Key key,
    @required this.mineTypeFilter,
  }) : super(key: key);

  @override
  _PlacesState createState() => _PlacesState();
}

class _PlacesState extends State<PlacesPage> {
  /// Make sure back button is pressed twice
  bool ifPop = false;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isIapAvailable = false;
  List<String> _productIds = ["gold11coins"];
  List<String> _productDescriptions = ["Card payment\nComing soon"];
  List<String> _productPrices = ["N/A"];
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];
  StreamSubscription _iapSubscription;
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;

  bool _showCoinSheet = false;

  /// Curent loggedin user
  User _user = User.blank();

  LtLn _userLocation = LtLn(51.5, 0.0);

  int _mineTypeFilter = 0;

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  /// Validation token is used to sign every purchase transaction on the API
  String _validationToken = '';

  /// Transaction Id has to match the database token
  int _transactionId = 0;

  // Admob variant 1 :(
  AdmobReward _admobAdvert;

  Mine mine = Mine.blank();
  final _places = [];
  final _recommandations = [];
  bool _isLoading = false;
  bool _isRewarded = false;

  String _admobType = "";
  int _admobAmount = 0;

  int mineId = 0;
  final _apiProvider = ApiProvider();

  final _locationStreamBus = getIt.get<StreamLocation>();
  StreamSubscription<LtLn> _locationStreamSubscription;

  @override
  void initState() {
    super.initState();
    _mineTypeFilter = widget.mineTypeFilter;

    //_initializeIAP();
    _getUserDetails();

    _locationStreamSubscription =
        _locationStreamBus.stream$.listen(_updateUserLocation);

    // Admob variant 1 :(
    _admobAdvert = AdmobReward(
      adUnitId: AdManager.rewardedAdUnitId,
      listener: (event, args) {
        if (event == AdmobAdEvent.loaded) {
          //print('--- AdmobReward loaded');
          _admobAdvert?.show();
          setState(() {
            _isRewarded = false;
          });
        } else if (event == AdmobAdEvent.closed) {
          //print('--- AdmobReward closed');
          _admobAdvert?.dispose();
          if (_isRewarded) {
            _serverReward();
          } else {
            showDialog(
              context: context,
              builder: (context) => CustomDialog(
                title: 'Info',
                description: "You have to watch the whole commercial "
                    "to get the materials from that point",
                buttonText: "Okay",
                images: [],
                callback: () {},
              ),
            );
          }
          _isRewarded = false;
          setState(() {
            _admobType = "";
            _isLoading = false;
          });
        } else if (event == AdmobAdEvent.rewarded) {
          //print('--- AdmobReward rewarded');
          _admobType = "Reward";
          _isRewarded = true;
          var totalAmount = int.tryParse(args['amount'].toString()) ?? 0;
          setState(() {
            _admobAmount += totalAmount;
            _isLoading = false;
          });
        } else if (event == AdmobAdEvent.failedToLoad) {
          //print('--- AdmobReward failed');
          _isRewarded = false;
          showDialog(
            context: context,
            builder: (context) => CustomDialog(
              title: 'Error',
              description: Platform.isAndroid
                  ? "Google Mobile Ads failed. Please try again later."
                  : "Apple Mobile Ads failed. Please try again later.",
              buttonText: "Okay",
              images: [],
              callback: () {},
            ),
          );
          _deleteReward();
          _admobAdvert?.dispose();
          setState(() {
            _isLoading = false;
          });
        }
      },
    );

    BackButtonInterceptor.add(
      myInterceptor,
      name: widget.name,
      context: context,
    );

    initPlatformState();
  }

  @override
  void dispose() {
    _locationStreamSubscription?.cancel();
    BackButtonInterceptor.remove(myInterceptor);
    _iapSubscription?.cancel();
    _admobAdvert?.dispose();
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

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterInappPurchase.instance.platformVersion;
    } on Exception {
      platformVersion = 'platform version unknown';
    }

    // prepare
    var result = await FlutterInappPurchase.instance.initConnection;
    print('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // refresh items for android
    try {
      String msg = await FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } on Exception catch (err) {
      print('consumeAllItems error: $err');
    }

    _iapSubscription =
        FlutterInappPurchase.connectionUpdated.listen((connected) {
      print('connected: $connected');
    });

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      print('new-purchase: $productItem');
      _callbackPurchase(productItem.productId);
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
      setState(() {
        _isLoading = false;
        _isRewarded = false;
      });
    });

    await _getProducts();
    await _getPurchases();
  }

  Future _getProducts() async {
    // ignore: omit_local_variable_types
    List<IAPItem> items =
        await FlutterInappPurchase.instance.getProducts(_productIds);
    var idx = 0;
    for (var item in items) {
      _productPrices[idx] = item.localizedPrice;
      _productDescriptions[idx] = item.description;
      _productIds[idx] = item.productId;
      idx++;
    }

    setState(() {
      _items.addAll(items.toList());
    });
  }

  Future _getPurchases() async {
    // ignore: omit_local_variable_types
    List<PurchasedItem> items =
        await FlutterInappPurchase.instance.getAvailablePurchases();
    // for (var item in items) {
    //   print('${item.toString()}');
    //   _purchases.add(item);
    // }

    setState(() {
      _purchases.addAll(items.toList());
    });
  }

  void _callbackPurchase(String productId) {
    if (productId != _productIds[0]) {
      _deleteReward();
      setState(() {
        _isLoading = false;
        _isRewarded = false;
      });
      return;
    }
    _serverReward();
    setState(() {
      _isLoading = false;
      _isRewarded = true;
    });
  }

  void _requestPurchase(IAPItem item) {
    // log.d(item.productId);
    FlutterInappPurchase.instance.requestPurchase(item.productId);
    _goForReward(item.productId);
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

  Widget build(BuildContext context) {
    /// Application top Bar
    final topBar = AppBar(
      leading: IconButton(
        color: GlobalConstants.appFg,
        icon: Icon(
          Icons.menu,
          // size: 32,
        ),
        onPressed: () => _scaffoldKey != null
            ? _scaffoldKey.currentState?.openDrawer()
            : Navigator.of(context).pop(),
      ),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text(
        AppLocalizations.of(context).translate('drawer_my_points'),
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
        onPressed: () {
          // Admob variant 1 :(
          _goForReward("AdReward");
          _admobAdvert?.load();
          // Admob variant 2 :(
          //RewardedVideoAd.instance.load(adUnitId: AdManager.woodchopAdUnitId,targetingInfo: targetingInfo).catchError((e) => print("error in loading ${e.toString()}")).then((v) => setState(() => _adLoaded = v));
          // Admob variant 3 :(
          // if (!_rewardedReady) return;
          // _rewardedAd.show();
          // _rewardedReady = false;
          // _rewardedAd = null;
        },
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
          onPressed: () {
            _requestPurchase(_items[idx]);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.shopping_cart, color: Color(0xffe6a04e)),
              Text(
                " ${_productPrices[idx]}",
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
                            _productDescriptions[0],
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

    // final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      //resizeToAvoidBottomPadding: false,
      appBar: topBar,
      //extendBodyBehindAppBar: true,
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
    } on Exception catch (err) {
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

    List<Mine> tmp = [];
    List<dynamic> places = [];

    if (response.containsKey("success")) {
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
      _isRewarded = false;
      _places.addAll(places.toList());
      _recommandations.addAll(tmp.toList());
    });
  }

  Future _serverReward() async {
    dynamic response;
    try {
      response = await _apiProvider.post(
        '/reward',
        {
          "token": _validationToken,
          "tid": _transactionId.toString(),
        },
      );
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description:
              '${err.response?.data['message']} trnx: ${_transactionId.toString()}',
          buttonText: "Okay",
          images: [],
          callback: () {},
        ),
      );
      return;
    }

    if (response.containsKey("success")) {
      if (response["success"] == true) {
        _validationToken = "";
        _user.details.coins =
            double.tryParse(response["coins"].toString()) ?? 0.0;
        _transactionId = 0;

        setState(() {
          _isLoading = false;
        });

        /// Retain the current total funds
        CustomInterceptors.setStoredCookies(
            GlobalConstants.apiHostUrl, _user.toMap());

        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: AppLocalizations.of(context).translate('congrats'),
            description: "You gained ${response['amount']} coins, "
                "for a grand total of ${_user.details.coins.toString()} !",
            buttonText: "Okay",
            images: [],
            callback: () {},
          ),
        );
      }
    }
    return;
  }

  Future _remoteMine() async {
    //ignore: omit_local_variable_types
    List<Image> imagesArr = [];
    _getReward(mine.id, _admobType, _admobAmount).then((mineResponse) {
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

      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: AppLocalizations.of(context).translate('congrats'),
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
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description: '${err.response?.data['message']}',
          buttonText: "Okay",
          images: [],
          callback: () {},
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return response;
    }

    setState(() {
      _isLoading = false;
    });
    return response;
  }

  /// First step: get the tokens
  Future _goForReward(String rtype) async {
    dynamic response;
    try {
      response = await _apiProvider.get("/reward/$rtype");
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description: 'Invalid ad server response. Please try again later.',
          buttonText: "Okay",
          images: [],
          callback: () {},
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (response.containsKey("success")) {
      if (response["success"] == true) {
        _validationToken = response["token"] ?? "";
        _user.details.coins =
            double.tryParse(response["coins"].toString()) ?? 0.0;
        _transactionId = response["tid"] ?? 0;

        /// Retain the current total funds
        CustomInterceptors.setStoredCookies(
            GlobalConstants.apiHostUrl, _user.toMap());
        setState(() {
          _isLoading = true;
        });
      }
    }

    return;
  }

  /// Failure step: garbage collect
  Future _deleteReward() async {
    try {
      final response = await _apiProvider
          .delete("/reward/$_validationToken/${_transactionId.toString()}", {});

      if (response.containsKey("success")) {
        if (response["success"] == true) {
          _validationToken = "";
          _transactionId = 0;

          setState(() {
            _isLoading = false;
          });
          return;
        }
      }
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description: '${err.response?.data}',
          buttonText: "Okay",
          images: [],
          callback: () {},
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
  }

  dynamic remoteClaimTextWidget(Mine mine) {
    // print(mine.properties.comment);
    final now =
        DateTime.parse(DateTime.now().toUtc().toIso8601String()).toLocal();

    if (mine.lastVisited != "" && mine.lastVisited != null) {
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

  void _updateUserLocation(LtLn ltln) async {
    //ltln.latitude.toString()
    //ltln.longitude.toString()
    setState(() {
      _userLocation = ltln;
    });
  }
}
