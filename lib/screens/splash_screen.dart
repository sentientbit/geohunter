// ignore_for_file: omit_local_variable_types
import 'dart:async';
import 'dart:math' as math;

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:workmanager/workmanager.dart';

import '../fonts/rpg_awesome_icons.dart';
import '../models/user.dart';
import '../providers/custom_interceptors.dart';
import '../providers/user_provider.dart';
import '../shared/auth_utils.dart';
import '../shared/constants.dart';

///
class SplashScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SplashScreen> createState() => SplashScreenState();
}

/// Our initial State
class SplashScreenState extends ConsumerState<SplashScreen> {
  ///
  final log = Logger(
      printer: PrettyPrinter(
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
          lineLength: 80));

  ///
  LocationPermission gpsPermission = LocationPermission.denied;

  ///
  bool isPositionStreaming = false;

  /// Secure Storage for User Data
  final _storage = const FlutterSecureStorage();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _permissionsGps();
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

  /// SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  /// AppSettings.openLocationSettings();
  _permissionsGps() async {
    var locationEnabled = await Geolocator.isLocationServiceEnabled();
    gpsPermission = await Geolocator.checkPermission();
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

    // locationProvider (StreamProvider) will start the GPS stream automatically
    // the first time it is watched in map_explore.dart.
    // Here we just record that permission is granted so the adventure button shows.
    if (locationEnabled == true) {
      _streamLocation(locationEnabled);
    }

    Timer(Duration(milliseconds: 800), buttonContinue);
  }

  /// What to do if the Continue adventuring button is pressed
  Future<bool> buttonContinue() async {
    final cookies =
        await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl);

    if (isLoggedIn(cookies) != true) {
      context.go('/login');
      return false;
    }

    try {
      // UserRepository fetches /api/profile, persists JWT + user to cookies,
      // and populates userProvider so the Drawer is ready immediately.
      ref.invalidate(userProvider);
      final user = await ref.read(userProvider.future);
      appGroupStatus = ((int.tryParse(user.details.guildId) ?? 0) > 0)
          ? GroupStatus.inGroup
          : GroupStatus.notInGroup;
    } catch (_) {
      // Profile fetch failed — navigate anyway; screens will handle auth errors.
      appGroupStatus = GroupStatus.unknown;
    }

    // Go to the Map
    context.go('/poi-map');
    return true;
  }

  ///
  void _streamLocation(bool locationEnabled) {
    // GPS stream is now owned by locationProvider (Riverpod StreamProvider).
    // map_explore.dart starts it automatically when it first watches the provider.
    setState(() {
      isPositionStreaming = locationEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    var szHeight = MediaQuery.of(context).size.height;
    var szWidth = MediaQuery.of(context).size.width;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
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
        FlameAudio.play(
            'sfx/bookOpen_${(math.Random.secure().nextInt(2) + 1).toString()}.mp3');
        context.push('/terms');
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
        _storage.delete(
          key: "dailyrewardsIds",
        );
        context.push('/settings');
      },
    );

    return Container(
      height: szHeight,
      width: szWidth,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: OfflineBuilder(
          connectivityBuilder: (
            context,
            connectivity,
            child,
          ) {
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
                context.pop();
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
                context.pop();
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

}
