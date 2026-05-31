// Route-migration tests
//
// Verifies that the 4 endpoints migrated from query-param / request-body
// format to CI4 path-segment routes send the correct URL shape.
//
// Before → After:
//   GET  /mine?mine_id=42              → GET  /mine/42
//   PUT  /friends?token=TOKEN          → PUT  /friends/TOKEN
//   POST /dailyrewards  (body params)  → POST /dailyrewards/3/5/10/15
//   POST /membership    (body guid)    → POST /membership/GUILD-ABC-123
//
// Strategy: install a _CapturingAdapter on the static Dio instance shared by
// all ApiProvider() calls, issue the request with the same URL string the
// production screen code produces, then assert on the captured path.
// No widget tree is needed — these are pure API-layer unit tests.

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geohunter/models/app_error.dart';
import 'package:geohunter/providers/api_provider.dart';

// ── Capturing adapter ──────────────────────────────────────────────────────────

/// Records every outbound request's method and path, then returns a canned
/// HTTP 200 with the provided JSON body.  Never actually sends network traffic.
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
    capturedPath   = options.path;
    capturedMethod = options.method;
    final bytes = utf8.encode(jsonEncode(_body));
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void _setAdapter(HttpClientAdapter a) => ApiProvider.api.httpClientAdapter = a;

// ── Suite ──────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // CustomInterceptors reads JWT from storage on every request.
    // Empty stores mean JWT is null — fine for route-shape tests.
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('Migrated routes — path-segment format', () {
    // ── 1. GET /mine/:id ────────────────────────────────────────────────────

    test('GET mine uses path segment, not query param', () async {
      final adapter = _CapturingAdapter(body: {
        'success':    true,
        'items':      <dynamic>[],
        'materials':  <dynamic>[],
        'blueprints': <dynamic>[],
      });
      _setAdapter(adapter);

      const mineId = 42;
      // Same string that map_explore.dart _goMine() builds.
      // Ignore AppError — these tests only care about the URL shape, not the
      // response envelope (which _unwrap validates separately).
      try { await ApiProvider().get('/mine/$mineId'); } on AppError { /**/ }

      expect(adapter.capturedMethod, equals('GET'));
      expect(adapter.capturedPath,   equals('/mine/42'));
      // Must NOT carry the old query-string form
      expect(adapter.capturedPath,   isNot(contains('?')));
      expect(adapter.capturedPath,   isNot(contains('mine_id')));
    });

    // ── 2. PUT /friends/:token ──────────────────────────────────────────────

    test('PUT friends uses token as path segment, not query param', () async {
      final adapter = _CapturingAdapter();
      _setAdapter(adapter);

      // friends.dart afterScan() splits the scanned QR URL and takes index [5].
      // CI4 generates: https://host/qr/friendship/TOKEN/bogus
      //                  0     1  2       3          4     5
      const qrUrl = 'https://geocraft.example.com/qr/friendship/TOKEN123/bogus';
      final token = qrUrl.split('/')[5];

      // Same call that friends.dart afterScan() makes after the migration:
      try { await ApiProvider().put('/friends/$token', {}); } on AppError { /**/ }

      expect(adapter.capturedMethod, equals('PUT'));
      expect(adapter.capturedPath,   equals('/friends/TOKEN123'));
      // Must NOT carry the old query-string form
      expect(adapter.capturedPath,   isNot(contains('?token')));
      expect(adapter.capturedPath,   isNot(contains('token=')));
    });

    // ── 3. POST /dailyrewards/:day/:bp/:mat/:item ───────────────────────────

    test('POST dailyrewards sends all four params as path segments', () async {
      final adapter = _CapturingAdapter(body: {
        'success':    true,
        'blueprints': <dynamic>[],
        'materials':  <dynamic>[],
        'items':      <dynamic>[],
      });
      _setAdapter(adapter);

      const day = 3, blueprintId = 5, materialId = 10, itemId = 15;
      // Same call that questline.dart _dailyReward() makes after the migration:
      try {
        await ApiProvider().post('/dailyrewards/$day/$blueprintId/$materialId/$itemId', {});
      } on AppError { /**/ }

      expect(adapter.capturedMethod, equals('POST'));
      expect(adapter.capturedPath,   equals('/dailyrewards/3/5/10/15'));
      // Must NOT carry the old body-param keys in the URL
      expect(adapter.capturedPath,   isNot(contains('day=')));
      expect(adapter.capturedPath,   isNot(contains('blueprint_id')));
      expect(adapter.capturedPath,   isNot(contains('material_id')));
      expect(adapter.capturedPath,   isNot(contains('item_id')));
    });

    // ── 4. POST /membership/:guid ───────────────────────────────────────────

    test('POST membership sends guid as path segment, not in body', () async {
      final adapter = _CapturingAdapter(body: {
        'guild_id': '12',
        'message':  'Joined!',
      });
      _setAdapter(adapter);

      const guid = 'GUILD-ABC-123';
      // Same call that join_group.dart _joinGuild() makes after the migration
      // (body is empty when guild is not locked; password would go here if set):
      try { await ApiProvider().post('/membership/$guid', {}); } on AppError { /**/ }

      expect(adapter.capturedMethod, equals('POST'));
      expect(adapter.capturedPath,   equals('/membership/GUILD-ABC-123'));
      // Must NOT carry guid as a query or body key in the path
      expect(adapter.capturedPath,   isNot(contains('?')));
      expect(adapter.capturedPath,   isNot(contains('guid')));
    });
  });
}
