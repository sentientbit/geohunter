import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import 'user_repository.dart';

/// Holds the live authenticated user.
///
/// Access from any ConsumerWidget:
///   `ref.watch(userProvider)` → AsyncValue<User>
///   `ref.watch(userProvider).valueOrNull` → User? (null while loading)
///
/// After any mutation that changes user state, call:
///   `ref.invalidate(userProvider)` — triggers a fresh GET /api/profile
///   and rebuilds every widget watching this provider.
class UserNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() => ref.read(userRepositoryProvider).getUser();

  /// Triggers a fresh GET /api/profile and waits for it to complete.
  /// Use [ref.invalidate(userProvider)] for fire-and-forget.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final userProvider =
    AsyncNotifierProvider<UserNotifier, User>(UserNotifier.new);
