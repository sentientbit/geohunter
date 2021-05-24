// ignore_for_file: omit_local_variable_types
library crashy;

import 'dart:async';
import 'dart:math' as math;

// Admob variant 1 :(
import 'package:admob_flutter/admob_flutter.dart';
// Admob variant 2 :(
//import 'package:firebase_admob/firebase_admob.dart';
// Admob variant 3 :(
//import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flame/flame.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
//import 'package:latlong/latlong.dart';
//import 'package:package_info/package_info.dart';
import 'package:sentry/sentry.dart' as sentry;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter/material.dart';

//import 'package:logger/logger.dart';

import 'app_localizations.dart';
import 'models/mine.dart';
import 'models/user.dart';
import 'providers/api_provider.dart';
import 'providers/custom_interceptors.dart';
import 'providers/stream_location.dart';
import 'providers/stream_mines.dart';
import 'providers/stream_userdata.dart';
import 'screens/account/profile.dart';
import 'screens/forge/forge.dart';
import 'screens/forgot.dart';
import 'screens/friendship/friends.dart';
import 'screens/group/in_group.dart';
import 'screens/group/no_group.dart';
import 'screens/help/legend.dart';
import 'screens/inventory/backpack.dart';
import 'screens/inventory/blueprints.dart';
import 'screens/inventory/materials.dart';
import 'screens/inventory/research.dart';
import 'screens/login.dart';
// import 'screens/planet_card.dart';
import 'screens/map_explore.dart';
import 'screens/places.dart';
import 'screens/quests/questline.dart';
import 'screens/register.dart';
import 'screens/terms_and_conditions.dart';
import 'shared/constants.dart';
import 'widgets/custom_dialog.dart';

/// global RouteObserver
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

///
enum GroupStatus {
  ///
  unknown,

  ///
  notInGroup,

  ///
  inGroup,
}

///
GroupStatus _groupStatus = GroupStatus.unknown;

final sentry.SentryClient _sentry =
    sentry.SentryClient(sentry.SentryOptions(dsn: GlobalConstants.sentryDsn));

/// assert debug mode
bool get isInDebugMode {
  var inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

Future<Null> _reportError(dynamic error, dynamic stackTrace) async {
  // Errors thrown in development mode are unlikely to be interesting. You can
  // check if you are running in dev mode using an assertion and omit sending
  // the report.
  if (isInDebugMode) {
    print('Caught error');
    print(error);
    print(stackTrace);
    print('In dev mode. Not sending report to Sentry.io.');
    return;
  }
  final sentryId = await _sentry.captureException(
    error,
    stackTrace: stackTrace,
  );
  print('Capture exception result : SentryId : $sentryId');
}

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  getIt.registerSingleton<StreamLocation>(StreamLocation());
  getIt.registerSingleton<StreamMines>(StreamMines());
  getIt.registerSingleton<StreamUserData>(StreamUserData());
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (details) async {
    if (isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Sentry.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  // For play billing library 2.0 on Android, it is mandatory to call
  // [enablePendingPurchases](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.Builder.html#enablependingpurchases)
  // as part of initializing the app.
  InAppPurchaseConnection.enablePendingPurchases();

  // This creates a [Zone] that contains the Flutter application and stablishes
  // an error handler that captures errors and reports them.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Admob variant 1 :(
    Admob.initialize();

    // Admob variant 2 :(
    //if (isInDebugMode) {
    //  FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
    //} else {
    //  FirebaseAdMob.instance.initialize(appId: AdManager.appId);
    //}
    // Admob variant 3 :(
    //MobileAds.instance.initialize();

    ApiProvider().addInterceptors();

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        navigatorObservers: <NavigatorObserver>[routeObserver],
        supportedLocales: [
          Locale('en', 'US'),
          Locale('ro', 'RO'),
        ],
        // ignore: These delegates make sure that the localization data for the proper language is loaded
        localizationsDelegates: [
          // A class which loads the translations from JSON files
          AppLocalizations.delegate,
          // Built-in localization of basic text for Material widgets
          GlobalMaterialLocalizations.delegate,
          // Built-in localization for text direction LTR/RTL
          GlobalWidgetsLocalizations.delegate,
        ],

        /// Returns a locale which will be used by the app
        localeResolutionCallback: (locale, supportedLocales) {
          // Check if the current device locale is supported
          for (var supportedLocale in supportedLocales) {
            if (locale != null &&
                locale.countryCode != null &&
                supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          // If the locale of the device is not supported, use the first one
          // from the list (English, in this case).
          return supportedLocales.first;
        },

        /// Named routing
        routes: <String, WidgetBuilder>{
          '/splash-screen': (context) => SplashScreen(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/forgot': (context) => ForgotPage(),
          '/profile': (context) => ProfilePage(),
          '/poi-map': (context) => PoiMap(goToRemoteLocation: false),
          '/inventory': (context) => InventoryPage(),
          '/blueprints': (context) => BlueprintListPage(),
          '/research': (context) => ResearchPage(),
          '/forge': (context) => ForgePage(),
          '/materials': (context) => MaterialListPage(),
          '/friends': (context) => FriendsPage(),
          '/places': (context) => PlacesPage(),
          '/questline': (context) =>
              QuestLinePage(quest: ModalRoute.of(context).settings.arguments),
          '/help': (context) => LegendPage(),
          '/group': (context) =>
              (_groupStatus == GroupStatus.inGroup) ? InGroup() : NoGroup(),
          '/in-group': (context) => InGroup(),
          '/no-group': (context) => NoGroup(),
          '/terms': (context) => TermsAndPrivacyPage(),
        },
      ),
    );
  }, (error, stack) async {
    await _reportError(error, stack);
  });
}

///
class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

final _apiProvider = ApiProvider();

/// Our initial State
class SplashScreenState extends State<SplashScreen> {
  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  final _location = getIt.get<StreamLocation>();
  final _minesStream = getIt.get<StreamMines>();

  ///
  final _userdata = getIt.get<StreamUserData>();

  ///
  StreamSubscription<UserData> _userDataStreamSubscription;

  bool _isOnline = true;

  /// Secure Storage for User Data
  final _storage = FlutterSecureStorage();

  ///
  StreamSubscription<Position> _positionStream;

  ///
  LocationPermission gpsPermission = LocationPermission.denied;

  ///
  bool isPositionStreaming = false;

  String _appVersion = GlobalConstants.appVersion;

  @override
  void dispose() {
    //if (_positionStream != null) { _positionStream.cancel(); _positionStream = null; }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkGps();

    //https://jap.alekhin.io/scoring-storage-sound-tutorial-flame-flutter-part-4
    Flame.audio.disableLog();
    Flame.audio.loadAll(<String>[
      'sfx/bookOpen_1.ogg',
      'sfx/bookOpen_2.ogg',
      'sfx/chopWood_1.ogg',
      'sfx/chopWood_2.ogg',
      'sfx/chopWood_3.ogg',
      'sfx/chopWood_4.ogg',
      'sfx/chopWood_5.ogg',
      'sfx/click_1.ogg',
      'sfx/click_2.ogg',
      'sfx/click_3.ogg',
      'sfx/click_4.ogg',
      'sfx/click_5.ogg',
      'sfx/doorClose_1.ogg',
      'sfx/doorClose_2.ogg',
      'sfx/doorClose_3.ogg',
      'sfx/doorOpen_1.ogg',
      'sfx/doorOpen_2.ogg',
      'sfx/miningPick_1.ogg',
      'sfx/miningPick_2.ogg',
      'sfx/miningPick_3.ogg',
      'sfx/miningPick_4.ogg',
      'sfx/raven_1.ogg'
    ]);
  }

  ///
  void enableUserDataStream() {
    _userDataStreamSubscription = _userdata.stream$.listen(_updateUserData);

    // _userDataStreamSubscription = _userdata.stream$.listen(null);
    // // ignore: avoid_types_on_closure_parameters
    // _userDataStreamSubscription?.onData((UserData newBytes) async {
    //   print('_userDataStreamSubscription');
    //   _userDataStreamSubscription?.pause();
    //   User user = await _apiProvider.getStoredUser();
    //   print('--- enableUserDataStream() ---');
    //   log.d(user.details.unread);
    //   log.d(newBytes.unread);
    //   user.details.coins = newBytes.coins;
    //   user.details.xp = newBytes.xp;
    //   CustomInterceptors.setStoredCookies(
    //       GlobalConstants.apiHostUrl, user.toMap());

    //   _userDataStreamSubscription?.resume();
    // });
  }

  /// SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  /// AppSettings.openLocationSettings();
  _checkGps() async {
    isPositionStreaming = await Geolocator.isLocationServiceEnabled();
    gpsPermission = await Geolocator.checkPermission();
    //log.d(permission);
    if (gpsPermission == LocationPermission.denied ||
        gpsPermission == LocationPermission.deniedForever) {
      gpsPermission = await Geolocator.requestPermission();
      if (gpsPermission == LocationPermission.denied ||
          gpsPermission == LocationPermission.deniedForever) {
        gpsPermission = await Geolocator.requestPermission();
      } else {
        isPositionStreaming = true;
      }
    } else {
      isPositionStreaming = true;
    }

    if (isPositionStreaming == true) {
      await _streamLocation();
    }
    Timer(Duration(milliseconds: 500), _tryAutoLogin);
    Timer(Duration(milliseconds: 1000), _loadMines);
    Timer(Duration(milliseconds: 1500), enableUserDataStream);
  }

  _tryAutoLogin() async {
    //print('--- _tryAutoLogin ---');
    //print(_permissionStatus);

    try {
      final cookies =
          await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl);

      //log.i('--- cookies ---');
      //log.i(cookies);

      if (cookies.isEmpty || !cookies.containsKey('jwt')) {
        Flame.audio.play('sfx/doorClose_1.ogg');
        Navigator.of(context).pushNamed('/login');
        return;
      }

      Map jwtdata = parseJwt(cookies["jwt"]);
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)
          .add(Duration(seconds: jwtdata['exp'].toInt()));
      // log.i(jwtdata);
      //log.i(expirationDate);
      var now = DateTime.now().toUtc();
      // log.i(now);
      // log.d(now.isAfter(expirationDate));
      if (now.isAfter(expirationDate)) {
        print('session expired');
        Flame.audio.play('sfx/doorClose_3.ogg');
        Navigator.of(context).pushNamed('/login');
        return;
      } else {
        print('session is still valid');
      }

      _groupStatus =
          ((int.tryParse(cookies["user"]["guild"]["id"].toString()) ?? 0) > 0)
              ? GroupStatus.inGroup
              : GroupStatus.notInGroup;

      _userdata.updateUserData(
        double.tryParse(cookies["user"]["coins"].toString()) ?? 0.0,
        0,
        cookies["user"]["guild"]["id"],
        cookies["user"]["xp"],
        cookies["user"]["unread"],
      );

      //final tmp = await _apiProvider.get('/profile');
      //final quest = Quest.fromJson(cookies["user"]["current_quests"][0]);

      Flame.audio.play(
          'sfx/doorOpen_${(math.Random.secure().nextInt(2) + 1).toString()}.ogg');

      Navigator.of(context).pushNamed('/poi-map');
      //Navigator.of(context).pushNamed('/quests-full-page', arguments: quest);

    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Main Error',
          description: err.error.toString(),
          buttonText: "Okay",
        ),
      );
    }
  }

  ///
  void _streamLocation() async {
    _positionStream =
        Geolocator.getPositionStream(distanceFilter: 1).listen((position) {
      //print('_streamLocation');
      //position.latitude.toString()
      //position.longitude.toString()
      if (position != null) {
        _location.updateLocation(LtLn(position.latitude, position.longitude));
      }
    });
  }

  Widget build(BuildContext context) {
    var szHeight = MediaQuery.of(context).size.height;
    var szWidth = MediaQuery.of(context).size.width;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      // statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ));

    final termsButton = TextButton(
      child: Text(
        'Terms and conditions',
        style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.bold,
            shadows: <Shadow>[
              Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 3.0,
                  color: Color.fromARGB(255, 0, 0, 0))
            ]),
      ),
      onPressed: () {
        Flame.audio.play(
            'sfx/bookOpen_${(math.Random.secure().nextInt(2) + 1).toString()}.ogg');
        Navigator.of(context).pushNamed('/terms');
      },
    );

    final adventureButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: _tryAutoLogin,
      child: Text(
        'Continue Adventuring',
        style: TextStyle(
            color: Color(0xffe6a04e),
            fontSize: 18,
            fontFamily: 'Cormorant SC',
            fontWeight: FontWeight.bold),
      ),
    );

    final enableGpsButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: () => _confirmGps(context),
      child: Text(
        'Allow Gps Sensor',
        style: TextStyle(
            color: Color(0xffe6a04e),
            fontSize: 18,
            fontFamily: 'Cormorant SC',
            fontWeight: FontWeight.bold),
      ),
    );

    return Container(
      height: szHeight,
      width: szWidth,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        // appBar: appBar,
        body: OfflineBuilder(
          connectivityBuilder: (
            context,
            connectivity,
            child,
          ) {
            _isOnline = connectivity != ConnectivityResult.none;
            return child;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: DoubleBackToCloseApp(
              snackBar: const SnackBar(
                content: Text('Tap back again to leave'),
              ),
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/compass_map.jpg'),
                          fit: BoxFit.cover),
                    ),
                  ),
                  Center(
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      // padding: EdgeInsets.only(left: 24.0, right: 24.0),
                      children: <Widget>[
                        Center(
                            child: Text(
                          GlobalConstants.appName,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 58,
                              fontFamily: 'Cormorant SC',
                              fontWeight: FontWeight.bold,
                              shadows: <Shadow>[
                                Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 3.0,
                                    color: Color.fromARGB(255, 0, 0, 0))
                              ]),
                        )),
                        Semantics(
                            child: Center(
                              child: Image.asset(
                                'assets/images/compass.gif',
                                width: 150,
                              ),
                            ),
                            label: 'Loading compass'),
                        SizedBox(height: 18),
                        Center(
                          child: isPositionStreaming
                              ? adventureButton
                              : enableGpsButton,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50, left: 0),
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        // mainAxisSize: MainAxisSize.max,

                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: termsButton,
                            ),
                          ),
                          Text(
                            "version: $_appVersion",
                            style:
                                TextStyle(fontSize: 14.0, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Populate list of mines closer to the user
  Future _populateMines(
    double neLat,
    double swLat,
    double neLng,
    double swLng,
    int mapZoom,
    LtLn currentLocation,
  ) async {
    List<Mine> _mines = [];
    dynamic response;
    try {
      response = await _apiProvider.get(
          '/radar?cntr_lng=${currentLocation.longitude}&cntr_lat=${currentLocation.latitude}2&zoom=$mapZoom&sw_lng=$swLng&sw_lat=$swLat&ne_lng=$neLng&ne_lat=$neLat');
    } on DioError catch (err) {
      print(err?.response?.data);
      return _mines;
    }

    // Get all the mines in the immediate location
    if (response.containsKey("geojson")) {
      if (response["geojson"]["features"] != null) {
        response["geojson"]["features"].forEach(
            (mine) => _mines.add(Mine(mine, 1, location: currentLocation)));
      }
    }

    // Sort the List by distance to the Player
    _mines.sort((a, b) => a.distanceToPoint.compareTo(b.distanceToPoint));

    return _mines;
  }

  Future _loadMines() async {
    // Port where we will receive our answer to nth prime.

    final cookies =
        await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl);

    if (cookies.isEmpty || !cookies.containsKey('jwt')) {
      return;
    }

    _location.stream$.listen(
      (currentLocation) async {
        //print('_location.stream.listen');
        if (currentLocation.latitude == 51.5 &&
            currentLocation.longitude == 0) {
          // It means Gps not ready yet, so we wait
          return;
        }

        // var neLat = 0.0;
        // var swLat = 0.0;
        // var neLng = 0.0;
        // var swLng = 0.0;
        // int zoom = 16;

        // Only browse through local points (zoom:16)
        // List<Mine> _mines = [];
        // var d = 39136000 *
        //     math.cos(degToRadian(currentLocation.longitude)) /
        //     math.pow(2, zoom);
        // if (d > 10000000) {
        //   d = 10000000; /* cap to 10km */
        // }

        // neLat = currentLocation.latitude + radianToDeg(d / earthRadius);
        // swLat = currentLocation.latitude - radianToDeg(d / earthRadius);
        // neLng = currentLocation.longitude +
        //     radianToDeg(math.asin(d / earthRadius) /
        //         math.cos(degToRadian(currentLocation.latitude)));
        // swLng = currentLocation.longitude -
        //     radianToDeg(math.asin(d / earthRadius) /
        //         math.cos(degToRadian(currentLocation.latitude)));

        // if (_isOnline) {
        //   _mines = await _populateMines(
        //     neLat,
        //     swLat,
        //     neLng,
        //     swLng,
        //     zoom,
        //     currentLocation,
        //   );

        //   print('after _populateMines');
        //   print(_mines.length);
        //   //final _user = await _apiProvider.getStoredUser();
        //   //_user.details.miningSpeed
        //   //_mines[0].lastVisited
        //   //now = DateTime.parse(DateTime.now().toUtc().toIso8601String()).toLocal();
        //   //timeFromLastMine = now.difference(DateTime.parse(mine.lastVisited)).inSeconds;
        //   if (_mines.isNotEmpty) {
        //     _minesStream.updateMinesList(_mines);
        //   }
        // }
      },
    );
  }

  void _confirmGps(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Please allow GPS sensor",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Cormorant SC',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "GeoHunter needs your permission to your GPS location while using the App. Allow it?",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Open Sans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.9),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: GlobalConstants.appBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                side: BorderSide(width: 1, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.close, color: Color(0xffe6a04e)),
                  Text(
                    " No",
                    style: TextStyle(
                        color: Color(0xffe6a04e),
                        fontSize: 18,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: GlobalConstants.appBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                side: BorderSide(width: 1, color: Colors.white),
              ),
              onPressed: () {
                _checkGps();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.done, color: Color(0xffe6a04e)),
                  Text(
                    " Yes",
                    style: TextStyle(
                        color: Color(0xffe6a04e),
                        fontSize: 18,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// A function to be called when the UserData stream gets updated
  void _updateUserData(UserData ud) async {
    User user = await _apiProvider.getStoredUser();
    if (user.details != null) {
      user.details.coins = ud.coins;
      user.details.xp = ud.xp;
      user.details.unread = ud.unread;
      CustomInterceptors.setStoredCookies(
          GlobalConstants.apiHostUrl, user.toMap());
    }
  }
}
