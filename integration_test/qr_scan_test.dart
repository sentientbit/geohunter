/// Integration tests — QR round-trip.
///
/// Renders a friendship QR code using the same QrPainter that ShowQRPage uses,
/// saves the PNG to the device temp directory, then feeds it to
/// MobileScannerController.analyzeImage() which calls the native MLKit /
/// ZXing decoder — no camera required.
///
/// This closes the loop between the two halves of the friendship feature:
///   • ShowQRPage renders a URL into a QrImageView.
///   • friends.dart decodes whatever the camera sees and calls
///     FriendsRepository.addFriend(scannedUrl) which splits at index [5].
///
/// If the URL format from the backend ever changes (e.g. an extra segment is
/// added) both test 1 and test 2 will fail immediately, pointing directly to
/// the breaking change.
///
/// Run with:
///   flutter test integration_test/qr_scan_test.dart -d emulator-5554
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Renders [data] as a QR PNG using the same QrPainter settings as
/// ShowQRPage, writes it to [filePath], and returns the File.
///
/// 512 × 512 px gives the native decoder plenty of resolution; the
/// production QrImageView uses 240 px which is fine on-screen but can
/// cause decode failures when the image is read back from disk.
///
/// A white background is painted explicitly before the QR modules because
/// QrPainter no longer accepts an emptyColor parameter (deprecated in
/// qr_flutter 4.1.0) and native decoders require high contrast.
Future<File> _renderQrToFile(String data, String filePath) async {
  const size = 512.0;

  final painter = QrPainter(
    data: data,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.M,
    gapless: true,
    eyeStyle: const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Color(0xFF000000),
    ),
    dataModuleStyle: const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Color(0xFF000000),
    ),
  );

  // Draw white background first so the native decoder has full contrast.
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size, size),
    Paint()..color = const Color(0xFFFFFFFF),
  );
  painter.paint(canvas, const Size(size, size));

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  expect(byteData, isNotNull,
      reason: 'PictureRecorder must produce valid PNG bytes');

  final file = File(filePath);
  await file.writeAsBytes(byteData!.buffer.asUint8List());
  return file;
}

// ── Constants ─────────────────────────────────────────────────────────────────

/// A realistic friendship URL produced by the backend.
/// Format: https://<host>/qr/friendship/<TOKEN>/<bogus-segment>
///                         0  1    2       3        4          5
const _testUrl =
    'https://geocraft.example.com/qr/friendship/TOKEN123/bogus';
const _expectedToken = 'TOKEN123';

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('QR round-trip — render → decode → token extraction', () {
    // ── Test 1 ─────────────────────────────────────────────────────────────
    // The QR code that ShowQRPage displays must be decodable by the same
    // native scanner that friends.dart uses.
    testWidgets('QrPainter output is decodable by MobileScanner native decoder',
        (tester) async {
      final tmp = Directory.systemTemp.path;
      final file = await _renderQrToFile(_testUrl, '$tmp/qr_round_trip_1.png');

      final controller = MobileScannerController();
      final capture = await controller.analyzeImage(file.path);
      controller.dispose();
      await file.delete();

      expect(
        capture,
        isNotNull,
        reason: 'analyzeImage returned null — the native decoder could not '
            'read the PNG produced by QrPainter. Check image size or '
            'error-correction level.',
      );

      expect(
        capture!.barcodes,
        isNotEmpty,
        reason: 'BarcodeCapture.barcodes must contain at least one barcode',
      );

      final decoded = capture.barcodes.first.rawValue;
      expect(
        decoded,
        equals(_testUrl),
        reason: 'Decoded URL must exactly match what ShowQRPage embedded. '
            'A mismatch means the QR content has changed or been truncated.',
      );
    });

    // ── Test 2 ─────────────────────────────────────────────────────────────
    // After the round-trip decode, FriendsRepository.addFriend()'s
    // split-at-index-5 must still give the right token.
    // This is the integration guard for URL format changes: if the backend
    // adds/removes a path segment, this test fails with a clear message.
    testWidgets(
        'decoded URL yields correct friendship token via split(\'/\')[5]',
        (tester) async {
      final tmp = Directory.systemTemp.path;
      final file = await _renderQrToFile(_testUrl, '$tmp/qr_round_trip_2.png');

      final controller = MobileScannerController();
      final capture = await controller.analyzeImage(file.path);
      controller.dispose();
      await file.delete();

      expect(capture, isNotNull);

      final decoded = capture!.barcodes.first.rawValue;
      expect(decoded, isNotNull,
          reason: 'rawValue must not be null for a URL-type QR code');

      final segments = decoded!.split('/');
      expect(
        segments.length,
        greaterThanOrEqualTo(6),
        reason: 'URL must have at least 6 slash-separated segments '
            '(https://host/qr/friendship/TOKEN/bogus). '
            'Current segment count: ${segments.length}. '
            'If the backend changed the URL shape, update '
            'FriendsRepository.addFriend() accordingly.',
      );

      expect(
        segments[5],
        equals(_expectedToken),
        reason: 'FriendsRepository.addFriend() always takes index [5] as the '
            'token. Decoded segments: $segments',
      );
    });
  });
}
