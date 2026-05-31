/// A Library mine returned by GET /api/research/libraries.
/// Pages drop from any Library mine — no mine is tied to a specific discipline.
class LibraryMine {
  final int id;
  final String name;
  final double lat;
  final double lng;

  /// Distance from the requesting player in kilometres (1 decimal, e.g. 3.7).
  final double distanceKm;

  /// True when the player has visited this mine at least once.
  final bool visited;

  const LibraryMine({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    required this.visited,
  });

  factory LibraryMine.fromJson(Map<String, dynamic> json) {
    return LibraryMine(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      name: json['name'] as String? ?? '',
      lat: double.tryParse((json['lat'] ?? 0).toString()) ?? 0.0,
      lng: double.tryParse((json['lng'] ?? 0).toString()) ?? 0.0,
      distanceKm:
          double.tryParse((json['distance_km'] ?? 0).toString()) ?? 0.0,
      visited: json['visited'] == true || json['visited'] == 1,
    );
  }

  /// Google Maps URL for this mine.
  String get mapsUrl => 'https://www.google.com/maps?q=$lat,$lng';
}

/// Typed result of GET /api/research/libraries.
class LibraryMinesResponse {
  final String message;
  final List<LibraryMine> mines;

  const LibraryMinesResponse({required this.message, required this.mines});

  factory LibraryMinesResponse.fromJson(Map<String, dynamic> json) {
    final rawMines = json['mines'] as List? ?? [];
    return LibraryMinesResponse(
      message: json['message'] as String? ?? '',
      mines: rawMines
          .map((e) => LibraryMine.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
