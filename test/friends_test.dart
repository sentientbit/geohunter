// Tests for the Friends QR feature — both displaying your own QR and
// scanning a friend's QR to send a friend request.
//
// Run with:  flutter test test/friends_test.dart
//
// Structure
// ─────────
//  Group 1 — Token extraction (pure Dart, no widget, no HTTP)
//    Validates the URL-split logic that extracts the friendship token from
//    the scanned QR URL.  Lives entirely in FriendsRepository.addFriend but
//    we test the extraction contract independently.
//
//  Group 2 — FriendsRepository.generateFriendshipQr
//    Verifies the POST /friends call and that the returned friendship_qr
//    string is surfaced correctly.  Uses _CapturingAdapter / _FakeAdapter.
//
//  Group 3 — FriendsRepository.addFriend
//    Verifies the PUT /friends/:token call shape.
//    Uses _CapturingAdapter to record the outgoing request path.
//
//  Group 4 — ShowQRPage widget
//    Verifies that after the API returns a friendship_qr URL,
//    a QrImageView widget appears in the tree.
//
// Shared infrastructure: _CapturingAdapter, _FakeAdapter, _FakeConnectivity,
// and _FakeUserNotifier are identical to the patterns in auth_test.dart /
// drawer_test.dart — copy rather than sharing to keep each test file
// self-contained and runnable in isolation.

import 'dart:convert';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geohunter/app_localizations.dart';
import 'package:geohunter/models/app_error.dart';
import 'package:geohunter/models/user.dart';
import 'package:geohunter/providers/api_provider.dart';
import 'package:geohunter/providers/friends_repository.dart';
import 'package:geohunter/providers/user_provider.dart';
import 'package:geohunter/screens/friendship/showqr.dart';

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

// ── Fake user notifier ─────────────────────────────────────────────────────────

class _FakeUserNotifier extends UserNotifier {
  @override
  Future<User> build() async => User.blank();
}

// ── HTTP adapters ──────────────────────────────────────────────────────────────

/// Records outbound method + path; returns a canned JSON body.
class _CapturingAdapter implements HttpClientAdapter {
  String? capturedPath;
  String? capturedMethod;

  final Map<String, dynamic> _body;

  _CapturingAdapter({Map<String, dynamic> body = const {'success': true}})
      : _body = body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedPath = options.path;
    capturedMethod = options.method;
    final bytes = utf8.encode(jsonEncode(_body));
    return ResponseBody.fromBytes(bytes, 200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        });
  }

  @override
  void close({bool force = false}) {}
}

/// Returns a fixed response body.
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
    return ResponseBody.fromBytes(bytes, statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        });
  }

  @override
  void close({bool force = false}) {}
}

void _setAdapter(HttpClientAdapter a) => ApiProvider.api.httpClientAdapter = a;

// ── Widget helpers ─────────────────────────────────────────────────────────────

Widget _app(Widget child) => ProviderScope(
      overrides: [userProvider.overrideWith(_FakeUserNotifier.new)],
      child: MaterialApp(
        home: child,
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
      ),
    );

Future<void> _pumpPage(WidgetTester tester, Widget child) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(_app(child));
  });
  await tester.pumpAndSettle();
}

// ── Suite ──────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ConnectivityPlatform.instance = _FakeConnectivity();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    // Stub audioplayers channels so DrawerPage (used as Scaffold drawer inside
    // ShowQRPage) does not throw MissingPluginException on init.
    for (final ch in const [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        MethodChannel(ch),
        (call) async => null,
      );
    }
  });

  // ═══════════════════════════════════════════════════════════════════════════
  //  Group 1 — Token extraction (pure Dart)
  // ═══════════════════════════════════════════════════════════════════════════

  group('QR URL token extraction', () {
    // The server produces URLs of the form:
    //   https://host/qr/friendship/TOKEN/bogus
    //                0  1    2       3     4    5
    // index [5] = token.  This is the contract tested here.
    test('splits standard friendship URL and yields token at index 5', () {
      const url =
          'https://geocraft.example.com/qr/friendship/TOKEN123/bogus';
      expect(url.split('/')[5], equals('TOKEN123'));
    });

    test('works with alphanumeric + hyphen tokens', () {
      const url =
          'https://geocraft.app/qr/friendship/abc-def-456/extra';
      expect(url.split('/')[5], equals('abc-def-456'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  //  Group 2 — FriendsRepository.generateFriendshipQr
  // ═══════════════════════════════════════════════════════════════════════════

  group('FriendsRepository.generateFriendshipQr', () {
    test('returns friendship_qr string from server response', () async {
      _setAdapter(const _FakeAdapter(
        statusCode: 200,
        body: {
          'success': true,
          'data': {
            'friendship_qr':
                'https://geocraft.example.com/qr/friendship/XYZ/y',
          },
        },
      ));

      final qr = await FriendsRepository().generateFriendshipQr();
      expect(
        qr,
        equals('https://geocraft.example.com/qr/friendship/XYZ/y'),
      );
    });

    test('returns empty string when friendship_qr key is absent', () async {
      _setAdapter(const _FakeAdapter(
        statusCode: 200,
        body: {'success': true, 'data': {}},
      ));

      final qr = await FriendsRepository().generateFriendshipQr();
      expect(qr, isEmpty);
    });

    test('calls POST /friends', () async {
      final adapter = _CapturingAdapter(body: {
        'success': true,
        'data': {'friendship_qr': 'https://geocraft.example.com/qr/friendship/T/y'},
      });
      _setAdapter(adapter);

      await FriendsRepository().generateFriendshipQr();

      expect(adapter.capturedMethod, equals('POST'));
      expect(adapter.capturedPath, equals('/friends'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  //  Group 3 — FriendsRepository.addFriend
  // ═══════════════════════════════════════════════════════════════════════════

  group('FriendsRepository.addFriend', () {
    test('calls PUT /friends/:token with token extracted from URL', () async {
      final adapter = _CapturingAdapter();
      _setAdapter(adapter);

      const scannedUrl =
          'https://geocraft.example.com/qr/friendship/TOKEN123/bogus';
      // _unwrap expects success:true — canned response satisfies it.
      try {
        await FriendsRepository().addFriend(scannedUrl);
      } on AppError {
        // _unwrap throws when data key is absent; ignore for URL-shape tests.
      }

      expect(adapter.capturedMethod, equals('PUT'));
      expect(adapter.capturedPath, equals('/friends/TOKEN123'));
      // Must NOT carry query params or the raw URL
      expect(adapter.capturedPath, isNot(contains('?')));
      expect(adapter.capturedPath, isNot(contains('geocraft')));
    });

    test('does not embed token= query param (path-segment migration)', () async {
      final adapter = _CapturingAdapter();
      _setAdapter(adapter);

      try {
        await FriendsRepository().addFriend(
            'https://geocraft.app/qr/friendship/abc-123/extra');
      } on AppError { /**/ }

      expect(adapter.capturedPath, equals('/friends/abc-123'));
      expect(adapter.capturedPath, isNot(contains('token')));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  //  Group 4 — ShowQRPage widget
  // ═══════════════════════════════════════════════════════════════════════════

  group('ShowQRPage', () {
    testWidgets('shows QrImageView after API returns friendship_qr',
        (tester) async {
      // Suppress pre-existing overflow/network-image errors from DrawerPage
      // header (same pattern as drawer_test.dart).
      final prevHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('HTTP request failed')) {
          return;
        }
        prevHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = prevHandler);

      _setAdapter(const _FakeAdapter(
        statusCode: 200,
        body: {
          'success': true,
          'data': {
            'friendship_qr':
                'https://geocraft.example.com/qr/friendship/TOKEN123/bogus',
          },
        },
      ));

      await _pumpPage(tester, const ShowQRPage());

      // QrImageView must be present — confirms generateNewQr() ran and
      // setState was called with the returned URL.
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('remains on page gracefully when API returns no qr field',
        (tester) async {
      final prevHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('HTTP request failed')) {
          return;
        }
        prevHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = prevHandler);

      // Server returns success but without friendship_qr — empty qr string.
      _setAdapter(const _FakeAdapter(
        statusCode: 200,
        body: {'success': true, 'data': {}},
      ));

      await _pumpPage(tester, const ShowQRPage());

      // QrImageView must NOT appear (empty _qrEndpoint → SizedBox shown).
      expect(find.byType(QrImageView), findsNothing);
      // Page itself must still be present — no crash.
      expect(find.text('Show QR Code'), findsOneWidget);
    });
  });
}
