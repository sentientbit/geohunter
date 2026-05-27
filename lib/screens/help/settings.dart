///
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//import 'package:logger/logger.dart';

///
import '../../app_localizations.dart';
import '../../models/app_error.dart';
import '../../models/player_stats.dart';
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../providers/custom_interceptors.dart';
import '../../providers/stream_userdata.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

///
class SettingsPage extends StatefulWidget {
  ///
  final String name = "settings";

  ///
  SettingsPage({
    Key? key,
  }) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

///
class _SettingsState extends State<SettingsPage> {
  ///
  final _userdata = getIt.get<StreamUserData>();

  ///
  math.Random rndBattleNumber = math.Random.secure();

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  final ApiProvider _apiProvider = ApiProvider();

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Curent loggedin user
  User _user = User.blank();

  bool _soundsEnabled = false;

  bool _vibrateEnabled = false;

  int notificationLevel = 0;

  int musicLevel = 0;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    /// Application top Bar
    final topBar = AppBar(
      leading: IconButton(
        color: GlobalConstants.appFg,
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          context.pop();
        },
      ),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text(
        "Settings",
        style: Style.topBar,
      ),
    );

    final saveButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: _updateSettings,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.done, color: Color(0xffe6a04e)),
          Text(
            " ${AppLocalizations.of(context)!.translate('save')}",
            style: TextStyle(
              color: Color(0xffe6a04e),
              fontSize: 18,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: GlobalConstants.appBg,
      resizeToAvoidBottomInset: false,
      appBar: topBar,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/closet.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(top: 90.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    // reverse: true,
                    child: Padding(
                      padding:
                          EdgeInsets.only(bottom: bottom, left: 25, right: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: SwitchListTile(
                                  activeTrackColor: Colors.white,
                                  activeThumbColor: Color(0xffe6a04e),
                                  title: const Text(
                                    'Notifications',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Open Sans',
                                      fontWeight: FontWeight.bold,
                                      shadows: <Shadow>[
                                        Shadow(
                                            offset: Offset(1.0, 1.0),
                                            blurRadius: 3.0,
                                            color: Color.fromARGB(255, 0, 0, 0))
                                      ],
                                    ),
                                  ),
                                  value: (notificationLevel > 0),
                                  onChanged: (toggle) {
                                    setState(() {
                                      notificationLevel = (!toggle) ? 0 : 100;
                                    });
                                  },
                                  secondary: Icon(
                                    (notificationLevel > 0)
                                        ? Icons.notifications_none
                                        : Icons.notifications_off_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(),
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: SwitchListTile(
                                  activeTrackColor: Colors.white,
                                  activeThumbColor: Color(0xffe6a04e),
                                  title: const Text(
                                    'Sounds',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Open Sans',
                                      fontWeight: FontWeight.bold,
                                      shadows: <Shadow>[
                                        Shadow(
                                            offset: Offset(1.0, 1.0),
                                            blurRadius: 3.0,
                                            color: Color.fromARGB(255, 0, 0, 0))
                                      ],
                                    ),
                                  ),
                                  value: _soundsEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _soundsEnabled = value;
                                    });
                                  },
                                  secondary: const Icon(Icons.volume_down,
                                      color: Colors.white),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(),
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: SwitchListTile(
                                  activeTrackColor: Colors.white,
                                  activeThumbColor: Color(0xffe6a04e),
                                  title: const Text(
                                    'Music',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Open Sans',
                                      fontWeight: FontWeight.bold,
                                      shadows: <Shadow>[
                                        Shadow(
                                            offset: Offset(1.0, 1.0),
                                            blurRadius: 3.0,
                                            color: Color.fromARGB(255, 0, 0, 0))
                                      ],
                                    ),
                                  ),
                                  value: (musicLevel > 0),
                                  onChanged: (toggle) {
                                    setState(() {
                                      musicLevel = (!toggle) ? 0 : 100;
                                    });
                                  },
                                  secondary: Icon(
                                    (musicLevel > 0)
                                        ? Icons.music_note
                                        : Icons.music_off,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(),
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: SwitchListTile(
                                  activeTrackColor: Colors.white,
                                  activeThumbColor: Color(0xffe6a04e),
                                  title: const Text(
                                    'Vibrate',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Open Sans',
                                      fontWeight: FontWeight.bold,
                                      shadows: <Shadow>[
                                        Shadow(
                                            offset: Offset(1.0, 1.0),
                                            blurRadius: 3.0,
                                            color: Color.fromARGB(255, 0, 0, 0))
                                      ],
                                    ),
                                  ),
                                  value: _vibrateEnabled,
                                  onChanged: (toggle) {
                                    setState(() {
                                      _vibrateEnabled = toggle;
                                    });
                                  },
                                  secondary: const Icon(Icons.vibration,
                                      color: Colors.white),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(),
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[saveButton],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }

  void _updateSettings() async {
    _user.details.settings = PlayerSettings(
      music: musicLevel,
      notifications: notificationLevel,
      sounds: _soundsEnabled ? 100 : 0,
      vibrate: _vibrateEnabled ? 1 : 0,
    );

    CustomInterceptors.setStoredCookies(
        GlobalConstants.apiHostUrl, _user.toMap());

    try {
      await ApiProvider().put('/settings', {
        "music": _user.details.settings.music,
        "notification": _user.details.settings.notifications,
        "sounds": _user.details.settings.sounds,
        "vibrate": _user.details.settings.vibrate,
      });
    } on AppError catch (err) {
      err.show(context);
    } catch (err) {
      debugPrint('_updateSettings unexpected error: $err');
    }

    // update global data
    _userdata.updateUserData(
      'settings',
      _user.details.coins,
      _user.details.mining,
      _user.details.guildId,
      _user.details.xp,
      _user.details.unread,
      _user.details.attack,
      _user.details.defense,
      _user.details.daily,
      _user.details.settings,
      _user.details.costs,
    );

    if (mounted) context.pop();
  }

  ///
  void _getUserDetails() async {
    /// populate initial data from cookies
    _user = await ApiProvider().getStoredUser();

    dynamic response;
    try {
      response = await _apiProvider.get("/equipment");
    } on AppError catch (err) {
      err.show(context);
      return;
    } catch (err) {
      debugPrint('_getUserDetails unexpected error: $err');
      return;
    }

    // update local data
    _user.details.coins = double.tryParse(response["coins"].toString()) ?? 0.0;
    _user.details.guildId = (response["guild"]?["id"] ?? '0').toString();
    _user.details.mining = response["mining"];
    _user.details.xp = response["xp"];
    _user.details.unread = ((response["unread"] ?? []) as List).map((e) => (e as num).toInt()).toList();
    _user.details.attack = StatRange.fromList((response["attack"] ?? []) as List);
    _user.details.defense = StatRange.fromList((response["defense"] ?? []) as List);
    _user.details.daily = response["daily"];
    if (response is Map && response.containsKey("settings")) {
      _user.details.settings = PlayerSettings.fromList((response["settings"] ?? [0, 0, 0]) as List);
    } else {
      _user.details.settings = PlayerSettings(
        music: musicLevel,
        notifications: notificationLevel,
        sounds: _soundsEnabled ? 100 : 0,
        vibrate: _vibrateEnabled ? 1 : 0,
      );
    }
    _user.details.costs = ActionCosts.fromList((response["costs"] ?? [0.1, 0.1, 0.1]) as List);

    // update global data
    _userdata.updateUserData(
      'settings2',
      _user.details.coins,
      _user.details.mining,
      _user.details.guildId,
      _user.details.xp,
      _user.details.unread,
      _user.details.attack,
      _user.details.defense,
      _user.details.daily,
      _user.details.settings,
      _user.details.costs,
    );

    setState(() {
      musicLevel = _user.details.settings.music;
      notificationLevel = _user.details.settings.notifications;
      _soundsEnabled = _user.details.settings.isSoundsOn;
      _vibrateEnabled = _user.details.settings.isVibrateOn;
    });

    return;
  }
}
