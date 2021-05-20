///
import 'dart:ui';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:logger/logger.dart';
import 'package:flutter_offline/flutter_offline.dart';

import '../app_localizations.dart';
import '../providers/api_provider.dart';
import '../shared/constants.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/network_status_message.dart';

///
class ForgotPage extends StatefulWidget {
  ///
  static String tag = 'forgot';
  @override
  _ForgotPageState createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  final _emailController = TextEditingController();
  String _emailControllerMessage = '';
  bool _showEmailError = false;

  final _storage = FlutterSecureStorage();

  _recoverPassword() async {
    _showEmailError = false;
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailControllerMessage = 'Please fill email';
        _showEmailError = true;
      });
      return;
    } else {
      _showEmailError = false;
    }

    try {
      final response =
          await ApiProvider().get('/forgot?email=${_emailController.text}');
      String message = response['message'] ?? "Please check your email.";

      showDialog(
        context: context,
        builder: (context) => CustomDialog(
            title: 'Forgot password',
            description: message,
            buttonText: "Okay",
            callback: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/login');
            }),
      );
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Forgot password',
          description: err?.response?.data["message"],
          buttonText: "Okay",
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    populateEmail();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  void populateEmail() async {
    var secureStorage = await _storage.readAll();
    if (secureStorage.containsKey("email")) {
      _emailController.text = secureStorage["email"];
    }
  }

  // ignore: avoid_positional_boolean_parameters
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.of(context).pop();
    return true;
  }

  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    final resetPassword = Padding(
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
        onPressed: _recoverPassword,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.shopping_cart, color: Color(0xffe6a04e)),
            Text(
              AppLocalizations.of(context).translate('recover_btn'),
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

    final goBack = TextButton(
      child: Text(
        AppLocalizations.of(context).translate('recover_back_btn'),
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
                image: AssetImage('assets/images/campfire_woods.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: ListView(
                //physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 90, left: 24.0, right: 24.0),
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)
                        .translate('recover_title_label'),
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
                      ],
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Text(
                    AppLocalizations.of(context)
                        .translate('recover_subtitle_label'),
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
                  SizedBox(
                    height: 40.0,
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
                                border: InputBorder.none, hintText: "Email"),
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
                  SizedBox(height: 24.0),
                  resetPassword,
                  SizedBox(width: 105),
                  goBack,
                  SizedBox(height: 100),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
