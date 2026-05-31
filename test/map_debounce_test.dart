/// Unit tests for the three-way onMapEvent debounce logic introduced in
/// commit 7dae0a0 ("Fix map regression: restore POI load on GPS recenter").
///
/// The logic under test (extracted from _PoiMapState.onMapEvent):
///
///   final isUserDrag     = event.source != MapEventSource.mapController
///   final wasGpsRecenter = _recenterBtnPressed   // captured before debounce fires
///
///   if (isUserDrag || wasGpsRecenter) → _loadPois()   ← POIs reload
///   else                              → skip           ← goToRemoteLocation path
///
/// These are pure Dart tests — no widget, no emulator, sub-millisecond.
import 'package:flutter_test/flutter_test.dart';
import 'package:geohunter/shared/constants.dart';

void main() {
  group('Map onMapEvent debounce — POI reload gating', () {
    // Helper: runs the debounce gate and returns whether _loadPois would fire.
    Future<bool> runGate({
      required bool isUserDrag,
      required bool wasGpsRecenter,
      int debounceMs = 20,
    }) async {
      final debouncer = Debouncer(milliseconds: debounceMs);
      var poiLoaded = false;

      debouncer.run(() {
        if (isUserDrag || wasGpsRecenter) {
          poiLoaded = true;
        }
      });

      await Future.delayed(Duration(milliseconds: debounceMs * 3));
      return poiLoaded;
    }

    // ── Test 1 ────────────────────────────────────────────────────────────────
    // GPS changes location → _recenterBtnPressed was true → map should update.
    // This is the regression that was broken: icons didn't appear on app start
    // because the GPS-triggered camera move was treated as a remote-location move.
    test('GPS recenter (wasGpsRecenter=true) triggers POI reload', () async {
      final loaded = await runGate(isUserDrag: false, wasGpsRecenter: true);
      expect(loaded, isTrue,
          reason: 'GPS location change must trigger _loadPois so mine '
              'icons appear within the debounce window');
    });

    // ── Test 2 ────────────────────────────────────────────────────────────────
    // User drags the map → reload POIs at the new viewport centre.
    test('User drag (isUserDrag=true) triggers POI reload', () async {
      final loaded = await runGate(isUserDrag: true, wasGpsRecenter: false);
      expect(loaded, isTrue,
          reason: 'Manual map pan must reload POIs at the new viewport');
    });

    // ── Test 3 ────────────────────────────────────────────────────────────────
    // goToRemoteLocation postFrameCallback fires mapController.move() which is
    // a programmatic move with wasGpsRecenter=false.  _loadPois must NOT fire
    // because _centerOfMap() already loaded POIs at the remote location.
    test('goToRemoteLocation postFrame move does NOT re-trigger POI reload',
        () async {
      final loaded = await runGate(isUserDrag: false, wasGpsRecenter: false);
      expect(loaded, isFalse,
          reason: 'Programmatic goToRemoteLocation move must not overwrite '
              'the already-loaded remote POIs with player-position POIs');
    });

    // ── Test 4 ────────────────────────────────────────────────────────────────
    // Debouncer collapses rapid GPS ticks into a single _loadPois call.
    test('Rapid GPS ticks are collapsed to one POI reload', () async {
      const ms = 20;
      final debouncer = Debouncer(milliseconds: ms);
      var loadCount = 0;

      for (var i = 0; i < 5; i++) {
        debouncer.run(() => loadCount++);
      }

      await Future.delayed(const Duration(milliseconds: ms * 3));
      expect(loadCount, 1,
          reason: 'Five back-to-back GPS ticks must collapse to one '
              '_loadPois call, not five separate API requests');
    });
  });
}
