import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

/// Holds the current live UserData that all screens can watch.
///
/// Populated by [StreamUserData.updateUserData] (existing call sites) until
/// each screen is migrated to call [UserNotifier.update] directly via ref.
class UserNotifier extends Notifier<UserData> {
  @override
  UserData build() => UserData.blank();

  void update(UserData ud) => state = ud;
}

final userProvider = NotifierProvider<UserNotifier, UserData>(UserNotifier.new);
