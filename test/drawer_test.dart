// Widget tests for DrawerPage — currently covers the logout flow.
//
// Run with:  flutter test test/drawer_test.dart
//
// Setup notes:
//  - connectivity_plus mocked via _FakeConnectivity (same pattern as auth_test).
//  - shared_preferences mocked via setMockInitialValues; getStoredUser() reads
//    cookies from SharedPreferences and safely returns User.blank() when empty.
//  - flutter_secure_storage 9.x: setMockInitialValues seeds in-memory storage;
//    pre-seeding api_key in each logout test lets us verify it is wiped.
//  - FlameAudio / audioplayers: playClick() fires FlameAudio.play() before
//    calling logout().  The two audioplayers MethodChannels are stubbed in
//    setUp so the fire-and-forget audio call doesn't throw
//    MissingPluginException and fail the test.
//    Channel names from audioplayers_platform_interface 6.1.0:
//      xyz.luan/audioplayers        — per-player calls (create/resume/…)
//      xyz.luan/audioplayers.global — global audio-context setup

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geohunter/app_localizations.dart';
import 'package:geohunter/models/user.dart';
import 'package:geohunter/providers/user_provider.dart';
import 'package:geohunter/widgets/drawer.dart';

/// Returns User.blank() without hitting the API — satisfies userProvider
/// which DrawerPage now watches (ConsumerStatefulWidget migration).
class _FakeUserNotifier extends UserNotifier {
  @override
  Future<User> build() async => User.blank();
}

// ── Fake connectivity ──────────────────────────────────────────────────────────

class _FakeConnectivity
    with MockPlatformInterfaceMixin
    implements ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream<List<ConnectivityResult>>.empty();
}

// ── App wrapper ────────────────────────────────────────────────────────────────

/// Builds a MaterialApp whose home is a host Scaffold that has DrawerPage as
/// its Scaffold.drawer.
///
/// This mirrors how DrawerPage is used in production and is critical for the
/// Navigator to work correctly during logout:
///
///   • Scaffold.openDrawer() pushes a DrawerRoute overlay onto the Navigator.
///   • logout() calls Navigator.pop()  → closes the DrawerRoute (drawer disappears).
///   • logout() calls pushReplacementNamed('/login') → replaces the host
///     Scaffold route.
///
/// Mounting DrawerPage directly as `home` breaks this: Navigator.pop() removes
/// the only route, leaving the stack empty, so pushReplacementNamed throws
/// "Navigator has no active routes to replace".
/// GoRouter stub — DrawerPage.logout() uses context.go('/login') which
/// requires GoRouter in the context tree. MaterialApp.routes does not
/// satisfy GoRouter.of(), so we switch to MaterialApp.router here.
GoRouter _router() => GoRouter(
      initialLocation: '/host',
      routes: [
        GoRoute(
          path: '/host',
          builder: (_, __) => Scaffold(
            body: const Center(child: Text('HostPage')),
            drawer: DrawerPage(),
          ),
        ),
        GoRoute(path: '/login',     builder: (_, __) => const Scaffold(body: Text('LoginPage'))),
        GoRoute(path: '/profile',   builder: (_, __) => const Scaffold(body: Text('ProfilePage'))),
        GoRoute(path: '/poi-map',   builder: (_, __) => const Scaffold(body: Text('MapPage'))),
        GoRoute(path: '/inventory', builder: (_, __) => const Scaffold(body: Text('InventoryPage'))),
        GoRoute(path: '/forge',     builder: (_, __) => const Scaffold(body: Text('ForgePage'))),
        GoRoute(path: '/questline', builder: (_, __) => const Scaffold(body: Text('QuestlinePage'))),
        GoRoute(path: '/places',    builder: (_, __) => const Scaffold(body: Text('PlacesPage'))),
        GoRoute(path: '/friends',   builder: (_, __) => const Scaffold(body: Text('FriendsPage'))),
        GoRoute(path: '/group',     builder: (_, __) => const Scaffold(body: Text('GroupPage'))),
        GoRoute(path: '/battle',    builder: (_, __) => const Scaffold(body: Text('BattlePage'))),
        GoRoute(path: '/help',      builder: (_, __) => const Scaffold(body: Text('HelpPage'))),
        GoRoute(path: '/settings',  builder: (_, __) => const Scaffold(body: Text('SettingsPage'))),
      ],
    );

Widget _app() => ProviderScope(
      overrides: [userProvider.overrideWith(_FakeUserNotifier.new)],
      child: MaterialApp.router(
        routerConfig: _router(),
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
      ),
    );

// ── Pump helper ────────────────────────────────────────────────────────────────

/// Pumps the host app, waits for frames to settle, then opens the drawer so
/// DrawerPage's ListView is in the tree and ready to interact with.
///
/// runAsync is required for the same reason as in auth_test: the
/// AppLocalizations Future must resolve in every test, not just the first.
Future<void> _pumpWithDrawerOpen(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(_app());
  });
  await tester.pumpAndSettle();

  // Open the drawer via Scaffold state so the DrawerRoute is pushed and
  // DrawerPage's content is visible.
  final ScaffoldState scaffold =
      tester.state<ScaffoldState>(find.byType(Scaffold).first);
  scaffold.openDrawer();
  await tester.pumpAndSettle();
}

// ── Suite ──────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ConnectivityPlatform.instance = _FakeConnectivity();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    // Stub both audioplayers method channels so FlameAudio.play() inside
    // playClick() doesn't throw MissingPluginException.  Returning null is
    // sufficient — the fire-and-forget call in onTap doesn't inspect the result.
    for (final channelName in const [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        MethodChannel(channelName),
        (call) async => null,
      );
    }
  });

  // ═══════════════════════════════════════════════════════════════════════════
  //  DrawerPage › logout
  // ═══════════════════════════════════════════════════════════════════════════

  group('DrawerPage › logout', () {
    testWidgets(
        'tapping Logout deletes api_key from secure storage and navigates to /login',
        (tester) async {
      // Two pre-existing issues in DrawerPage are unrelated to logout but would
      // fail the test as "unexpected exceptions":
      //
      //  • RenderFlex overflow — the header Row (avatar + username + XP bar)
      //    needs ~290 px but the ListView content area is 274 px (Drawer 304 px
      //    minus ListView left-padding 30 px).  Pre-existing UI bug.
      //
      //  • NetworkImageLoadException — the avatar URL is constructed from the
      //    stored user's picture path; with an empty SharedPreferences the URL
      //    degenerates to the bare host.  TestWidgetsFlutterBinding blocks all
      //    real HTTP and returns 400, so the image always fails in tests.
      //    Note: NetworkImageLoadException.toString() returns
      //    "HTTP request failed, statusCode: …" — not the class name — so the
      //    filter must match that string, not "NetworkImageLoad".
      //
      // Suppress both via FlutterError.onError; restore via addTearDown so the
      // handler is always cleaned up even if the test throws.
      final prevHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('HTTP request failed')) {
          return;
        }
        prevHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = prevHandler);

      // Pre-seed api_key so there is a value to delete — verifiable post-logout.
      FlutterSecureStorage.setMockInitialValues({'api_key': 'session-token'});

      await _pumpWithDrawerOpen(tester);

      // ListView is lazy — items outside the viewport are not in the widget
      // tree yet, so find.text('Logout') returns nothing until we scroll.
      // scrollUntilVisible increments by [delta] px per step until the finder
      // matches, building new tiles as they enter the viewport.
      await tester.scrollUntilVisible(
        find.text('Logout'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // logout() calls context.go('/login') — GoRouter navigates to the stub
      // route which renders "LoginPage".
      expect(find.text('LoginPage'), findsOneWidget);

      // api_key must have been wiped from the in-memory mock store.
      final stored = await FlutterSecureStorage().read(key: 'api_key');
      expect(stored, isNull);
    });
  });
}
