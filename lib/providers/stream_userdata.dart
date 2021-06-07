///
import 'package:rxdart/rxdart.dart';
import '../models/user.dart';

///
class StreamUserData {
  ///
  final _userdata = BehaviorSubject<UserData>.seeded(
    UserData(
      coins: 0.0,
      miningSpeed: 0,
      guildId: "0",
      xp: 0,
      unread: [],
      attack: [],
      defense: [],
      daily: 0,
      music: 100,
    ),
  );

  ///
  Stream<UserData> get stream$ => _userdata.stream;

  ///
  UserData get currentUserData => _userdata.value;

  ///
  void updateUserData(
    double coins,
    int miningSpeed,
    String guildId,
    int xp,
    List<dynamic> unread,
    List<dynamic> attack,
    List<dynamic> defense,
    int daily,
    int music,
  ) {
    _userdata.add(
      UserData(
        coins: coins,
        miningSpeed: miningSpeed,
        guildId: guildId,
        xp: xp,
        unread: unread,
        attack: attack,
        defense: defense,
        daily: daily,
        music: music,
      ),
    );
  }
}
