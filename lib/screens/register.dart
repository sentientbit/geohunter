///
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:geohunter/shared/constants.dart';

///
import '../app_localizations.dart';
import '../providers/api_provider.dart';
import '../shared/constants.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/network_status_message.dart';

///
class RegisterPage extends StatefulWidget {
  ///
  static String tag = 'login-page';
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _acceptedTerms = false;
  void _acceptedTermsChanged(bool value) =>
      setState(() => _acceptedTerms = value);
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _retypePasswordController = TextEditingController();
  String _emailControllerMessage = '';
  String _usernameControllerMessage = '';
  String _passwordControllerMessage = '';
  String _retypePasswordControllerMessage = '';
  String _showAcceptedTermsMessage = '';

  bool _showEmailError = false;
  bool _showUsernameError = false;
  bool _showPasswordError = false;
  bool _showRetypePasswordError = false;

  @override
  void initState() {
    super.initState();
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
    final registerButton = Padding(
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
        onPressed: _register,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.shopping_cart, color: Color(0xffe6a04e)),
            Text(
              AppLocalizations.of(context).translate('register_submit_btn'),
              style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 16,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    final forgotLabel = TextButton(
      child: Text(
        AppLocalizations.of(context).translate('register_back_btn'),
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

    final topBar = AppBar(
      backgroundColor: Colors.transparent,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      //appBar: topBar,
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
        child: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/blacksmith_hammer.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Center(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)
                      .translate('register_title_label'),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold,
                      shadows: <Shadow>[
                        Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Color.fromARGB(255, 0, 0, 0))
                      ]),
                ),
                SizedBox(height: 16.0),
                Text(
                  AppLocalizations.of(context)
                      .translate('register_username_label'),
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
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: AppLocalizations.of(context)
                                  .translate('register_username_label')),
                          onSubmitted: (text) {},
                        ),
                      )
                    ],
                  ),
                ),
                _showUsernameError
                    ? Text(
                        _usernameControllerMessage,
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.bold,
                            shadows: <Shadow>[
                              Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                  color: Color.fromARGB(255, 0, 0, 0))
                            ]),
                      )
                    : Text(''),
                SizedBox(height: 8.0),
                Text(
                  AppLocalizations.of(context)
                      .translate('register_email_label'),
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
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "john.doe@domain.com"),
                          onSubmitted: (text) {},
                        ),
                      )
                    ],
                  ),
                ),
                _showEmailError
                    ? Text(
                        _emailControllerMessage,
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.bold,
                            shadows: <Shadow>[
                              Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                  color: Color.fromARGB(255, 0, 0, 0))
                            ]),
                      )
                    : Text(''),
                SizedBox(height: 8.0),
                Text(
                  AppLocalizations.of(context)
                      .translate('register_password_label'),
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
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: AppLocalizations.of(context)
                                  .translate('register_password_label')),
                          obscureText: true,
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
                                  color: Color.fromARGB(255, 0, 0, 0))
                            ]),
                      )
                    : Text(''),
                SizedBox(height: 8.0),
                Text(
                  AppLocalizations.of(context)
                      .translate('register_confirm_password_label'),
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
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _retypePasswordController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: AppLocalizations.of(context).translate(
                                  'register_confirm_password_label')),
                          obscureText: true,
                          onSubmitted: (text) {},
                        ),
                      )
                    ],
                  ),
                ),
                _showRetypePasswordError
                    ? Text(
                        _retypePasswordControllerMessage,
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.bold,
                            shadows: <Shadow>[
                              Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                  color: Color.fromARGB(255, 0, 0, 0))
                            ]),
                      )
                    : Text(''),
                Row(
                  children: <Widget>[
                    Switch(
                      value: _acceptedTerms,
                      onChanged: _acceptedTermsChanged,
                      activeTrackColor: Colors.white,
                      activeColor: Color(0xffe6a04e),
                    ),
                    GestureDetector(
                      onTap: () => {Navigator.of(context).pushNamed('/terms')},
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('register_terms_label'),
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
                    ),
                  ],
                ),
                _acceptedTerms == false
                    ? Text(
                        _showAcceptedTermsMessage,
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.bold,
                            shadows: <Shadow>[
                              Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                  color: Color.fromARGB(255, 0, 0, 0))
                            ]),
                      )
                    : Text(''),
                registerButton,
                SizedBox(width: 105),
                forgotLabel,
                SizedBox(height: 100),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void _register() async {
    _showEmailError = false;
    _showPasswordError = false;
    _showUsernameError = false;

    if (_usernameController.text.isEmpty) {
      setState(() {
        _usernameControllerMessage = AppLocalizations.of(context)
            .translate('register_fill_username_error');
        _showUsernameError = true;
      });
      return;
    }

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailControllerMessage =
            AppLocalizations.of(context).translate('register_fill_email_error');
        _showEmailError = true;
      });
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordControllerMessage = AppLocalizations.of(context)
            .translate('register_fill_password_error');
        _showPasswordError = true;
      });
      return;
    }
    if (_retypePasswordController.text.isEmpty) {
      setState(() {
        _retypePasswordControllerMessage = AppLocalizations.of(context)
            .translate('register_fill_password_error');
        _showRetypePasswordError = true;
      });
      return;
    }

    if (_passwordController.text != _retypePasswordController.text) {
      setState(() {
        _retypePasswordControllerMessage = AppLocalizations.of(context)
            .translate('register_confirm_password_error');
        _showRetypePasswordError = true;
      });
      return;
    } else {
      _showRetypePasswordError = false;
    }

    if (!_acceptedTerms) {
      //print('Accepted terms not ');
      setState(() {
        _showAcceptedTermsMessage = AppLocalizations.of(context)
            .translate('register_accept_terms_error');
      });
      return;
    }

    try {
      await ApiProvider().post("/signup", {
        "username": _usernameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "pass_confirm": _retypePasswordController.text
      });
      showDialog(
          context: context,
          builder: (context) => CustomDialog(
                title: "Success",
                description:
                    "We have sent an email to you with a validation link",
                buttonText: "Okay",
              ));

      // Navigator.of(context).pop();

      // Navigator.of(context).pushNamed('/poi-map');
      // log.d(body);
    } on DioError catch (err) {
      showDialog<void>(
        context: context,
        builder: (context) {
          return CustomDialog(
            title: "Register Error",
            description: err.response?.data["message"],
            buttonText: 'Okay',
          );
        },
      );
    }
  }
}
