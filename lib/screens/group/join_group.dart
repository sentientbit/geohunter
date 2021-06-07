///
import 'dart:ui';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geohunter/screens/group/no_group.dart';
// import 'package:logger/logger.dart';

///
import '../../app_localizations.dart';
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../providers/custom_interceptors.dart';
import '../../shared/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dialog.dart';

///
class JoinGroup extends StatefulWidget {
  ///
  static String tag = 'join-group';

  ///
  String guid = "";

  ///
  int isLocked = 0;

  ///
  String title = "";

  ///
  JoinGroup({
    Key? key,
    required this.guid,
    required this.isLocked,
    required this.title,
  }) : super(key: key);

  @override
  _JoinGroupState createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroup> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ApiProvider _apiProvider = ApiProvider();

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  final _guildUidController = TextEditingController();
  String _guildUidControllerMessage = '';
  bool _showGuildUidError = false;

  /// if the Guild is public or not
  bool _isLocked = false;
  void _isLockedChanged(bool value) => setState(() => _isLocked = value);

  final _passwordController = TextEditingController();
  String _passwordControllerMessage = '';
  bool _showPasswordError = false;

  String pageTitle = "Join Guild";

  /// Curent loggedin user
  User _user = User.blank();

  @override
  void initState() {
    super.initState();
    _guildUidController.text = widget.guid;
    if (widget.isLocked > 0) {
      _isLocked = true;
    }
    if (widget.title != "") {
      pageTitle = widget.title;
    }
    _getUserDetails();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  // ignore: avoid_positional_boolean_parameters
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.of(context).pop();
    return true;
  }

  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    final joinButton = Padding(
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
        onPressed: () => _joinGuild(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.close, color: Color(0xffe6a04e)),
            Text(
              'Join',
              style: TextStyle(
                  color: Color(0xffe6a04e),
                  fontSize: 18,
                  fontFamily: 'Cormorant SC',
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    final cancelButton = TextButton(
      child: Text(
        'Cancel',
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
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoGroup(),
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/inn.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Column(
            children: <Widget>[
              ConstrainedBox(
                // height: 0,
                constraints: BoxConstraints(maxHeight: 80),
                child: CustomAppBar(
                  Colors.white,
                  Colors.white,
                  _scaffoldKey,
                  icon: Icon(Icons.arrow_back),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    height: deviceSize.height,
                    width: deviceSize.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          //flex: deviceSize.width > 600 ? 2 : 1,
                          child: Center(
                            child: ListView(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.only(left: 24.0, right: 24.0),
                              children: <Widget>[
                                Text(
                                  pageTitle,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontFamily: 'Cormorant SC',
                                    fontWeight: FontWeight.bold,
                                    shadows: <Shadow>[
                                      Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(255, 0, 0, 0))
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24.0),
                                Text(
                                  "To join a guild you have to know the "
                                  "guild's id, and be approved.",
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
                                SizedBox(height: 24.0),
                                Text(
                                  'Guild Unique ID',
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: _guildUidController,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Guild Unique ID"),
                                          onSubmitted: (text) {},
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                _showGuildUidError
                                    ? Text(
                                        _guildUidControllerMessage,
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                            fontFamily: 'Open Sans',
                                            fontWeight: FontWeight.bold,
                                            shadows: <Shadow>[
                                              Shadow(
                                                  offset: Offset(1.0, 1.0),
                                                  blurRadius: 3.0,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0))
                                            ]),
                                      )
                                    : Text(''),
                                Text(
                                  'I have a password',
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
                                Row(
                                  children: <Widget>[
                                    Switch(
                                      value: _isLocked,
                                      onChanged: _isLockedChanged,
                                      activeTrackColor: Colors.white,
                                      activeColor: Color(0xffe6a04e),
                                    ),
                                    Text(
                                      _isLocked ? 'Locked' : 'Open',
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
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (_isLocked)
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
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0))
                                        ]),
                                  ),
                                if (_isLocked)
                                  Card(
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
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
                                if (_isLocked)
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
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0))
                                              ]),
                                        )
                                      : Text(''),
                                SizedBox(height: 24.0),
                                joinButton,
                                SizedBox(width: 105),
                                cancelButton
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _getUserDetails() async {
    final tmp = await _apiProvider.getStoredUser();
    setState(() {
      _user = tmp;
    });
    await CustomInterceptors.setStoredCookies(
        GlobalConstants.apiHostUrl, _user.toMap());
  }

  /// 5556665 should pass
  bool isValidGuid(String guid) {
    return guildIdOfflineValidation(guid);
  }

  void _joinGuild(BuildContext context) async {
    _showGuildUidError = false;
    if (_guildUidController.text.isEmpty) {
      setState(() {
        _guildUidControllerMessage = 'Please enter a Guild Unique ID';
        _showGuildUidError = true;
      });
      return;
    }
    if (!isValidGuid(_guildUidController.text)) {
      setState(() {
        _guildUidControllerMessage = 'Please enter a valid Guild Unique ID';
        _showGuildUidError = true;
      });
      return;
    }
    if (_isLocked && _passwordController.text.isEmpty) {
      setState(() {
        _passwordControllerMessage = 'Please enter a Password';
        _showPasswordError = true;
      });
      return;
    }
    try {
      var data = {"guid": _guildUidController.text};
      if (_isLocked && _passwordController.text.isNotEmpty) {
        data["password"] = _passwordController.text;
      }
      dynamic response = await _apiProvider.post('/membership', data);

      if (int.parse(response["guild_id"] ?? 0) > 0) {
        _user.details.guildId = response["guild_id"].toString();
        await CustomInterceptors.setStoredCookies(
            GlobalConstants.apiHostUrl, _user.toMap());

        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: AppLocalizations.of(context)!.translate('congrats'),
            description: response["message"],
            buttonText: "Okay",
            images: [],
            callback: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/in-group');
            },
          ),
        );
      }
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
    }
  }
}
