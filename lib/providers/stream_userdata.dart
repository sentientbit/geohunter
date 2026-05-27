import 'package:rxdart/rxdart.dart';
import '../models/user.dart';
import '../models/player_stats.dart';

///
class StreamUserData {
  ///
  final _userdata = BehaviorSubject<UserData>.seeded(UserData.blank());

  /// Set by SplashScreen once Riverpod is available.
  /// Called alongside the stream so screens don't need ref yet.
  void Function(UserData)? _riverpodSink;

  void setRiverpodSink(void Function(UserData)? sink) => _riverpodSink = sink;

  ///
  Stream<UserData> get stream$ => _userdata.stream;

  ///
  UserData get currentUserData => _userdata.value;

  ///
  void updateUserData(
    String traces,
    double coins,
    int mining,
    String guildId,
    int xp,
    List<int> unread,
    StatRange attack,
    StatRange defense,
    int daily,
    PlayerSettings settings,
    ActionCosts costs,
  ) {
    final ud = UserData(
      traces: traces,
      coins: coins,
      mining: mining,
      guildId: guildId,
      xp: xp,
      unread: unread,
      attack: attack,
      defense: defense,
      daily: daily,
      settings: settings,
      costs: costs,
    );
    _userdata.add(ud);
    if (_riverpodSink != null) {
      try {
        _riverpodSink!.call(ud);
      } catch (_) {
        // SplashScreen ref was disposed — clear the stale sink silently.
        _riverpodSink = null;
      }
    }
  }
}
