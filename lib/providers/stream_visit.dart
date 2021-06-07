///
import 'package:rxdart/rxdart.dart';
import '../models/visitevent.dart';

/// Visit Events can be Battle Results, Trading Outcome, Library Foundings, etc..
class StreamVisit {
  ///
  final _visitevent = BehaviorSubject<VisitEvent>.seeded(VisitEvent(0, "0", 0));

  ///
  Stream<VisitEvent> get stream$ => _visitevent.stream;

  ///
  VisitEvent get currentEvent => _visitevent.value;

  ///
  void updateEvent(VisitEvent event) {
    // print('updateEvent res');
    // print(event.outcome);
    // print('updateEvent mine id');
    // print(event.mineId);
    _visitevent.add(event);
  }
}
