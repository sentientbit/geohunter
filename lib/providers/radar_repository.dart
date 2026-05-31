import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/library_mine.dart';
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

  /// Fetches Library mines (mine_type=7) nearest to [lat]/[lng].
  /// Uses GET /api/places?mine_type=7&lat=…&lng=… (consolidated endpoint).
  ///
  /// Response shape (PlaceFeature — flat, not GeoJSON):
  ///   places[]         → visited mines   (lastVisited != null)
  ///   recommandations[] → unvisited mines
  /// Fields: id, desc (name), lat, lng, distance_km (server-computed, km).
  Future<LibraryMinesResponse> findNearestLibraries(
      double lat, double lng) async {
    final response =
        await _api.get('/places?mine_type=7&lat=$lat&lng=$lng');

    LibraryMine _parse(dynamic e, bool visited) {
      return LibraryMine(
        id: int.tryParse((e['id'] ?? 0).toString()) ?? 0,
        name: (e['desc'] as String?)?.isNotEmpty == true
            ? e['desc'] as String
            : 'Library Mine',
        lat: double.tryParse((e['lat'] ?? 0).toString()) ?? 0.0,
        lng: double.tryParse((e['lng'] ?? 0).toString()) ?? 0.0,
        distanceKm:
            double.tryParse((e['distance_km'] ?? 0).toString()) ?? 0.0,
        visited: visited,
      );
    }

    final mines = <LibraryMine>[];
    if (response['success'] == true) {
      final places = response['places'] as List? ?? [];
      mines.addAll(places.map((e) => _parse(e, true)));

      final recs = response['recommandations'] as List? ?? [];
      mines.addAll(recs.map((e) => _parse(e, false)));
    }

    // Both arrays already come sorted by distance from the server;
    // re-sort after merging so the combined list is still nearest-first.
    mines.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return LibraryMinesResponse(message: '', mines: mines.take(5).toList());
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

/// Formats [Mine.distanceToPoint] (metres, from radar) for display.
String formatMineDistance(double metres) {
  if (metres < 1000) return '${metres.toStringAsFixed(0)} m';
  return '${(metres / 1000).toStringAsFixed(1)} km';
}

/// Formats a distance already in kilometres (from LibraryMine.distanceKm).
String formatLibraryDistance(double km) {
  if (km < 1.0) return '${(km * 1000).toStringAsFixed(0)} m';
  return '${km.toStringAsFixed(1)} km';
}
