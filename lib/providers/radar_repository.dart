import 'package:flutter_riverpod/flutter_riverpod.dart';

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
