import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/visitevent.dart';

/// Carries the most recent battle/visit outcome fired by [RockPaperScissorsPage].
///
/// Map screen listens for win signals:
///   ref.listen(visitEventProvider, (_, event) {
///     if (event.outcome == 1) _goMine(_mineIdx);
///   });
///
/// Battle screen writes the result:
///   ref.read(visitEventProvider.notifier).update(VisitEvent(1, "3", mineId));
class VisitEventNotifier extends StateNotifier<VisitEvent> {
  VisitEventNotifier() : super(VisitEvent(0, '0', 0));

  void update(VisitEvent event) => state = event;
}

final visitEventProvider =
    StateNotifierProvider<VisitEventNotifier, VisitEvent>(
        (ref) => VisitEventNotifier());
