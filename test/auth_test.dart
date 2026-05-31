// Widget + network tests for LoginPage and ForgotPage.
//
// Run with:  flutter test test/auth_test.dart
//
// Design notes:
//  - No extra packages needed — only flutter_test (already a dev dependency).
//  - HTTP is mocked by swapping ApiProvider.api.httpClientAdapter, which is the
//    static Dio instance shared by every ApiProvider() call in the app.
//  - Platform plugins (shared_preferences, flutter_secure_storage) are mocked
//    via their built-in setMockInitialValues() helpers (both available in the
//    versions pinned in pubspec.yaml).
//  - connectivity_plus is mocked by replacing ConnectivityPlatform.instance with
//    _FakeConnectivity (uses MockPlatformInterfaceMixin to bypass the token
//    guard) so OfflineBuilder renders the connected branch in every test without
//    going through any platform channel.  The platform singleton is a fresh
//    instance each setUp, so there is zero cross-test contamination.
//  - Every test pumps via _pumpApp(), which wraps pumpWidget in tester.runAsync().
//    This is required because _LocalizationsState.build() defers its child until
//    Future.wait(delegates.map(load)) resolves.  In test 2+, CachingAssetBundle
//    returns the already-resolved Future from test 1, but that Future's listeners
//    were captured in test 1's FakeAsync zone; the new zone's microtask queue
//    never fires it.  runAsync() escapes FakeAsync so the real async (or the
//    previously-resolved Future) completes, setState sets _locale, and
//    LoginPage is actually built in every test.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geohunter/app_localizations.dart';
import 'package:geohunter/providers/api_provider.dart';
import 'package:geohunter/screens/forgot.dart';
import 'package:geohunter/screens/login.dart';

// ── Fake connectivity ──────────────────────────────────────────────────────────

/// Replaces [ConnectivityPlatform.instance] in every test so that
/// [OfflineBuilder] receives a "wifi" result immediately — no platform channels
/// involved, no cross-test state left behind.
///
/// [MockPlatformInterfaceMixin] bypasses [PlatformInterface.verifyToken] so
/// we can use `implements` rather than `extends` (whose constructor call would
/// require the private _token from the platform-interface package).
class _FakeConnectivity
    with MockPlatformInterfaceMixin
    implements ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.wifi];

  /// Return an empty stream so OfflineBuilder's asyncExpand settles cleanly.
  /// The initial "wifi" value from checkConnectivity() is enough; no
  /// connectivity-change events are needed for these tests.
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream<List<ConnectivityResult>>.empty();
}

// ── Fake HTTP adapters ─────────────────────────────────────────────────────────

/// Returns a canned JSON response (status + body) for every outgoing request.
///
/// Uses `implements` (not `extends`) because HttpClientAdapter in Dio 5.x
/// only exposes a factory constructor, which cannot be called via super().
class _FakeAdapter implements HttpClientAdapter {
  final int statusCode;
  final Map<String, dynamic> body;

  const _FakeAdapter({required this.statusCode, required this.body});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = utf8.encode(jsonEncode(body));
    return ResponseBody.fromBytes(
      bytes,
      statusCode,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Throws a connection-error DioException — simulates no network.
class _ErrorAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );

  @override
  void close({bool force = false}) {}
}

// ── Helpers ────────────────────────────────────────────────────────────────────

/// Builds a minimal, structurally valid JWT (header.payload.sig).
/// parseJwt() in constants.dart only base64-decodes the payload, so the
/// signature is never verified — "fakesignature" is fine for tests.
String _fakeJwt(Map<String, dynamic> payload) {
  // Pad base64url to avoid "Invalid base64" errors in parseJwt().
  String pad(String s) => s.padRight((s.length + 3) & ~3, '=');
  final header = pad(base64Url.encode(utf8.encode('{"typ":"JWT","alg":"HS512"}')));
  final body   = pad(base64Url.encode(utf8.encode(jsonEncode(payload))));
  return '$header.$body.fakesignature';
}

/// Swaps the Dio client's HTTP adapter for the duration of one test.
void _setAdapter(HttpClientAdapter adapter) =>
    ApiProvider.api.httpClientAdapter = adapter;

/// Wraps [child] in a MaterialApp with all localisation delegates and the
/// named routes the app navigates to after a successful login.
Widget _app(Widget child) => MaterialApp(
      home: child,
      routes: {
        '/poi-map': (_) => const Scaffold(body: Text('MapPage')),
        '/login':   (_) => LoginPage(),
        '/forgot':  (_) => ForgotPage(),
      },
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
    );

/// Finds a [TextField] by its InputDecoration hintText.
Finder _field(String hint) => find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == hint,
    );

/// Pumps [child] inside the test [MaterialApp] and waits for all frames to
/// settle.
///
/// [tester.runAsync] is mandatory here.  [_LocalizationsState._load()] calls
/// [Future.wait] over every delegate's [load()] Future.  From test 2 onward
/// [CachingAssetBundle] returns the same already-resolved Future it stored in
/// test 1, but that Future's pending listeners were captured in test 1's
/// [FakeAsync] zone.  When the new test zone registers a [.then()] on it the
/// microtask is silently swallowed by the old zone and never fires in the
/// current zone — [_locale] stays null, [_LocalizationsState.build] returns
/// [SizedBox.shrink], and [LoginPage] is never mounted.
///
/// Wrapping [pumpWidget] in [runAsync] escapes [FakeAsync] entirely so real
/// async (and cached-but-zone-captured Futures) resolves, [setState] is called,
/// [AppLocalizations] becomes available, and [LoginPage] builds normally.
/// The subsequent [pumpAndSettle] drains any residual frame callbacks
/// (e.g. [OfflineBuilder] scheduling a rebuild after [checkConnectivity]).
Future<void> _pumpApp(WidgetTester tester, Widget child) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(_app(child));
  });
  await tester.pumpAndSettle();
}

// ── Suite ──────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Replace the connectivity platform so OfflineBuilder sees "wifi" instantly
    // without touching any platform channel.  Fresh instance each setUp means
    // no state leaks between tests.
    ConnectivityPlatform.instance = _FakeConnectivity();

    // shared_preferences: used by CustomInterceptors cookie store.
    SharedPreferences.setMockInitialValues({});

    // flutter_secure_storage 9.x ships setMockInitialValues() — one liner.
    FlutterSecureStorage.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════════════════════════════════════
  //  LoginPage
  // ═══════════════════════════════════════════════════════════════════════════

  group('LoginPage › layout', () {
    testWidgets('renders Email field, Password field, and Login button',
        (tester) async {
      await _pumpApp(tester, LoginPage());

      expect(_field('Email'),    findsOneWidget);
      expect(_field('Password'), findsOneWidget);
      expect(find.text('Log in with email'),    findsOneWidget);
      expect(find.text('Forgot password'),      findsOneWidget);
      expect(find.text("Don't have an account"), findsOneWidget);
    });
  });

  group('LoginPage › validation', () {
    testWidgets('tap Login with empty email → "Please fill email"',
        (tester) async {
      await _pumpApp(tester, LoginPage());

      await tester.tap(find.text('Log in with email'));
      await tester.pump();

      expect(find.text('Please fill email'),    findsOneWidget);
      expect(find.text('Please fill password'), findsNothing);
    });

    testWidgets('email filled, password empty → "Please fill password"',
        (tester) async {
      await _pumpApp(tester, LoginPage());

      await tester.enterText(_field('Email'), 'user@example.com');
      await tester.tap(find.text('Log in with email'));
      await tester.pump();

      expect(find.text('Please fill email'),    findsNothing);
      expect(find.text('Please fill password'), findsOneWidget);
    });
  });

  group('LoginPage › network', () {
    testWidgets('HTTP 200 with no jwt key → shows "Invalid credentials"',
        (tester) async {
      // _unwrap needs success:true to pass; no jwt key in data simulates the
      // server returning a successful HTTP 200 but without a JWT (e.g. wrong
      // credentials that the server reports as success but without a token).
      // LoginPage then falls through to its "no jwt" branch and shows the
      // hardcoded "Invalid credentials" inline message.
      _setAdapter(const _FakeAdapter(
        statusCode: 200,
        body: {'success': true, 'data': {}},
      ));

      await _pumpApp(tester, LoginPage());

      await tester.enterText(_field('Email'),    'bad@example.com');
      await tester.enterText(_field('Password'), 'wrongpass');
      await tester.tap(find.text('Log in with email'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('valid JWT in response → navigates to /poi-map',
        (tester) async {
      final jwt = _fakeJwt({
        'usr': 'user@example.com',
        'iat': 1000000,
        'exp': 9999999999,
      });
      // _unwrap expects {success:true, data:{…}} envelope.
      // LoginPage reads jwt/api_key/user from the merged data map.
      _setAdapter(_FakeAdapter(
        statusCode: 200,
        body: {
          'success': true,
          'data': {
            'jwt':     jwt,
            'api_key': 'testapikey',
            'user':    {'username': 'testuser'},
          },
        },
      ));

      await _pumpApp(tester, LoginPage());

      await tester.enterText(_field('Email'),    'user@example.com');
      await tester.enterText(_field('Password'), 'correctpass');
      await tester.tap(find.text('Log in with email'));
      await tester.pumpAndSettle();

      // LoginPage calls context.go('/poi-map') which uses go_router — it does
      // not push via MaterialApp.routes, so we can't verify the route stub.
      // Instead verify the side-effect that proves a successful login: the JWT
      // api_key was persisted to secure storage.
      final storedKey = await FlutterSecureStorage().read(key: 'api_key');
      expect(storedKey, equals('testapikey'));
    });

    testWidgets('network error → "Check internet connection" dialog',
        (tester) async {
      _setAdapter(_ErrorAdapter());

      await _pumpApp(tester, LoginPage());

      await tester.enterText(_field('Email'),    'a@b.com');
      await tester.enterText(_field('Password'), 'anypass');
      await tester.tap(find.text('Log in with email'));
      await tester.pumpAndSettle();

      // AppError.fromDio for connectionError produces this exact message:
      expect(
        find.text('Check your internet connection and try again.'),
        findsOneWidget,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  //  ForgotPage
  // ═══════════════════════════════════════════════════════════════════════════

  group('ForgotPage › validation', () {
    testWidgets('tap Submit with empty email → "Please fill email"',
        (tester) async {
      await _pumpApp(tester, ForgotPage());

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text('Please fill email'), findsOneWidget);
    });
  });

  group('ForgotPage › network', () {
    testWidgets('success response → dialog shows server message',
        (tester) async {
      // _unwrap requires {success:true, data:{…}} envelope.
      // ForgotPage reads response['message'] from the merged data map.
      _setAdapter(const _FakeAdapter(
        statusCode: 200,
        body: {'success': true, 'data': {'message': 'Please check your email'}},
      ));

      await _pumpApp(tester, ForgotPage());

      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Please check your email'), findsOneWidget);
    });

    testWidgets('400 error response → dialog shows error message',
        (tester) async {
      // ApiProvider.hookStatus returns false for non-200, so Dio throws
      // DioException with the response attached. ForgotPage catches it and
      // shows err.response?.data["message"] in the dialog.
      _setAdapter(const _FakeAdapter(
        statusCode: 400,
        body: {'success': false, 'message': 'Email not found'},
      ));

      await _pumpApp(tester, ForgotPage());

      await tester.enterText(find.byType(TextField).first, 'noone@example.com');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Email not found'), findsOneWidget);
    });
  });
}
