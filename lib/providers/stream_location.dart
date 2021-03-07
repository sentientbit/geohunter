///
import 'package:rxdart/rxdart.dart';
import '../shared/constants.dart';

///
class StreamLocation {
  ///
  final _location = BehaviorSubject<LtLn>.seeded(LtLn(51.5, 0));

  ///
  Stream<LtLn> get stream$ => _location.stream;

  ///
  LtLn get currentLocation => _location.value;

  ///
  void updateLocation(LtLn position) {
    //print('updateLocation Lat');
    //print(position.latitude);
    //print('updateLocation Lng');
    //print(position.longitude);
    _location.add(position);
  }
}
