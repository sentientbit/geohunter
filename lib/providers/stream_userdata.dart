///
import 'package:rxdart/rxdart.dart';
import '../models/user.dart';

///
class StreamUserData {
  ///
  final _userdata = BehaviorSubject<UserData>.seeded(
    UserData(
      username: "",
      coins: 0.0,
      miningSpeed: 0,
      guildId: "0",
      xp: 0,
    ),
  );

  ///
  Stream<UserData> get stream$ => _userdata.stream;

  ///
  UserData get currentUserData => _userdata.value;

  ///
  void updateUserData(
      String username, double coins, int miningSpeed, String guildId, int xp) {
    _userdata.add(
      UserData(
        username: username,
        coins: coins,
        miningSpeed: miningSpeed,
        guildId: guildId,
        xp: xp,
      ),
    );
  }
}
