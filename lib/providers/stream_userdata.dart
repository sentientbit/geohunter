///
import 'package:rxdart/rxdart.dart';
import '../models/user.dart';

///
class StreamUserData {
  ///
  final _userdata = BehaviorSubject<UserData>.seeded(
    UserData(
      coins: 0.0,
      mining: 3600,
      guildId: "0",
      xp: 0,
      unread: [],
      attack: [],
      defense: [],
      daily: 0,
      music: 100,
      costs: [],
    ),
  );

  ///
  Stream<UserData> get stream$ => _userdata.stream;

  ///
  UserData get currentUserData => _userdata.value;

  ///
  void updateUserData(
    double coins,
    int mining,
    String guildId,
    int xp,
    List<dynamic> unread,
    List<dynamic> attack,
    List<dynamic> defense,
    int daily,
    int music,
    List<dynamic> costs,
  ) {
    _userdata.add(
      UserData(
        coins: coins,
        mining: mining,
        guildId: guildId,
        xp: xp,
        unread: unread,
        attack: attack,
        defense: defense,
        daily: daily,
        music: music,
        costs: costs,
      ),
    );
  }
}
