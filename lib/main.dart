library crashy;

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

// Admob variant 1 :(
import 'package:admob_flutter/admob_flutter.dart';
// Admob variant 2 :(
//import 'package:firebase_admob/firebase_admob.dart';
// Admob variant 3 :(
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flame/flame.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:latlong/latlong.dart';
import 'package:package_info/package_info.dart';
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
import 'screens/forgot.dart';
import 'screens/friendship/friends.dart';
import 'screens/group/in_group.dart';
import 'screens/group/noGroup.dart';
import 'screens/help/legend.dart';
import 'screens/inventory/backpack.dart';
import 'screens/inventory/forge.dart';
import 'screens/inventory/research.dart';
import 'screens/login.dart';
// import 'screens/planet_card.dart';
import 'screens/map_explore.dart';
import 'screens/places.dart';
import 'screens/quests/questline.dart';
import 'screens/register.dart';
import 'screens/terms_and_conditions.dart';
import 'shared/constants.dart';
import 'widgets/custom_alert.dart';
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

/// Sentry.io client used to send crash reports (or more generally "events").
final sentry.SentryClient _sentry =
    sentry.SentryClient(dsn: GlobalConstants.sentryDsn);

/// assert debug mode
bool get isInDebugMode {
  var inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

/// Reports [error] along with its [stackTrace] to Sentry.io.
Future<Null> _reportError(dynamic error, dynamic stackTrace) async {
  print('Caught error: $error');

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

  final response = await _sentry.captureException(
    exception: error,
    stackTrace: stackTrace,
  );

  if (response.isSuccessful) {
    print('Success! Event ID: ${response.eventId}');
  } else {
    print('Failed to report to Sentry.io: ${response.error}');
  }
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
            if (supportedLocale.languageCode == locale.languageCode &&
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
          '/research': (context) => ResearchPage(),
          '/forge': (context) => ForgePage(),
          '/friends': (context) => FriendsPage(),
          '/places': (context) => PlacesPage(),
          '/questline': (context) =>
              QuestLinePage(quest: ModalRoute.of(context).settings.arguments),
          '/help': (context) => LegendPage(),
          '/group': (context) =>
              (_groupStatus == GroupStatus.inGroup) ? InGroup() : NoGroup(),
          '/in-group': (context) => InGroup(),
          '/no-group': (context) => NoGroup(),
          '/terms': (context) => TermsAndPrivacyPage()
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
  //final Logger log = Logger(
  //    printer: PrettyPrinter(
  //        colors: true, printEmojis: true, printTime: true, lineLength: 80));

  final _location = getIt.get<StreamLocation>();
  final _minesStream = getIt.get<StreamMines>();

  ///
  final _userdata = getIt.get<StreamUserData>();

  ///
  StreamSubscription<UserData> _userDataStreamSubscription;

  bool _isOnline = true;

  /// Secure Storage for User Data
  final _storage = FlutterSecureStorage();

  StreamSubscription<Position> _positionStream;

  ///
  bool isPositionStreaming = false;

  String _appVersion = "";

  @override
  void dispose() {
    if (_positionStream != null) {
      _positionStream.cancel();
      _positionStream = null;
    }
    super.dispose();
  }

  @override
  void initState() {
    _setVersion();
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
      'sfx/doorOpen_1.ogg',
      'sfx/doorOpen_2.ogg',
      'sfx/miningPick_1.ogg',
      'sfx/miningPick_2.ogg',
      'sfx/miningPick_3.ogg',
      'sfx/miningPick_4.ogg'
    ]);

    super.initState();
  }

  _setVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;
    // String appName = packageInfo.appName;
    // String packageName = packageInfo.packageName;
    // String version = packageInfo.version;
    // String buildNumber = packageInfo.buildNumber;
    //ignore: omit_local_variable_types
    String uniqueId;
    //ignore: omit_local_variable_types
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      //ignore: omit_local_variable_types
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      uniqueId = androidInfo.model;
      uniqueId += androidInfo.isPhysicalDevice ? ',true,' : ',false,';
      uniqueId += androidInfo.androidId;
    } else {
      //ignore: omit_local_variable_types
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      // unique ID on iOS
      uniqueId = iosInfo.model;
      uniqueId += iosInfo.isPhysicalDevice ? ',true,' : ',false,';
      uniqueId += iosInfo.identifierForVendor;
    }
    print("unique id: $uniqueId : ${hashStringMD5(uniqueId)}");
  }

  /// SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  /// AppSettings.openLocationSettings();
  _checkGps() async {
    print('--- check Gps ${isPositionStreaming.toString()} ---');
    //ignore: omit_local_variable_types
    LocationPermission permission = await Geolocator.checkPermission();
    //log.d(permission);
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      //ignore: omit_local_variable_types
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        //ignore: omit_local_variable_types
        LocationPermission permission = await Geolocator.requestPermission();
      } else {
        isPositionStreaming = true;
      }
    } else {
      isPositionStreaming = true;
    }

    if (isPositionStreaming == true) {
      await _streamLocation();
    }
  }

  _tryAutoLogin() async {
    //print('--- _tryAutoLogin ---');
    //print(_permissionStatus);

    try {
      final cookies =
          await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl);

      //log.i('---cookies---');
      //log.i(cookies);

      if (cookies.isEmpty || !cookies.containsKey('jwt')) {
        Flame.audio.play('sfx/doorClose_1.ogg');
        Navigator.of(context).pushNamed('/login');
        return;
      }

      Map jwtdata = parseJwt(cookies["jwt"]);
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)
          .add(Duration(seconds: jwtdata['exp'].toInt()));
      //log.i(jwtdata);
      //log.i(expirationDate);
      var now = DateTime.now().toUtc();
      //log.i(now);
      if (now.isAfter(expirationDate)) {
        print('session expired');
        Flame.audio.play('sfx/doorClose_3.ogg');
        Navigator.of(context).pushNamed('/login');
        return;
      } else {
        print('session is still valid');
      }

      if (cookies["user"]["guild"]["id"].toString() == "0") {
        setState(() {
          //log.d('group status becomes Not in');
          _groupStatus = GroupStatus.notInGroup;
        });
      } else {
        setState(() {
          //log.d('group status becomes In');
          _groupStatus = GroupStatus.inGroup;
        });
      }

      _userdata.updateUserData(
        "",
        double.tryParse(cookies["user"]["coins"].toString()) ?? 0.0,
        0,
      );

      _userDataStreamSubscription = _userdata.stream$.listen(_updateUserData);

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

  Future<Timer> _streamLocation() async {
    _positionStream =
        Geolocator.getPositionStream(distanceFilter: 1).listen((position) {
      print('_streamLocation');
      print(position == null
          ? 'Unknown'
          : "${position.latitude.toString()} ${position.longitude.toString()}");
      if (position != null) {
        _location.updateLocation(LtLn(position.latitude, position.longitude));
      }
    });
    Timer(Duration(milliseconds: 1000), _loadMines);
    return Timer(Duration(milliseconds: 500), _tryAutoLogin);
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
                  )),
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
                            // ignore: lines_longer_than_80_chars
                            "ver: $_appVersion",
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
      Map<String, String> secureStorage, LtLn currentLocation) async {
    //ignore: omit_local_variable_types
    List<Mine> _mines = [];
    dynamic response;
    try {
      response = await _apiProvider.get(
          '/radar?cntr_lng=${currentLocation.longitude}&cntr_lat=${currentLocation.latitude}2&zoom=${secureStorage["mapZoom"]}&sw_lng=${secureStorage["swLng"]}&sw_lat=${secureStorage["swLat"]}&ne_lng=${secureStorage["neLng"]}&ne_lat=${secureStorage["neLat"]}');
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

        if (cookies["user"]["guild"]["id"].toString() == "0") {
          setState(() {
            _groupStatus = GroupStatus.notInGroup;
          });
        }

        var secureStorage = await _storage.readAll();

        // Only browse through local points (zoom:16)
        //ignore: omit_local_variable_types
        List<Mine> _mines = [];
        var d = 39136000 *
            math.cos(degToRadian(currentLocation.longitude)) /
            math.pow(2, 16 /*zoom*/);
        if (d > 10000000) {
          d = 10000000;
          /* cap to 10km */
        }

        // Define a polygon in which we search
        if (secureStorage["swLng"] == null) {
          final neLat = currentLocation.latitude +
              radianToDeg(d / earthRadius); /* max lat */
          final swLat = currentLocation.latitude -
              radianToDeg(d / earthRadius); /* min lat */

          final neLng = currentLocation.longitude +
              radianToDeg(math.asin(d / earthRadius) /
                  math.cos(
                      degToRadian(currentLocation.latitude))); /* max lng */
          final swLng = currentLocation.longitude -
              radianToDeg(math.asin(d / earthRadius) /
                  math.cos(
                      degToRadian(currentLocation.latitude))); /* min lng */
          await _storage.write(key: 'swLng', value: swLng.toString());
          await _storage.write(key: 'swLat', value: swLat.toString());
          await _storage.write(key: 'neLng', value: neLng.toString());
          await _storage.write(key: 'neLat', value: neLat.toString());
          await _storage.write(key: 'mapZoom', value: /*zoom*/ "16");
          secureStorage = await _storage.readAll();
        }

        if (_isOnline) {
          //print(' --- before _populateMines ---');
          _mines = await _populateMines(secureStorage, currentLocation);

          if (_mines.isNotEmpty) {
            final _user = await _apiProvider.getStoredUser();

            // Try only the closest mine
            var mine = _mines[0];

            // IT means that user never mined here
            // so we make it that you can mine it
            var timeFromLastMine = _user.details.miningSpeed + 1;

            if (mine.lastVisited != null) {
              final now =
                  DateTime.parse(DateTime.now().toUtc().toIso8601String())
                      .toLocal();

              timeFromLastMine =
                  now.difference(DateTime.parse(mine.lastVisited)).inSeconds;
            }

            //print('--- _mines.isNotEmpty ---');
            //print(mine.properties.ico);
            //print(timeFromLastMine);
            //print(mine.distanceToPoint);
            //print(digDistance);

            try {
              if (mine.distanceToPoint <= digDistance &&
                  timeFromLastMine > _user.details.miningSpeed) {
                final mineResponse = await _apiProvider.get(
                  '/mine?mine_id=${mine.id}',
                );

                //print('---mineResponse---');
                //log.d(mineResponse);

                if (mineResponse["success"] == true) {
                  if (mine.properties.ico == '1') {
                    Flame.audio.play(
                        'sfx/chopWood_${(math.Random.secure().nextInt(5) + 1).toString()}.ogg');
                  } else if (mine.properties.ico == '2') {
                    Flame.audio.play(
                        'sfx/miningPick_${(math.Random.secure().nextInt(4) + 1).toString()}.ogg');
                  }
                  //ignore: omit_local_variable_types
                  List<Image> imagesArr = [];

                  if (mineResponse["items"].isNotEmpty) {
                    for (dynamic value in mineResponse["items"]) {
                      if (value.containsKey("img") && value["img"] != "") {
                        //mine.addItem(value);
                        imagesArr.add(
                            Image.asset("assets/images/items/${value['img']}"));
                        //} else { log.d(value);
                      }
                    }
                  }

                  for (dynamic value in mineResponse["materials"]) {
                    if (value.containsKey("img") && value["img"] != "") {
                      //mine.addMaterial(value);
                      imagesArr.add(Image.asset(
                          "assets/images/materials/${value['img']}"));
                      //} else { log.d(value);
                    }
                  }

                  for (dynamic value in mineResponse["blueprints"]) {
                    if (value.containsKey("img") && value["img"] != "") {
                      imagesArr.add(Image.asset(
                          "assets/images/blueprints/${value['img']}"));
                      //} else { log.d(value);
                    }
                  }

                  // Show this mine as already mined
                  _mines[0].properties.ico = "0";
                  mine.properties.ico = "0";

                  Timer(Duration(seconds: 1), () {
                    //ignore: omit_local_variable_types
                    String mining = AppLocalizations.of(context)
                        .translate('you_found_point');
                    showDialog(
                      context: context,
                      builder: (context) => CustomDialog(
                          title: AppLocalizations.of(context)
                              .translate('congrats'),
                          description:
                              // ignore: lines_longer_than_80_chars
                              "$mining ${mine?.id}, ${mine?.properties?.comment}",
                          buttonText: "Okay",
                          images: imagesArr),
                    );
                  });
                }
              }
            } on DioError catch (err) {
              //log.e(err);
              Timer(Duration(seconds: 1), () {
                showDialog(
                  context: context,
                  builder: (context) => CustomDialog(
                    title: 'Error',
                    description:
                        // ignore: lines_longer_than_80_chars
                        '${err.response?.data}',
                    buttonText: "Okay",
                  ),
                );
              });
            }

            _minesStream.updateMinesList(_mines);
          }
        }
      },
    );
  }

  void _confirmGps(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return CustomAlert(
          title: "Please allow GPS sensor",
          description: "We need your permission",
          firstButtonText: 'Yes, allow it!',
          secondButtonText: 'No',
          callback: () {
            _checkGps();
          },
        );
      },
    );
  }

  /// A function to be called when the UserData stream gets updated
  void _updateUserData(UserData ud) async {
    //print('Drawer received _updateUserData');
    //print(ud.coins);
    //ignore: omit_local_variable_types
    User user = await _apiProvider.getStoredUser();
    if (user.details != null) {
      user.details.coins = ud.coins;
      CustomInterceptors.setStoredCookies(
          GlobalConstants.apiHostUrl, user.toMap());
    }
  }
}
