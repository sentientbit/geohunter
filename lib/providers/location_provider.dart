import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../shared/constants.dart';

/// App-wide GPS position stream.
///
/// Non-auto-dispose: stays alive for the entire app lifetime so the GPS chip
/// does not restart between screen navigations.
///
/// Permission must already be granted before this stream emits.
/// [SplashScreen._permissionsGps] handles the one-time permission prompt.
///
/// Access from ConsumerWidget / ConsumerState:
///   ref.watch(locationProvider)             → AsyncValue<LtLn>
///   ref.watch(locationProvider).valueOrNull → LtLn? (null before first fix)
///   ref.listen(locationProvider, (_, next) => next.whenData(fn))
final locationProvider = StreamProvider<LtLn>((ref) {
  return Geolocator.getPositionStream(
    locationSettings: const LocationSettings(distanceFilter: 1),
  ).map((p) => LtLn(p.latitude, p.longitude));
});
