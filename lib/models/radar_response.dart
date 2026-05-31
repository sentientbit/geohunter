import 'mine.dart';
import '../shared/constants.dart';

/// Result of GET /api/radar — the map POI and player overlay.
///
/// [pois]    — game points (category == 1): mines, wood, battle, library, etc.
/// [players] — other online players visible on the map (category == 2).
///
/// Both lists contain [Mine] objects with pre-computed [Mine.distanceToPoint]
/// relative to [userLocation] at the time of the request.
class RadarResponse {
  final List<Mine> pois;
  final List<Mine> players;

  const RadarResponse({required this.pois, required this.players});

  factory RadarResponse.fromJson(Map<String, dynamic> json, LtLn userLocation) {
    final pois = <Mine>[];
    final players = <Mine>[];

    final geojson = json['geojson'];
    if (geojson != null && geojson['features'] != null) {
      for (final elem in geojson['features'] as List) {
        pois.add(Mine.fromJson(elem, 1, userLocation));
      }
    }

    final playersGeo = json['players'];
    if (playersGeo != null && playersGeo['features'] != null) {
      for (final elem in playersGeo['features'] as List) {
        players.add(Mine.fromJson(elem, 2, userLocation));
      }
    }

    return RadarResponse(pois: pois, players: players);
  }
}
