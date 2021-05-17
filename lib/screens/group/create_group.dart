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
class CreateGroup extends StatefulWidget {
  ///
  static String tag = 'create-group';
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final ApiProvider _apiProvider = ApiProvider();

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  final _groupNameController = TextEditingController();
  String _groupNameControllerMessage = '';
  bool _showGroupNameError = false;

  /// if the Guild is public or not
  bool _isHidden = false;
  void _isHiddenChanged(bool value) => setState(() => _isHidden = value);

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
    BackButtonInterceptor.add(myInterceptor, zIndex: 2, name: "SomeName");
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _passwordController.dispose();
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

    final createButton = Padding(
      padding: EdgeInsets.all(0),
      child: RaisedButton(
        shape: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
          borderRadius: BorderRadius.circular(10),
        ),
        onPressed: () => _addGuild(context),
        padding: EdgeInsets.all(16),
        color: Colors.black,
        child: Text(
          'Create',
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
                                  'Create a new guild',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
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
                                  'Guild Name',
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
                                          controller: _groupNameController,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Guild Name"),
                                          onSubmitted: (text) {},
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                _showGroupNameError
                                    ? Text(
                                        _groupNameControllerMessage,
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
                                  'Will it be public ?',
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
                                      value: _isHidden,
                                      onChanged: _isHiddenChanged,
                                      activeTrackColor: Colors.white,
                                      activeColor: Color(0xffe6a04e),
                                    ),
                                    Text(
                                      _isHidden ? 'Hidden' : 'Public',
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
                                Text(
                                  'Will it be locked with a password ?',
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
                                createButton,
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

  void _addGuild(BuildContext context) async {
    _showGroupNameError = false;
    if (_groupNameController.text.isEmpty) {
      setState(() {
        _groupNameControllerMessage = 'Please choose a guild name';
        _showGroupNameError = true;
      });
      return;
    }

    _showPasswordError = false;
    if (_isLocked) {
      if (_passwordController.text.isEmpty) {
        setState(() {
          _passwordControllerMessage = 'Please fill a password';
          _showPasswordError = true;
        });
        return;
      }
    }

    try {
      final response = await _apiProvider.post('/guild', {
        "name": _groupNameController.text,
        "is_hidden": _isHidden ? "1" : "0",
        "is_locked": _isLocked ? "1" : "0",
        "password": _passwordController.text
      });

      if (response["success"] == true) {
        _user.details.guildId = response["guild_id"].toString();
        await CustomInterceptors.setStoredCookies(
            GlobalConstants.apiHostUrl, _user.toMap());
      }

      _groupNameController.text = "";
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
      // _images.clear();
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description: err.response?.data["message"],
          buttonText: "Okay",
        ),
      );
      //log.e(err.response);
    }
  }
}
