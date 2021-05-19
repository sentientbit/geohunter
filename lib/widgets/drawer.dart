///
import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:logger/logger.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:image_picker/image_picker.dart';

///
import '../app_localizations.dart';
import '../libraries/pk_skeleton.dart';
import '../models/user.dart';
import '../providers/api_provider.dart';
import '../providers/custom_interceptors.dart';
import '../shared/constants.dart';
import '../text_style.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_dialog.dart';

///
GetIt getIt = GetIt.instance;

///
class DrawerPage extends StatefulWidget {
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  /// Curent loggedin user
  User _user;

  final _storage = FlutterSecureStorage();

  /// Safe holding for coins
  double _currentCoins = 0.0;

  final ApiProvider _apiProvider = ApiProvider();
  ImageProvider _avatar = AssetImage("assets/images/avatars/default01.jpg");

  bool _loadingAvatar = true;

  void loadUser() async {
    final tmp = await _apiProvider.getStoredUser();

    setState(() {
      _user = tmp;
      _currentCoins = tmp.details.coins;
      _loadingAvatar = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  ///
  Widget build(BuildContext context) {
    ///
    var username = 'Guest';

    ///
    //var status = 'Undefined';

    ///
    var percentage = 0.0;

    ///
    var currentLevel = 0;

    ///
    var nextExperienceLevel = 1;

    ///
    var currentExperience = 0;

    if (_user != null && _user.details != null) {
      username = _user.details.username;
      currentExperience = int.tryParse(_user.details.experience) ?? 0;
      currentLevel = expToLevel(currentExperience);
      nextExperienceLevel = levelToExp(currentLevel + 1);
      percentage =
          (int.tryParse(_user.details.experience) ?? 0) / nextExperienceLevel;
      //status = _user.details.status;

      _avatar = CachedNetworkImageProvider(
          'https://${GlobalConstants.apiHostUrl}${_user.details.picture}');
    }

    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
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
                              Navigator.of(context).pop();
                              Navigator.of(context)
                                  .pushReplacementNamed('/profile');
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      username,
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
                                    linearStrokeCap: LinearStrokeCap.roundAll,
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
                                      " $_currentCoins",
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
                  title: Text(AppLocalizations.of(context).translate('profile'),
                      style: Style.menuTextStyle),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/profile');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.explore, color: GlobalConstants.appFg),
                  title: Text(AppLocalizations.of(context).translate('explore'),
                      style: Style.menuTextStyle),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    // Navigator.pop(context);
                    // ModalRoute.of(context).settings.name == "/poi-map"
                    //     ? log.d("Already on map")
                    //     : Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/poi-map');
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
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/inventory');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.gavel, color: GlobalConstants.appFg),
                  title: Text('Forge', style: Style.menuTextStyle),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/forge');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.assignment, color: GlobalConstants.appFg),
                  title: Text(
                      AppLocalizations.of(context).translate('drawer_quests'),
                      style: Style.menuTextStyle),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.of(context).pop();

                    Navigator.of(context).pushReplacementNamed('/questline');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.flag, color: GlobalConstants.appFg),
                  title: Text(
                      AppLocalizations.of(context)
                          .translate('drawer_my_points'),
                      style: Style.menuTextStyle),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/places');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.group, color: GlobalConstants.appFg),
                  title: Text(
                      AppLocalizations.of(context).translate('drawer_friends'),
                      style: Style.menuTextStyle),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.of(context).pop();
                    // ModalRoute.of(context).settings.name == "/poi-map"
                    //     // ? Navigator.of(context).pushNamed('/friends')
                    //     ? Navigator.of(context).pushNamed('/friends')
                    //     : Navigator.of(context)
                    //         .pushReplacementNamed('/friends');
                    Navigator.of(context).pushReplacementNamed('/friends');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.security, color: GlobalConstants.appFg),
                  title: Row(children: <Widget>[
                    Text(
                        AppLocalizations.of(context)
                            .translate('guild_drawer_label'),
                        style: Style.menuTextStyle),
                    SizedBox(
                      width: 20,
                    ),
                    if (_user != null)
                      if (_user.details.unnaprovedMembers > 0)
                        Chip(
                          backgroundColor: Colors.red,
                          label: Text(
                            _user.details.unnaprovedMembers.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                  ]),
                  onTap: () async {
                    if (_user.details.unnaprovedMembers > 0) {
                      _user.details.unnaprovedMembers = 0;
                      await CustomInterceptors.setStoredCookies(
                          GlobalConstants.apiHostUrl, _user.toMap());
                    }
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/group');
                  },
                ),
                Divider(
                  color: Colors.white,
                  endIndent: 30,
                  indent: 0,
                ),
                ListTile(
                  leading:
                      Icon(Icons.help_outline, color: GlobalConstants.appFg),
                  title: Text(AppLocalizations.of(context).translate('help'),
                      style: Style.menuTextStyle),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/help');
                  },
                ),
                ListTile(
                    leading: Icon(Icons.power_settings_new,
                        color: GlobalConstants.appFg),
                    title: Text(
                        AppLocalizations.of(context).translate('drawer_logout'),
                        style: Style.menuTextStyle),
                    onTap: () async => {
                          // Logout
                          await CustomInterceptors.deleteStoredCookies(
                              GlobalConstants.apiHostUrl),
                          await _storage.delete(key: 'api_key'),
                          Navigator.of(context).pop(),
                          Navigator.of(context).pushReplacementNamed('/login')
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

  ///
  Future getImage() async {
    final picker = ImagePicker();
    PickedFile pickedFile;
    try {
      pickedFile =
          await picker.getImage(source: ImageSource.gallery, imageQuality: 100);
      setState(() {
        _loadingAvatar = true;
      });
    } on DioError catch (e) {
      //print(e.message);
      setState(() {
        _loadingAvatar = false;
      });
    }

    if (pickedFile == null) {
      _loadingAvatar = false;
      return;
    }

    dynamic response =
        await _apiProvider.updateProfilePicture(File(pickedFile.path));

    if (response["success"] != true) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description: '${response['message']}',
          buttonText: "Okay",
        ),
      );
      setState(() {
        _avatar = AssetImage("assets/images/avatars/default01.jpg");
        _loadingAvatar = false;
      });
      return;
    }

    _user.details.picture = response["thumbnail"];
    await CustomInterceptors.setStoredCookies(
        GlobalConstants.apiHostUrl, _user.toMap());
    setState(() {
      _avatar = CachedNetworkImageProvider(response["thumbnail"]);
      _loadingAvatar = false;
    });
    return;
  }
}
