/// Authentication helpers shared across the app.

/// Whether [cookies] represent a logged-in session.
bool isLoggedIn(Map<String, dynamic> cookies) {
  if (cookies.isEmpty || !cookies.containsKey('jwt')) {
    return false;
  }
  final jwt = cookies['jwt'];
  return jwt != null && jwt.toString().isNotEmpty;
}

/// The player's current guild membership state.
enum GroupStatus {
  unknown,
  notInGroup,
  inGroup,
}

/// Global mutable — set by SplashScreen after /profile response.
/// Router reads it for the /group redirect.
GroupStatus appGroupStatus = GroupStatus.unknown;
