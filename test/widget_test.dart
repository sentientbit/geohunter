import 'dart:async' show Future;
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

//import 'package:flutter/material.dart';
//import 'package:flutter_test/flutter_test.dart';

//import 'package:geohunter/main.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(MyApp());

//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);

//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();

//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }

// flutter test
import 'package:flutter_test/flutter_test.dart';
import 'package:geohunter/shared/constants.dart';
import 'package:encrypt/encrypt.dart' as enq;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Murmur32 Hash Test', () {
    final hash =
        hashStringMurmur("The quick brown fox jumps over the lazy dog");
    expect(hash, "2186537283");
  });

  test('Guild Unique Id offline validation', () {
    final ok = guildIdOfflineValidation("5556665");
    expect(ok, true);
    final fail = guildIdOfflineValidation("1234567");
    expect(fail, false);
  });

  test('PointyCastle Encode', () {
    final key =
        enq.Key.fromBase64("zV2TK7FQKMz2aDCxFciYh0qkXo70vrlPUDT1ZLf9lI4=");
    final iv = enq.IV.fromUtf8("np8unGFM3wwpUGhU");
    final obj = enq.Encrypter(enq.AES(key, mode: enq.AESMode.cbc));
    final enc =
        obj.encrypt("The quick brown fox jumps over the lazy dog", iv: iv);
    expect(enc.base64,
        "TXyq7mnWjyLCGFZW38rguz9TBZ4G7lsyuUm0dgH7xvSH7fOnqK99nR1Rj6h6fUYJ");
  });

  test('PointyCastle Decode', () {
    final key =
        enq.Key.fromBase64("zV2TK7FQKMz2aDCxFciYh0qkXo70vrlPUDT1ZLf9lI4=");
    final iv = enq.IV.fromUtf8("np8unGFM3wwpUGhU");
    final obj = enq.Encrypter(enq.AES(key, mode: enq.AESMode.cbc));
    final d = enq.Key.fromBase64(
        "TXyq7mnWjyLCGFZW38rguz9TBZ4G7lsyuUm0dgH7xvSH7fOnqK99nR1Rj6h6fUYJ");
    final dec = obj.decrypt(d, iv: iv);
    expect(dec, "The quick brown fox jumps over the lazy dog");
  });

  test('Debouncer test', () async {
    final _debouncer = Debouncer(milliseconds: 10);
    var k = 0;

    _debouncer.run(() => {k++});
    _debouncer.run(() => {k++});
    await Future.delayed(Duration(milliseconds: 50));
    _debouncer.run(() => {k++});
    _debouncer.run(() => {k++});
    _debouncer.run(() => {k++});
    _debouncer.run(() => {k++});
    await Future.delayed(Duration(milliseconds: 50));

    expect(k, 2);
  });
}
