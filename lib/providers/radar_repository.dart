import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mine.dart';
import '../models/radar_response.dart';
import '../shared/constants.dart';
import 'api_provider.dart';

/// Wraps GET /api/radar — fetches visible POIs and players for the current
/// map viewport.
///
/// The bounding box is computed by the caller ([_PoiMapState._loadPois])
/// using the current map zoom and display-window centre, then passed here as
/// pre-calculated lat/lng extents.
class RadarRepository {
  final ApiProvider _api = ApiProvider();

  /// Finds Library mines (ico == "7") within roughly 10 km of [location].
  /// Returns them sorted by [Mine.distanceToPoint] (metres), nearest first.
  ///
  /// Once the radar API carries `blueprint_id` on Library features, callers
  /// can pass an optional [blueprintId] to filter to the exact page type.
  Future<List<Mine>> findNearestLibraries(LtLn location,
      {int? blueprintId}) async {
    const double span = 0.09; // ~10 km latitude span
    final response = await getRadar(
      userLocation: location,
      zoom: 12,
      swLat: location.latitude - span,
      swLng: location.longitude - span * 1.4,
      neLat: location.latitude + span,
      neLng: location.longitude + span * 1.4,
    );
    var libs =
        response.pois.where((m) => m.properties.ico == '7').toList();
    // Future: filter by blueprintId once radar carries that field.
    libs.sort((a, b) => a.distanceToPoint.compareTo(b.distanceToPoint));
    return libs;
  }

  Future<RadarResponse> getRadar({
    required LtLn userLocation,
    required double zoom,
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
  }) async {
    final url = '/radar'
        '?cntr_lng=${userLocation.longitude}'
        '&cntr_lat=${userLocation.latitude}'
        '&zoom=$zoom'
        '&sw_lng=$swLng'
        '&sw_lat=$swLat'
        '&ne_lng=$neLng'
        '&ne_lat=$neLat';
    final response = await _api.get(url);
    return RadarResponse.fromJson(response, userLocation);
  }
}

final radarRepositoryProvider =
    Provider<RadarRepository>((ref) => RadarRepository());

/// Distance formatter shared across UI that uses [Mine.distanceToPoint] (metres).
String formatMineDistance(double metres) {
  if (metres < 1000) return '${metres.toStringAsFixed(0)} m';
  return '${(metres / 1000).toStringAsFixed(1)} km';
}
