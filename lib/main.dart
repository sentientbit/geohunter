// ignore_for_file: omit_local_variable_types
// @dart=2.11
library crashy;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:admob_flutter/admob_flutter.dart';
//import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flame_audio/bgm.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:geohunter/fonts/rpg_awesome_icons.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:latlong/latlong.dart';
//import 'package:package_info/package_info.dart';
import 'package:sentry/sentry.dart' as sentry;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';

import 'app_localizations.dart';
import 'models/user.dart';
import 'models/visitevent.dart';
import 'providers/api_provider.dart';
import 'providers/custom_interceptors.dart';
import 'providers/stream_location.dart';
import 'providers/stream_mines.dart';
import 'providers/stream_notifications.dart';
import 'providers/stream_userdata.dart';
import 'providers/stream_visit.dart';
import 'screens/account/profile.dart';
import 'screens/battle/rock_paper_scissors.dart';
import 'screens/forge/forge.dart';
import 'screens/forgot.dart';
import 'screens/friendship/friends.dart';
import 'screens/group/in_group.dart';
import 'screens/group/no_group.dart';
import 'screens/help/legend.dart';
import 'screens/help/settings.dart';
import 'screens/inventory/backpack.dart';
import 'screens/inventory/blueprints.dart';
import 'screens/inventory/materials.dart';
import 'screens/inventory/research.dart';
import 'screens/login.dart';
// import 'screens/planet_card.dart';
import 'screens/map/map_explore.dart';
import 'screens/places.dart';
import 'screens/quests/questline.dart';
import 'screens/register.dart';
import 'screens/terms_and_conditions.dart';
import 'shared/constants.dart';

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

/// API Connection provider
final _apiProvider = ApiProvider();

/// Current user guild status
GroupStatus _groupStatus = GroupStatus.unknown;

/// Curent loggedin user
User _user = User.blank();

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

///
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

///
final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

/// Used for finding out if a Notification launched the app
NotificationAppLaunchDetails notificationAppLaunchDetails;

/// Used to store all daily rewards hash IDs as to not repeat them
List<int> dailyrewardsIds = [];

/// What to visit first time
String initialRoute = GlobalConstants.backButtonPage;

/// Secure Storage for User Data
final _storage = FlutterSecureStorage();

///
void callbackDispatcher() async {
  Workmanager().executeTask((task, inputData) async {
    //debugPrint("Native task: $task bg: ${DateTime.now().toUtc().toIso8601String()}");
    await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl)
        .then((cookies) async {
      if (isLoggedIn(cookies) != true) {
        //debugPrint('not logged in');
        return Future.value(false);
      }

      await http.get(
        Uri.parse("https://${GlobalConstants.apiHostUrl}/api/profile"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          //HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer ${cookies['jwt']}",
        },
      ).then((response) {
        if (response.statusCode == 200) {
          final responseJson = jsonDecode(response.body);
          //debugPrint('daily: ${responseJson["user"]["daily"]}');
          if (responseJson["user"]["daily"] > GlobalConstants.dailyGiftFreq) {
            _showDailyNotification("Daily reward", DateTime.now().toUtc());
          }
        }
      });
    });

    return Future.value(true);
  });
}

/// Check if we are logged in (valid JWT token)
bool isLoggedIn(Map<String, dynamic> cookies) {
  if (cookies.isEmpty || !cookies.containsKey('jwt')) {
    return false;
  }

  Map jwtdata = parseJwt(cookies["jwt"]);
  final expirationDate = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)
      .add(Duration(seconds: jwtdata['exp'].toInt()));

  var now = DateTime.now().toUtc();

  if (now.isAfter(expirationDate)) {
    return false;
  }

  return true;
}

///
Future<void> _showDailyNotification(String title, DateTime now) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'tgh.notifications.channel.daily',
    'Daily reward',
    'Show notifications for each daily reward',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'Daily reward',
  );
  const IOSNotificationDetails iosPlatformChannelSpecifics =
      IOSNotificationDetails();
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics);

  var thisPayload =
      '{"nav":"questline","date":"${now.year}-${now.month}-${now.day}"}';
  var hashId = hashStringMurmur(thisPayload) &
      0x7FFFFFFF /* for some weird reason flutter_local_notifications IDs must be 32-bit integers */;
  //debugPrint('hashId: $hashId');
  if (!isInList(hashId, dailyrewardsIds)) {
    dailyrewardsIds.add(hashId);
    await flutterLocalNotificationsPlugin.show(
      hashId,
      title,
      'Please choose your free daily reward',
      platformChannelSpecifics,
      payload: thisPayload,
    );

    await _storage.write(
      key: "dailyrewardsIds",
      value: dailyrewardsIds.join(','),
    );
  }
}

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  getIt.registerSingleton<StreamLocation>(StreamLocation());
  getIt.registerSingleton<StreamMines>(StreamMines());
  getIt.registerSingleton<StreamUserData>(StreamUserData());
  getIt.registerSingleton<StreamVisit>(StreamVisit());
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails.didNotificationLaunchApp ?? false) {
    //debugPrint("launched by notification ${notificationAppLaunchDetails.payload}");
    if (notificationAppLaunchDetails.payload != null) {
      var resJson = json.decode(notificationAppLaunchDetails.payload);
      if (resJson.containsKey("nav")) {
        initialRoute = '/${resJson["nav"]}';
      }
    }
  }

  Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    //isInDebugMode: true
  );

  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (details) async {
    if (isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Sentry.
      StackTrace myDetails = details.stack ?? StackTrace.empty;
      Zone.current.handleUncaughtError(details.exception, myDetails);
    }
  };

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
        //initialRoute: initialRoute/* The splash screen is the parent screen as it will be responsible for all the checks */,
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
          '/poi-map': (context) => PoiMap(
                goToRemoteLocation: false,
                latitude: 51.5,
                longitude: 0.0,
              ),
          '/inventory': (context) => InventoryPage(),
          '/blueprints': (context) => BlueprintListPage(),
          '/research': (context) => ResearchPage(),
          '/forge': (context) => ForgePage(),
          '/materials': (context) => MaterialListPage(),
          '/friends': (context) => FriendsPage(),
          '/places': (context) => PlacesPage(
                mineTypeFilter: 0,
              ),
          '/questline': (context) => QuestLinePage(),
          '/battle': (context) => RockPaperScissorsPage(
                rndMap: (math.Random.secure().nextInt(2) + 1),
                mineId: 13,
              ),
          '/help': (context) => LegendPage(),
          '/settings': (context) => SettingsPage(),
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

///
extension ExtendedIterable<E> on Iterable<E> {
  /// Like Iterable<T>.map but callback have index as second argument
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }

  ///
  void forEachIndexed(void Function(E e, int i) f) {
    var i = 0;
    forEach((e) => f(e, i++));
  }
}

/// Our initial State
class SplashScreenState extends State<SplashScreen> {
  /// backround music variable
  Bgm musicBackground = Bgm();
  final Logger log = Logger(
      printer: PrettyPrinter(
          colors: true, printEmojis: true, printTime: true, lineLength: 80));

  /// Send periodical GPS updates to all dart files
  final _location = getIt.get<StreamLocation>();

  final _minesStream = getIt.get<StreamMines>();

  /// keep user data updated
  final _userdata = getIt.get<StreamUserData>();

  ///
  StreamSubscription<UserData> _userDataStreamSubscription;

  ///
  final _visiteventdata = getIt.get<StreamVisit>();

  ///
  StreamSubscription<VisitEvent> _visitStreamSubscription;

  bool _isOnline = true;

  ///
  StreamSubscription<Position> _positionStream;

  ///
  LocationPermission gpsPermission = LocationPermission.denied;

  ///
  bool isPositionStreaming = false;

  ///
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('notification_icon');

  /// permissions aren't requested here just to demo that can be done later
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      didReceiveLocalNotificationSubject.add(
        ReceivedNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        ),
      );
    },
  );

  ///
  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  @override
  void dispose() {
    //if (_positionStream != null) { _positionStream.cancel(); _positionStream = null; }
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _permissionsNotifications();
    musicBackground.initialize();
    _initializeNotifications();
    _permissionsGps();
    _configureSelectNotificationSubject();
    _initializePeriodicWorker();
  }

  void _initializePeriodicWorker() {
    Workmanager().cancelAll();
    // Periodic tasks for Android
    Workmanager().registerPeriodicTask(
      "tgh.periodic.15mins",
      "GeoHunter periodic background worker",
      frequency: Duration(minutes: 15),
      initialDelay: Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  ///
  void _permissionsNotifications() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  ///
  void _initializeNotifications() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) async {
      if (payload != null) {
        selectNotificationSubject.add(payload);
      }
    });

    // populate the notifications IDs hashes
    var secureStorage = await _storage.readAll();
    dailyrewardsIds.clear();
    //print('--- populate dailyrewardsIds ---');
    if (secureStorage.containsKey("dailyrewardsIds")) {
      dailyrewardsIds = secureStorage["dailyrewardsIds"]
          .split(',')
          .mapIndexed((e, i) => int.tryParse(e))
          .toList();
    }
  }

  ///
  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((payload) async {
      var resJson = json.decode(payload);
      if (resJson.containsKey("nav")) {
        await Navigator.of(context).pushReplacementNamed('/${resJson["nav"]}');
      }
      //debugPrint('notification payload: $payload');
    });
  }

  /// SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  /// AppSettings.openLocationSettings();
  _permissionsGps() async {
    //print('--- _permissionsGps ---');

    var locationEnabled = await Geolocator.isLocationServiceEnabled();
    //log.d(locationEnabled);
    gpsPermission = await Geolocator.checkPermission();
    //log.d(permission);
    if (gpsPermission == LocationPermission.denied ||
        gpsPermission == LocationPermission.deniedForever) {
      gpsPermission = await Geolocator.requestPermission();
      if (gpsPermission == LocationPermission.denied ||
          gpsPermission == LocationPermission.deniedForever) {
        gpsPermission = await Geolocator.requestPermission();
      } else {
        locationEnabled = true;
      }
    } else {
      locationEnabled = true;
    }

    if (locationEnabled == true) {
      _streamLocation(locationEnabled);
    }

    _visitStreamSubscription = _visiteventdata.stream$.listen(_visitEventData);

    _userDataStreamSubscription = _userdata.stream$.listen(_updateUserData);

    Timer(Duration(milliseconds: 800), buttonContinue);
  }

  /// What to do if the Continue adventuring button is pressed
  Future<bool> buttonContinue() async {
    final cookies =
        await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl);

    if (isLoggedIn(cookies) != true) {
      Navigator.of(context).pushNamed('/login');
      return false;
    }

    final response = await _apiProvider.get('/profile');

    if (response.containsKey("user")) {
      if (response["user"] != null) {
        // update local data
        _user.details.coins =
            double.tryParse(response["user"]["coins"].toString()) ?? 0.0;
        _user.details.guildId = response["user"]["guild"]["id"];
        _user.details.xp = response["user"]["xp"];
        _user.details.unread = response["user"]["unread"];
        _user.details.attack = response["user"]["attack"];
        _user.details.defense = response["user"]["defense"];
        _user.details.daily = response["user"]["daily"];
        _user.details.costs = response["user"]["costs"];

        _groupStatus = ((int.tryParse(_user.details.guildId) ?? 0) > 0)
            ? GroupStatus.inGroup
            : GroupStatus.notInGroup;

        // update global data
        _userdata.updateUserData(
          _user.details.coins,
          _user.details.mining,
          _user.details.guildId,
          _user.details.xp,
          _user.details.unread,
          _user.details.attack,
          _user.details.defense,
          _user.details.daily,
          _user.details.music,
          _user.details.costs,
        );

        cookies["jwt"] = response["jwt"];
        cookies["user"] = response["user"];
        await CustomInterceptors.setStoredCookies(
            GlobalConstants.apiHostUrl, cookies);
      }
    }

    // Go to the Map or to the notification Nav payload
    Navigator.of(context).pushNamed(initialRoute);
    // Then change it back for the next time
    setState(() {
      initialRoute = GlobalConstants.backButtonPage;
    });
    return true;
  }

  ///
  void _streamLocation(bool locationEnabled) async {
    //print('--- _streamLocation ---');
    _positionStream =
        Geolocator.getPositionStream(distanceFilter: 1).listen((position) {
      //position.latitude.toString()
      //position.longitude.toString()
      _location.updateLocation(LtLn(position.latitude, position.longitude));
    });
    setState(() {
      isPositionStreaming = locationEnabled;
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
              color: Color.fromARGB(255, 0, 0, 0),
            )
          ],
        ),
      ),
      onPressed: () {
        FlameAudio.audioCache.play(
            'sfx/bookOpen_${(math.Random.secure().nextInt(2) + 1).toString()}.mp3');
        Navigator.of(context).pushNamed('/terms');
      },
    );

    final adventureButton = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: SizedBox(),
        ),
        Expanded(
          flex: 8,
          child: Padding(
            padding: EdgeInsets.all(0),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: GlobalConstants.appBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                side: BorderSide(width: 1, color: Colors.white),
              ),
              onPressed: () {
                buttonContinue();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.hiking, color: Color(0xffe6a04e)),
                  Text(
                    ' Continue Adventuring',
                    style: TextStyle(
                      color: Color(0xffe6a04e),
                      fontSize: 18,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: SizedBox(),
        ),
      ],
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

    final settingsButton = TextButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            RPGAwesome.repair,
            color: Colors.white,
          ),
          Text(
            ' Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.bold,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 3.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ],
            ),
          ),
        ],
      ),
      onPressed: () {
        dailyrewardsIds.clear();
        _storage.delete(
          key: "dailyrewardsIds",
        );
        Navigator.of(context).pushNamed('/settings');
      },
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
                                  color: Color.fromARGB(255, 0, 0, 0),
                                )
                              ],
                            ),
                          ),
                        ),
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
                        SizedBox(height: 18),
                        settingsButton,
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20, left: 0),
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
                            "version: ${GlobalConstants.appVersion}",
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

  // Future _loadMines() async {
  //   // Port where we will receive our answer to nth prime.

  //   final cookies =
  //       await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl);

  //   if (cookies.isEmpty || !cookies.containsKey('jwt')) {
  //     return;
  //   }

  //   _location.stream$.listen(
  //     (currentLocation) async {
  //       //print('_location.stream.listen');
  //       if (currentLocation.latitude == 51.5 &&
  //           currentLocation.longitude == 0) {
  //         // It means Gps not ready yet, so we wait
  //         return;
  //       }

  //       var neLat = 0.0;
  //       var swLat = 0.0;
  //       var neLng = 0.0;
  //       var swLng = 0.0;
  //       int zoom = 16;

  //       Only browse through local points (zoom:16)
  //       List<Mine> _mines = [];
  //       var d = 39136000 *
  //           math.cos(degToRadian(currentLocation.longitude)) /
  //           math.pow(2, zoom);
  //       if (d > 10000000) {
  //         d = 10000000; /* cap to 10km */
  //       }

  //       neLat = currentLocation.latitude + radianToDeg(d / terraRadius);
  //       swLat = currentLocation.latitude - radianToDeg(d / terraRadius);
  //       neLng = currentLocation.longitude +
  //           radianToDeg(math.asin(d / terraRadius) /
  //               math.cos(degToRadian(currentLocation.latitude)));
  //       swLng = currentLocation.longitude -
  //           radianToDeg(math.asin(d / terraRadius) /
  //               math.cos(degToRadian(currentLocation.latitude)));

  //       if (_isOnline) {
  //         _mines = await _populateMines(
  //           neLat,
  //           swLat,
  //           neLng,
  //           swLng,
  //           zoom,
  //           currentLocation,
  //         );

  //         print('after _populateMines');
  //         print(_mines.length);
  //         //final _user = await _apiProvider.getStoredUser();
  //         //_user.details.mining
  //         //_mines[0].lastVisited
  //         //now = DateTime.parse(DateTime.now().toUtc().toIso8601String()).toLocal();
  //         //timeFromLastMine = now.difference(DateTime.parse(mine.lastVisited)).inSeconds;
  //         if (_mines.isNotEmpty) {
  //           _minesStream.updateMinesList(_mines);
  //         }
  //       }
  //     },
  //   );
  // }

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
                _permissionsGps();
                Navigator.of(context).pop();
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

  /// A function to be called when the User has new data
  void _updateUserData(UserData ud) async {
    User user = await _apiProvider.getStoredUser();
    print('--- _updateUserData ---');
    print(ud);
    print(user.details);

    // provide default music
    if (ud.music == null) {
      ud.music = 100;
    }

    // user opted for a music change
    if (musicBackground.isPlaying == false) {
      if (ud.music > 0) {
        musicBackground.play('audio/music/aWayThrough.mp3');
      }
    } else {
      if (ud.music == 0) {
        musicBackground.stop();
      }
    }

    if (user.details != null) {
      user.details.coins = ud.coins;
      user.details.mining = ud.mining;
      user.details.xp = ud.xp;
      user.details.unread = ud.unread;
      user.details.attack = ud.attack;
      user.details.defense = ud.defense;
      user.details.daily = ud.daily;

      user.details.music = ud.music;
      CustomInterceptors.setStoredCookies(
          GlobalConstants.apiHostUrl, user.toMap());
    }
  }

  /// What outcome did a visit had
  /// VisitEvent({outcome: ?, icoProperty: ?, mineId: ?})
  void _visitEventData(VisitEvent ve) async {
    print('--- _visitEventData ---');
    print(ve);
  }
}
