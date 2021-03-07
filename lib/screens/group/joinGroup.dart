///
import 'dart:ui';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
  @override
  _JoinGroupState createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroup> {
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

  /// Curent loggedin user
  User _user;

  @override
  void initState() {
    super.initState();
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
      child: RaisedButton(
        shape: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
          borderRadius: BorderRadius.circular(10),
        ),
        onPressed: () => _joinGuild(context),
        padding: EdgeInsets.all(16),
        color: Colors.black,
        child: Text(
          'Join',
          style: TextStyle(
              color: Color(0xffe6a04e),
              fontSize: 18,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.bold),
        ),
      ),
    );

    final cancelButton = FlatButton(
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
                image: AssetImage('assets/images/bar.jpg'),
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
                    null,
                    icon: Icon(Icons.arrow_back),
                  )),
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
                          // flex: deviceSize.width > 600 ? 2 : 1,
                          child: Center(
                            child: ListView(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.only(left: 24.0, right: 24.0),
                              children: <Widget>[
                                Text(
                                  'Join existing guild',
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
                                  'To join an existing guild you have to know the guild\'s unique id and be accepted by the leader.',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
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
                                    AppLocalizations.of(context)
                                        .translate('your_password_input_label'),
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
    if (guid.length != 7) {
      return false;
    }

    var bits = List(6);
    bits[0] = int.parse(guid[0]) * 4;
    bits[1] = int.parse(guid[1]) * 6;
    bits[2] = int.parse(guid[2]) * 7;
    bits[3] = int.parse(guid[3]) * 9;
    bits[4] = int.parse(guid[4]) * 2;
    bits[5] = int.parse(guid[5]) * 5;

    var sum = bits[0] + bits[1] + bits[2] + bits[3] + bits[4] + bits[5];
    var ck = sum % 11;
    if (ck == 10) {
      ck = 1;
    }
    if (ck != int.parse(guid[6])) {
      return false;
    }
    return true;
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
        _user.details.guild.id = response["guild_id"];
        _user.details.guild.permissions = "0";
        await CustomInterceptors.setStoredCookies(
            GlobalConstants.apiHostUrl, _user.toMap());

        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: AppLocalizations.of(context).translate('congrats'),
            description: response["message"],
            buttonText: "Okay",
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
        ),
      );
    }
  }
}
