import 'dart:ui';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:geohunter/screens/group/no_group.dart';

//import 'package:logger/logger.dart';

///
import '../../app_localizations.dart';
import '../../models/guild.dart';
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../providers/custom_interceptors.dart';
import '../../shared/constants.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';
import '../../widgets/network_status_message.dart';

///
class InGroup extends StatefulWidget {
  ///
  final String name = 'in-group';
  @override
  _InGroupState createState() => _InGroupState();
}

class _InGroupState extends State<InGroup> {
  /// Make sure back button is pressed twice
  bool ifPop = false;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _guildNameController = TextEditingController();
  String _guildNameControllerMessage = '';
  bool _showGuildNameError = false;

  /// if the Guild is public or not
  int _isHidden = 0;
  void _isHiddenChanged(bool toggle) {
    if (!toggle) {
      setState(() {
        _isHidden = 0;
      });
      return;
    }
    setState(() {
      _isHidden = 1;
    });
    return;
  }

  /// if the Guild is public or not
  int _isLocked = 0;
  void _isLockedChanged(bool toggle) {
    if (!toggle) {
      setState(() {
        _isLocked = 0;
      });
      return;
    }
    setState(() {
      _isLocked = 1;
    });
    return;
  }

  final _passwordController = TextEditingController();
  String _passwordControllerMessage = '';
  bool _showPasswordError = false;

  /// If the user is this guild's Leader
  bool _isGroupOwner = false;

  final ApiProvider _apiProvider = ApiProvider();

  Guild currentGuild = Guild.blank();
  String guildUid = "Unique ID";

  /// Curent loggedin user
  User _user = User.blank();

  //final Logger log = Logger(
  //    printer: PrettyPrinter(
  //        colors: true, printEmojis: true, printTime: true, lineLength: 80));

  @override
  void initState() {
    super.initState();
    _getGuildDetails();
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
      if (_scaffoldKey != null) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(GlobalConstants.backButtonPage);
      }
    }
    return true;
  }

  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    // Button to save and update the guild's details
    final saveButton = Padding(
      padding: EdgeInsets.all(0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(16),
          backgroundColor: GlobalConstants.appBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(width: 1, color: Colors.white),
        ),
        onPressed: _saveGuildDetails,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.check, color: Color(0xffe6a04e)),
            Text(
              'Save',
              style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    // Button to delete the guild and all members associated with it
    final deleteButton = Padding(
      padding: EdgeInsets.all(0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(16),
          backgroundColor: GlobalConstants.appBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(width: 1, color: Colors.white),
        ),
        onPressed: () {
          _confirmDelete(_scaffoldKey.currentContext);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.delete_outline, color: Color(0xffe6a04e)),
            Text(
              "Delete",
              style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    final leaveButton = Padding(
      padding: EdgeInsets.all(0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(16),
          backgroundColor: GlobalConstants.appBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(width: 1, color: Colors.white),
        ),
        onPressed: () {
          _confirmLeave(_scaffoldKey.currentContext!);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.undo, color: Color(0xffe6a04e)),
            Text(
              "Leave Guild",
              style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    final browseButton = Padding(
      padding: EdgeInsets.all(0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(16),
          backgroundColor: GlobalConstants.appBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(width: 1, color: Colors.white),
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NoGroup()));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.list, color: Color(0xffe6a04e)),
            Text(
              "Browse",
              style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    /// Application top Bar
    final topBar = AppBar(
      leading: IconButton(
        color: GlobalConstants.appFg,
        icon: Icon(
          Icons.menu,
          // size: 32,
        ),
        onPressed: () => _scaffoldKey != null
            ? _scaffoldKey.currentState?.openDrawer()
            : Navigator.of(context).pop(),
      ),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text("Guild - ${guildUid}",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Cormorant SC",
            fontWeight: FontWeight.bold,
          )),
    );

    return Scaffold(
      backgroundColor: GlobalConstants.appBg,
      resizeToAvoidBottomInset: false,
      appBar: topBar,
      body: OfflineBuilder(
        connectivityBuilder: (
          context,
          connectivity,
          child,
        ) {
          if (connectivity == ConnectivityResult.none) {
            return Stack(children: <Widget>[
              child,
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                    color: Colors.black.withOpacity(0),
                    // child: child,
                    child: NetworkStatusMessage()),
              )
            ]);
          } else {
            return child;
          }
        },
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/friends.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Column(
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
                          SizedBox(height: 18.0),
                          Text(
                            'Guild name',
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
                                ]),
                          ),
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: TextField(
                                    enabled: _isGroupOwner,
                                    controller: _guildNameController,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Guild Name"),
                                    onSubmitted: (text) {},
                                  ),
                                )
                              ],
                            ),
                          ),
                          if (_showGuildNameError)
                            _showGuildNameError
                                ? Text(
                                    _guildNameControllerMessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontFamily: 'Open Sans',
                                        fontWeight: FontWeight.bold,
                                        shadows: <Shadow>[
                                          Shadow(
                                              offset: Offset(1.0, 1.0),
                                              blurRadius: 3.0,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0))
                                        ]),
                                  )
                                : Text(''),
                          SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Text(
                                'Visibility',
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
                                    ]),
                              ),
                              _isGroupOwner
                                  ? Switch(
                                      value: (_isHidden > 0),
                                      onChanged: _isHiddenChanged,
                                      activeTrackColor: Colors.white,
                                      activeColor: Color(0xffe6a04e),
                                    )
                                  : Row(
                                      children: <Widget>[
                                        Text("  "),
                                        (_isHidden > 0)
                                            ? Icon(Icons.visibility_off,
                                                color: Colors.white)
                                            : Icon(Icons.visibility,
                                                color: Colors.white),
                                        Text("  ")
                                      ],
                                    ),
                              Text(
                                (_isHidden > 0) ? 'Hidden' : 'Public',
                                maxLines: 1,
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
                            ],
                          ),
                          SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Text(
                                'Security',
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
                                    ]),
                              ),
                              _isGroupOwner
                                  ? Switch(
                                      value: (_isLocked > 0),
                                      onChanged: _isLockedChanged,
                                      activeTrackColor: Colors.white,
                                      activeColor: Color(0xffe6a04e),
                                    )
                                  : Row(
                                      children: <Widget>[
                                        Text("  "),
                                        (_isLocked > 0)
                                            ? Icon(Icons.lock_outline,
                                                color: Colors.white)
                                            : Icon(Icons.lock_open,
                                                color: Colors.white),
                                        Text("  ")
                                      ],
                                    ),
                              Text(
                                (_isLocked > 0) ? 'Locked' : 'Open',
                                maxLines: 1,
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
                            ],
                          ),
                          if ((_isLocked > 0) && _isGroupOwner)
                            Text(
                              AppLocalizations.of(context)!
                                  .translate('password_input_label'),
                              semanticsLabel: 'Password',
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
                                  ]),
                            ),
                          if ((_isLocked > 0) && _isGroupOwner)
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Pass"),
                                      onSubmitted: (text) {},
                                    ),
                                  )
                                ],
                              ),
                            ),
                          if ((_isLocked > 0) && _isGroupOwner)
                            _showPasswordError
                                ? Text(
                                    _passwordControllerMessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontFamily: 'Open Sans',
                                        fontWeight: FontWeight.bold,
                                        shadows: <Shadow>[
                                          Shadow(
                                              offset: Offset(1.0, 1.0),
                                              blurRadius: 3.0,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0))
                                        ]),
                                  )
                                : Text(''),
                          SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              browseButton,
                              _isGroupOwner ? saveButton : leaveButton,
                              if (_isGroupOwner)
                                Center(
                                  child: deleteButton,
                                )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }

  void _getGuildDetails() async {
    final user = await _apiProvider.getStoredUser();

    if (user.details.guildId == "0") {
      Navigator.of(context).pop();
      return;
    }

    try {
      dynamic response =
          await _apiProvider.get("/guild/${user.details.guildId}");

      if (response["guilds"].isEmpty) {
        _user = user;
        _user.details.guildId = '0';
        await CustomInterceptors.setStoredCookies(
            GlobalConstants.apiHostUrl, _user.toMap());
      } else if (response["guilds"][0] != null) {
        setState(() {
          _user = user;
          currentGuild = Guild.fromJson(response["guilds"][0]);
          guildUid = currentGuild.guid;
          _isHidden = currentGuild.isHidden;
          _isLocked = currentGuild.isLocked;
          _passwordController.text = "";
          _isGroupOwner = response["guilds"][0]["leader_id"] == user.details.id;
          _guildNameController.text = currentGuild.name;
        });
      }
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Forgot password',
          description: err.response?.data["message"],
          buttonText: "Okay",
          images: [],
          callback: () {},
        ),
      );
    }

    //log.d('--- currentGuild ---');
    //log.d(currentGuild.guid);
  }

  void _saveGuildDetails() async {
    _showGuildNameError = false;
    if (_guildNameController.text.isEmpty) {
      setState(() {
        _guildNameControllerMessage = 'Please choose a guild name';
        _showGuildNameError = true;
      });
      return;
    }
    _showPasswordError = false;
    if ((_isLocked > 0) && _passwordController.text.isEmpty) {
      setState(() {
        _passwordControllerMessage = 'Please enter a password';
        _showPasswordError = true;
      });
      return;
    }
    try {
      var data = {
        "guild_id": currentGuild.id,
        "name": _guildNameController.text,
        "is_hidden": _isHidden,
        "is_locked": _isLocked,
      };
      if ((_isLocked > 0) && _passwordController.text != "") {
        data["password"] = _passwordController.text;
      }
      final response = await _apiProvider.put("/guild", data);

      // if (_image != null) {
      //   try {
      //     await _apiProvider.uploadPicture('/emblem', 'emblemfile', 'guild_id',
      //         _image, int.parse(addGuild["guild_id"].toString()));
      //   } on DioError catch (err) {
      //     log.e(err.response);
      //   }
      // }

      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: AppLocalizations.of(context)!.translate('congrats'),
          description: response["message"],
          buttonText: "Okay",
          images: [],
          callback: () {},
        ),
      );
      // _images.clear();
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
      //log.e(err.response);
    }
  }

  void _confirmDelete(BuildContext? context) {
    showDialog<void>(
      context: context!,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Please confirm",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Cormorant SC',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this Guild?",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Open Sans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.9),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: GlobalConstants.appBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                side: BorderSide(width: 1, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.close, color: Color(0xffe6a04e)),
                  Text(
                    " No",
                    style: TextStyle(
                        color: Color(0xffe6a04e),
                        fontSize: 18,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: GlobalConstants.appBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                side: BorderSide(width: 1, color: Colors.white),
              ),
              onPressed: () {
                _deleteGuild(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.done, color: Color(0xffe6a04e)),
                  Text(
                    " Yes",
                    style: TextStyle(
                        color: Color(0xffe6a04e),
                        fontSize: 18,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmLeave(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Please confirm",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Cormorant SC',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to leave this Guild?",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Open Sans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.9),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: GlobalConstants.appBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                side: BorderSide(width: 1, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.close, color: Color(0xffe6a04e)),
                  Text(
                    " No",
                    style: TextStyle(
                        color: Color(0xffe6a04e),
                        fontSize: 18,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: GlobalConstants.appBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                side: BorderSide(width: 1, color: Colors.white),
              ),
              onPressed: () {
                _unjoinGuild(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.done, color: Color(0xffe6a04e)),
                  Text(
                    " Yes",
                    style: TextStyle(
                        color: Color(0xffe6a04e),
                        fontSize: 18,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteGuild(BuildContext context) async {
    try {
      final response =
          await _apiProvider.delete("/guild/${currentGuild.id}", {});

      if (response["success"] == true) {
        _user.details.guildId = '0';
        await CustomInterceptors.setStoredCookies(
            GlobalConstants.apiHostUrl, _user.toMap());
      }

      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: AppLocalizations.of(context)!.translate('congrats'),
          description: response["message"],
          buttonText: "Okay",
          images: [],
          callback: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/no-group');
          },
        ),
      );
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
      //log.e(err.response);
    }
  }

  void _unjoinGuild(BuildContext context) async {
    try {
      final response = await _apiProvider
          .delete("/membership/${currentGuild.id}/${_user.details.id}", {});

      if (response["success"] == true) {
        _user.details.guildId = '0';
        await CustomInterceptors.setStoredCookies(
            GlobalConstants.apiHostUrl, _user.toMap());
      }

      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: AppLocalizations.of(context)!.translate('congrats'),
          description: response["message"],
          buttonText: "Okay",
          images: [],
          callback: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/no-group');
          },
        ),
      );
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
      //log.e(err.response);
    }
  }
}
