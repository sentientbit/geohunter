///
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

//import 'package:logger/logger.dart';

///
import '../../app_localizations.dart';
import '../../fonts/rpg_awesome_icons.dart';
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../providers/custom_interceptors.dart';
import '../../providers/stream_userdata.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
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

  /// Make sure back button is pressed twice
  bool ifPop = false;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Curent loggedin user
  User _user = User.blank();

  bool _lights = false;

  int musicLevel = 100;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    BackButtonInterceptor.add(myInterceptor,
        name: widget.name, context: context);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  // ignore: avoid_positional_boolean_parameters
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (stopDefaultButtonEvent) return false;
    if (ifPop) {
      return false;
    } else {
      setState(() => ifPop = true);
      Navigator.of(context).pop();
    }
    return true;
  }

  Widget build(BuildContext context) {
    var szHeight = MediaQuery.of(context).size.height;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    /// Application top Bar
    final topBar = AppBar(
      brightness: Brightness.dark,
      leading: IconButton(
        color: GlobalConstants.appFg,
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
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
                                flex: 1,
                                child: SizedBox(),
                              ),
                              Expanded(
                                flex: 10,
                                child: SwitchListTile(
                                  activeTrackColor: Colors.black,
                                  activeColor: Colors.black,
                                  inactiveThumbColor: Colors.black,
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
                                  value: _lights,
                                  onChanged: (value) {
                                    setState(() {
                                      _lights = value;
                                    });
                                  },
                                  secondary: const Icon(
                                      Icons.notifications_none,
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
                                flex: 1,
                                child: SizedBox(),
                              ),
                              Expanded(
                                flex: 10,
                                child: SwitchListTile(
                                  activeTrackColor: Colors.black,
                                  activeColor: Colors.black,
                                  inactiveThumbColor: Colors.black,
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
                                  value: _lights,
                                  onChanged: (value) {
                                    setState(() {
                                      _lights = value;
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
                                flex: 1,
                                child: SizedBox(),
                              ),
                              Expanded(
                                flex: 10,
                                child: SwitchListTile(
                                  activeTrackColor: Colors.white,
                                  activeColor: Color(0xffe6a04e),
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
                                flex: 1,
                                child: SizedBox(),
                              ),
                              Expanded(
                                flex: 10,
                                child: SwitchListTile(
                                  activeTrackColor: Colors.black,
                                  activeColor: Colors.black,
                                  inactiveThumbColor: Colors.black,
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
                                  value: _lights,
                                  onChanged: (value) {
                                    setState(() {
                                      _lights = value;
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
    _user.details.music = musicLevel;

    CustomInterceptors.setStoredCookies(
        GlobalConstants.apiHostUrl, _user.toMap());

    // update global data
    _userdata.updateUserData(
      _user.details.coins,
      0,
      _user.details.guildId,
      _user.details.xp,
      _user.details.unread,
      _user.details.attack,
      _user.details.defense,
      _user.details.daily,
      _user.details.music,
    );

    Navigator.of(context).pop();
  }

  ///
  void _getUserDetails() async {
    /// populate initial data from cookies
    _user = await ApiProvider().getStoredUser();

    dynamic response;
    try {
      response = await _apiProvider.get("/equipment");
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description: err.response?.data["message"],
          buttonText: "Okay",
          images: [],
          callback: () {},
        ),
      );
      return;
    }

    // update local data
    _user.details.coins = double.tryParse(response["coins"].toString()) ?? 0.0;
    _user.details.guildId = response["guild"]["id"];
    _user.details.xp = response["xp"];
    _user.details.unread = response["unread"];
    _user.details.attack = response["attack"];
    _user.details.defense = response["defense"];
    _user.details.daily = response["daily"];

    // update global data
    _userdata.updateUserData(
      _user.details.coins,
      0,
      _user.details.guildId,
      _user.details.xp,
      _user.details.unread,
      _user.details.attack,
      _user.details.defense,
      _user.details.daily,
      _user.details.music,
    );

    print('111');
    print(_user.details);
    setState(() {
      /// update controller data
      musicLevel = _user.details.music;
    });

    return;
  }
}
