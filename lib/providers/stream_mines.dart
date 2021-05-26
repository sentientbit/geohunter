///
import 'package:rxdart/rxdart.dart';
import '../models/mine.dart';

///
class StreamMines {
  final _mine = BehaviorSubject<List<Mine>>.seeded([]);

  /// Create stream for mines
  Stream<List<Mine>> get stream$ => _mine.stream;

  /// Get current mine from stream
  List<Mine> get currentLocation => _mine.value;

  ///
  void updateMinesList(List<Mine> mines) {
    _mine.add(mines);
    // log.w("LocationUpdated with ${_location.value}");
  }
}
