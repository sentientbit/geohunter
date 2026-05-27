///
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:go_router/go_router.dart';

// import 'package:logger/logger.dart';

///
import '../app_localizations.dart';
import '../models/app_error.dart';
import '../fonts/rpg_awesome_icons.dart';
import '../libraries/pk_skeleton.dart';
import '../models/user.dart';
import '../providers/api_provider.dart';
import '../providers/custom_interceptors.dart';
import '../providers/user_provider.dart';
import '../shared/constants.dart';
import '../text_style.dart';
import '../widgets/custom_app_bar.dart';
// import '../widgets/custom_dialog.dart';

///
GetIt getIt = GetIt.instance;

///
class DrawerPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends ConsumerState<DrawerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  final _storage = FlutterSecureStorage();

  final ApiProvider _apiProvider = ApiProvider();
  ImageProvider _avatar = AssetImage("assets/images/avatars/default01.jpg");

  bool _loadingAvatar = true;

  @override
  void initState() {
    super.initState();
  }

  Widget dailyQuests(UserData details) {
    if (details.daily > GlobalConstants.dailyGiftFreq) {
      return Chip(
        backgroundColor: Colors.red,
        label: Text(
          "1",
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return SizedBox();
  }

  ///
  Widget numberOfUnreadMessages(List<int> unread) {
    if (unread.isNotEmpty) {
      return Chip(
        backgroundColor: Colors.red,
        label: Text(
          unread.length.toString(),
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return SizedBox();
  }

  ///
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).valueOrNull ?? User.blank();

    ///
    var percentage = 0.0;

    ///
    var currentLevel = 0;

    ///
    var nextExperienceLevel = 1;

    ///
    var currentExperience = 0;

    currentExperience = user.details.xp;
    currentLevel = expToLevel(currentExperience);
    nextExperienceLevel = levelToExp(currentLevel + 1);
    percentage = currentExperience / nextExperienceLevel;

    if (!_loadingAvatar && user.details.picture.isNotEmpty) {
      _avatar = NetworkImage(
          'https://${GlobalConstants.apiHostUrl}${user.details.picture}');
    }

    return Stack(
      children: <Widget>[
        CustomAppBar(Colors.red, Colors.red, _scaffoldKey),
        // Container(
        //   decoration:BoxDecoration(
        //     image: DecorationImage(
        //       image:AssetImage('assets/images/moon_light.jpg'),
        //       fit: BoxFit.fill,
        //     ),
        //   ),
        // ),
        Drawer(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/drawer.jpg'),
                fit: BoxFit.fill,
              ),
            ),
            // color: Colors.black87,
            // alignment: Alignment.center,
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.only(left: 30),
              children: <Widget>[
                Container(
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          !_loadingAvatar
                              ? Container(
                                  height: 70,
                                  width: 70,
                                  child: GestureDetector(
                                    onTap: getImage,
                                    child: CircleAvatar(
                                      backgroundImage: _avatar,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 70,
                                  width: 70,
                                  child: PKUserProfileSkeleton(
                                    isCircularImage: true,
                                    isBottomLinesActive: false,
                                  ),
                                ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              playClick();
                              context.go('/profile');
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      user.details.username,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "  level $currentLevel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 40,
                                  width: 150,
                                  child: LinearPercentIndicator(
                                    lineHeight: 14.0,
                                    percent: percentage,
                                    center: Text(
                                      "${currentExperience.toString()} / ${nextExperienceLevel.toString()}",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    
                                    backgroundColor: Colors.white,
                                    progressColor: Colors.orange,
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.monetization_on,
                                      color: Color(0xffe6a04e),
                                      size: 20,
                                    ),
                                    Text(
                                      " ${user.details.coins}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading: Icon(Icons.portrait, color: GlobalConstants.appFg),
                  title: Text(
                      AppLocalizations.of(context)!.translate('profile'),
                      style: Style.menuTextStyle),
                  onTap: () {
                    playClick();
                    context.go('/profile');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.explore, color: GlobalConstants.appFg),
                  title: Text(
                      AppLocalizations.of(context)!.translate('explore'),
                      style: Style.menuTextStyle),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    // Navigator.pop(context);
                    // ModalRoute.of(context).settings.name == "/poi-map"
                    //     ? log.d("Already on map")
                    //     : Navigator.of(context).pop();
                    playClick();
                    context.go('/poi-map');
                  },
                ),
                Divider(
                  color: Colors.white,
                  endIndent: 30,
                  indent: 0,
                ),
                ListTile(
                  leading: Icon(Icons.widgets, color: GlobalConstants.appFg),
                  title: Text('Inventory', style: Style.menuTextStyle),
                  onTap: () {
                    playClick();
                    context.go('/inventory');
                  },
                ),
                ListTile(
                  leading:
                      Icon(RPGAwesome.forging, color: GlobalConstants.appFg),
                  title: Text('Forge', style: Style.menuTextStyle),
                  onTap: () {
                    playClick();
                    context.go('/forge');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.assignment, color: GlobalConstants.appFg),
                  title: Row(
                    children: <Widget>[
                      Text(
                          AppLocalizations.of(context)!
                              .translate('drawer_quests'),
                          style: Style.menuTextStyle),
                      SizedBox(
                        width: 20,
                      ),
                      dailyQuests(user.details),
                    ],
                  ),
                  onTap: () {
                    playClick();
                    context.go('/questline');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.flag, color: GlobalConstants.appFg),
                  title: Text(
                      AppLocalizations.of(context)!
                          .translate('drawer_my_points'),
                      style: Style.menuTextStyle),
                  onTap: () {
                    playClick();
                    context.go('/places');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.group, color: GlobalConstants.appFg),
                  title: Row(
                    children: <Widget>[
                      Text(
                          AppLocalizations.of(context)!
                              .translate('drawer_friends'),
                          style: Style.menuTextStyle),
                      SizedBox(
                        width: 20,
                      ),
                      numberOfUnreadMessages(user.details.unread),
                    ],
                  ),
                  onTap: () {
                    playClick();
                    // ModalRoute.of(context).settings.name == "/poi-map"
                    //     // ? Navigator.of(context).pushNamed('/friends')
                    //     ? Navigator.of(context).pushNamed('/friends')
                    //     : Navigator.of(context)
                    //         .pushReplacementNamed('/friends');
                    context.go('/friends');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.security, color: GlobalConstants.appFg),
                  title: Text(
                      AppLocalizations.of(context)!
                          .translate('guild_drawer_label'),
                      style: Style.menuTextStyle),
                  onTap: () {
                    playClick();
                    context.go('/group');
                  },
                ),
                Divider(
                  color: Colors.white,
                  endIndent: 30,
                  indent: 0,
                ),
                ListTile(
                  leading: Icon(RPGAwesome.crossed_swords,
                      color: GlobalConstants.appFg),
                  title: Text('Battle Training', style: Style.menuTextStyle),
                  onTap: () {
                    playClick();
                    context.go('/battle');
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.help_outline, color: GlobalConstants.appFg),
                  title: Text(AppLocalizations.of(context)!.translate('help'),
                      style: Style.menuTextStyle),
                  onTap: () {
                    playClick();
                    context.go('/help');
                  },
                ),
                ListTile(
                  leading:
                      Icon(RPGAwesome.repair, color: GlobalConstants.appFg),
                  title: Text("Settings", style: Style.menuTextStyle),
                  onTap: () {
                    playClick();
                    context.push('/settings');
                  },
                ),
                ListTile(
                    leading: Icon(Icons.power_settings_new,
                        color: GlobalConstants.appFg),
                    title: Text(
                        AppLocalizations.of(context)!
                            .translate('drawer_logout'),
                        style: Style.menuTextStyle),
                    onTap: () {
                      playClick();
                      logout();
                    }),
                SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void playClick() {
    FlameAudio.play(
        'sfx/click_${(math.Random.secure().nextInt(3) + 1).toString()}.mp3');
  }

  ///
  Future getImage() async {
    final picker = ImagePicker();
    XFile? pickedFile;
    try {
      pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
      setState(() {
        _loadingAvatar = true;
      });
    } on AppError catch (_) {
      setState(() {
        _loadingAvatar = false;
      });
      return;
    } catch (err) {
      debugPrint('getImage unexpected error: $err');
      setState(() {
        _loadingAvatar = false;
      });
      return;
    }

    if (pickedFile == null) {
      setState(() {
        _loadingAvatar = false;
      });
      return;
    }

    try {
      final response =
          await _apiProvider.updateProfilePicture(File(pickedFile.path));
      // _unwrap() already threw on any failure — we're here only on success.
      setState(() {
        _avatar = NetworkImage(response["thumbnail"]);
        _loadingAvatar = false;
      });
      // Refresh user data so picture URL is in sync with server state.
      ref.invalidate(userProvider);
    } on AppError catch (err) {
      err.show(context);
      setState(() {
        _loadingAvatar = false;
      });
    } catch (err) {
      debugPrint('getImage upload unexpected error: $err');
      setState(() {
        _loadingAvatar = false;
      });
    }
  }

  ///
  Future logout() async {
    await CustomInterceptors.deleteStoredCookies(GlobalConstants.apiHostUrl);
    await _storage.delete(key: 'api_key');
    if (!mounted) return;
    context.go('/login');
  }
}
