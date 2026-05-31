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

  /// Fetches Library mines (mine_type=7) nearest to [lat]/[lng].
  /// Uses GET /api/places?mine_type=7&lat=…&lng=… — the consolidated
  /// places endpoint (no separate /research/libraries needed).
  /// Pages drop from any Library mine regardless of discipline.
  Future<LibraryMinesResponse> findNearestLibraries(
      double lat, double lng) async {
    final response =
        await _api.get('/places?mine_type=7&lat=$lat&lng=$lng');

    final location = LtLn(lat, lng);
    final mines = <Mine>[];

    if (response is Map && response['success'] == true) {
      for (final key in ['places', 'recommandations']) {
        final items = response[key];
        if (items is List) {
          mines.addAll(
              items.map((e) => Mine.fromJson(e, 1, location)));
        }
      }
    }

    // Sort nearest first (distanceToPoint is metres, computed in Mine.fromJson).
    mines.sort((a, b) => a.distanceToPoint.compareTo(b.distanceToPoint));

    final libraryMines = mines.take(5).map((m) {
      // lastVisited default "1980-01-01 01:01:01Z" means never visited.
      final visited = m.lastVisited != '1980-01-01 01:01:01Z' &&
          m.lastVisited.isNotEmpty;
      return LibraryMine(
        id: m.id,
        name: m.properties.title.isNotEmpty
            ? m.properties.title
            : 'Library Mine',
        lat: m.geometry.coordinates[1],
        lng: m.geometry.coordinates[0],
        distanceKm: m.distanceToPoint / 1000,
        visited: visited,
      );
    }).toList();

    return LibraryMinesResponse(message: '', mines: libraryMines);
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
