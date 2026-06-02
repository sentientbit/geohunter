import 'dart:math' as math;

import 'package:go_router/go_router.dart';

import 'screens/account/profile.dart';
import 'screens/splash_screen.dart';
import 'shared/auth_utils.dart';
import 'screens/battle/rock_paper_scissors.dart';
import 'screens/forge/forge.dart';
import 'screens/forgot.dart';
import 'screens/friendship/friends.dart';
import 'screens/group/in_group.dart';
import 'screens/group/no_group.dart';
import 'screens/help/legend.dart';
import 'screens/help/settings.dart';
import 'screens/inventory/backpack.dart';
import 'screens/inventory/blueprints.dart';
import 'screens/inventory/materials.dart';
import 'screens/inventory/research.dart';
import 'screens/login.dart';
import 'screens/map/map_explore.dart';
import 'screens/places.dart';
import 'screens/quests/questline.dart';
import 'screens/register.dart';
import 'screens/terms_and_conditions.dart';

/// The app's top-level router.
///
/// SplashScreen is NOT in this table — it is the `home:` widget in
/// [MainApp] and runs before routing starts. Once it decides where to
/// send the user it calls [context.go] into this table.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/group',
      redirect: (context, state) =>
          appGroupStatus == GroupStatus.inGroup ? '/in-group' : '/no-group',
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterPage(),
    ),
    GoRoute(
      path: '/forgot',
      builder: (context, state) => ForgotPage(),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => TermsAndPrivacyPage(),
    ),
    GoRoute(
      path: '/poi-map',
      builder: (context, state) {
        final params = state.uri.queryParameters;
        final lat = double.tryParse(params['lat'] ?? '');
        final lng = double.tryParse(params['lng'] ?? '');
        return PoiMap(
          goToRemoteLocation: lat != null && lng != null,
          latitude: lat ?? 51.5,
          longitude: lng ?? 0.0,
        );
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfilePage(),
    ),
    GoRoute(
      path: '/inventory',
      builder: (context, state) => InventoryPage(),
    ),
    GoRoute(
      path: '/blueprints',
      builder: (context, state) => BlueprintListPage(),
    ),
    GoRoute(
      path: '/materials',
      builder: (context, state) => MaterialListPage(),
    ),
    GoRoute(
      path: '/forge',
      builder: (context, state) => ForgePage(),
    ),
    GoRoute(
      path: '/research',
      builder: (context, state) => ResearchPage(),
    ),
    GoRoute(
      path: '/friends',
      builder: (context, state) => FriendsPage(),
    ),
    GoRoute(
      path: '/places',
      builder: (context, state) => PlacesPage(mineTypeFilter: 0),
    ),
    GoRoute(
      path: '/questline',
      builder: (context, state) => QuestLinePage(),
    ),
    GoRoute(
      path: '/battle',
      builder: (context, state) => RockPaperScissorsPage(
        rndMap: (math.Random.secure().nextInt(2) + 1),
        mineId: 13,
      ),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => LegendPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsPage(),
    ),
    GoRoute(
      path: '/in-group',
      builder: (context, state) => InGroup(),
    ),
    GoRoute(
      path: '/no-group',
      builder: (context, state) => NoGroup(),
    ),
  ],
);
