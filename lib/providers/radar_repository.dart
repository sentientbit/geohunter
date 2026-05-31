import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/library_mine.dart';
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

  /// Fetches up to 5 Library mines nearest to [lat]/[lng].
  /// Uses GET /api/research/libraries — a dedicated lightweight endpoint
  /// that returns typed results with distance_km and visited flag.
  /// Pages drop from any Library mine (not tied to a specific discipline).
  Future<LibraryMinesResponse> findNearestLibraries(
      double lat, double lng) async {
    final response =
        await _api.get('/research/libraries?lat=$lat&lng=$lng');
    return LibraryMinesResponse.fromJson(
        response as Map<String, dynamic>);
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
