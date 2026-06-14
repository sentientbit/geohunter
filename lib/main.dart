// ignore_for_file: omit_local_variable_types
library crashy;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'app_localizations.dart';
import 'providers/api_provider.dart';
import 'providers/custom_interceptors.dart';
import 'providers/user_provider.dart';
import 'router.dart';
import 'shared/auth_utils.dart';
import 'shared/constants.dart';
import 'shared/sfx.dart';

/// assert debug mode
bool get isInDebugMode {
  var inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

///
@pragma('vm:entry-point')
void callbackDispatcher() {
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
          final _ = jsonDecode(response.body);
          //debugPrint('daily: ${_["user"]["daily"]}');
          //if (_["user"]["daily"] > GlobalConstants.dailyGiftFreq) {
          //  _showDailyNotification("Daily reward", DateTime.now().toUtc());
          //}
        }
      });
    });

    return Future.value(true);
  });
}

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  ///
  // GetIt stream singletons removed — replaced by Riverpod providers:
  //   StreamLocation  → locationProvider  (lib/providers/location_provider.dart)
  //   StreamVisit     → visitEventProvider (lib/providers/visit_provider.dart)
  //   StreamMines     → dead code (never written to externally)
  //   StreamUserData  → userProvider       (lib/providers/user_provider.dart)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Load the device-local sound-effects toggle (backend doesn't persist it).
  await Sfx.init();

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

  runApp(const ProviderScope(child: AppStartupWidget()));
}

class AppStartupWidget extends StatefulWidget {
  const AppStartupWidget({super.key});

  @override
  State<AppStartupWidget> createState() => _AppStartupWidgetState();
}

// https://codewithandrea.com/articles/robust-app-initialization-riverpod/
class _AppStartupWidgetState extends State<AppStartupWidget> {
  // declare state variables

  @override
  void initState() {
    ApiProvider().addInterceptors();
    Workmanager().initialize(callbackDispatcher);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainApp();
    //if (loading) return AppStartupLoadingWidget()
    //if (error) return AppStartupErrorWidget(error, onRetry: () { ... })
  }
}

class MainApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Drive the app's UI locale from the account language so the whole app —
    // not just server content — follows the Settings language choice. Null
    // (logged out / not yet loaded) falls back to the device locale via
    // localeResolutionCallback below.
    final accountLang = ref.watch(userProvider).valueOrNull?.details.language;
    final Locale? locale = accountLang == 'ro'
        ? const Locale('ro', 'RO')
        : accountLang == 'en'
            ? const Locale('en', 'US')
            : accountLang == 'fr'
                ? const Locale('fr', 'FR')
                : null;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      locale: locale,
      theme: ThemeData(
        // canvasColor is what BottomNavigationBar actually reads in M3.
        // bottomNavigationBarTheme + elevation:0 also needed to suppress tint.
        canvasColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ro', 'RO'),
        Locale('fr', 'FR'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (locale != null &&
              locale.countryCode != null &&
              supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}
