///
import 'dart:convert' as convert;
import 'dart:math' as math;
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

import 'package:flutter_offline/flutter_offline.dart';
//import 'package:encrypt/encrypt.dart' as enq;
import 'package:loading_overlay/loading_overlay.dart';

//import 'package:logger/logger.dart';

///
import '../app_localizations.dart';
import '../models/secret.dart';
import '../providers/api_provider.dart';
import '../providers/custom_interceptors.dart';
import '../shared/constants.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/network_status_message.dart';

///
class SecretLoader {
  ///
  final String secretPath;

  ///
  SecretLoader({this.secretPath});

  ///
  Future<Secret> load() {
    return rootBundle.loadStructuredData<Secret>(secretPath, (jsonStr) async {
      final secret = Secret.fromJson(convert.json.decode(jsonStr));
      return secret;
    });
  }
}

///
class LoginPage extends StatefulWidget {
  ///
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //final Logger log = Logger(
  //    printer: PrettyPrinter(
  //        colors: true, printEmojis: true, printTime: true, lineLength: 80));

  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String errorMessage = '';
  String _emailControllerMessage = '';
  bool _showEmailError = false;
  String _passwordControllerMessage = '';
  bool _showPasswordError = false;
  convert.Codec<String, String> stringToBase64 =
      convert.utf8.fuse(convert.base64);

  final _apiProvider = ApiProvider();
  final _storage = FlutterSecureStorage();

  String _appVersion = GlobalConstants.appVersion;

  // final _googleSignIn = GoogleSignIn(
  //   scopes: [
  //     'email',
  //     'openid',
  //     'https://www.googleapis.com/auth/userinfo.profile',
  //   ],
  // );

  // Future<void> _handleSignIn() async {
  //   try {
  //     final googleUser = await _googleSignIn.signIn(); /* or signInSilently() */
  //     final googleAuth = await googleUser.authentication;
  //     print("${googleAuth.accessToken} ${googleAuth.idToken}");

  //     final plainText = convert.json.encode({
  //       'username': googleUser.displayName,
  //       'email': googleUser.email,
  //       'google_id': googleUser.id,
  //       'access_token': googleAuth.accessToken,
  //       'id_token': googleAuth.idToken
  //     });

  //     final secret =
  //         await SecretLoader(secretPath: "assets/secrets.json").load();
  //     final key = enq.Key.fromBase64(secret.enqKey);

  //     final rnd = enq.IV.fromSecureRandom(32);
  //     final rndstr = rnd.base64;
  //     final ivstr = rndstr.substring(0, 16);
  //     final iv = enq.IV.fromUtf8(ivstr);

  //     final encrypter = enq.Encrypter(enq.AES(key, mode: enq.AESMode.cbc));
  //     final encryptedpay = encrypter.encrypt(plainText, iv: iv);
  //     final enc = encryptedpay.base64;

  //     try {
  //       final response = await _apiProvider.get(
  //           "/authorize?aud=google&enc=${Uri.encodeComponent(ivstr + enc)}");
  //       final tmp = await CustomInterceptors.getStoredCookies(
  //           GlobalConstants.apiHostUrl);
  //       tmp["jwt"] = response["jwt"];
  //       tmp["user"] = response["user"];
  //       await CustomInterceptors.setStoredCookies(
  //           GlobalConstants.apiHostUrl, tmp);

  //       Navigator.of(context).pushReplacementNamed('/poi-map');
  //     } on DioError catch (err) {
  //       showDialog<void>(
  //         context: context,
  //         builder: (context) {
  //           return CustomDialog(
  //             title: "Error",
  //             description: err.response?.data["message"],
  //             buttonText: 'Okay',
  //           );
  //         },
  //       );
  //     }
  //   } on Exception catch (e) {
  //     print(e);
  //   }
  // }

  // When the user was already logged in, and we know everything
  Future getInFull(String jwt, Map<String, dynamic> userObject) async {
    final tmp =
        await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl);
    tmp["jwt"] = jwt;
    tmp["user"] = userObject;
    await CustomInterceptors.setStoredCookies(GlobalConstants.apiHostUrl, tmp);
    return true;
  }

  // When we know only the api key
  Future getInPartial(String jwt) async {
    final tmp =
        await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl);
    tmp["jwt"] = jwt;
    // First store the new token
    await CustomInterceptors.setStoredCookies(GlobalConstants.apiHostUrl, tmp);

    // then get all the info
    bool isOk = await _getUserDetails();
    return isOk;
  }

  Future _getUserDetails() async {
    //print('_getUserDetails');
    final response = await _apiProvider.get('/profile');
    try {
      final tmp =
          await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl);
      if (response["success"] == true) {
        tmp["jwt"] = response["jwt"];
        tmp["user"] = response["user"];
        Map jwtdata = parseJwt(response["jwt"]);

        // Todo: better user validation
        if (jwtdata.containsKey("usr")) {
          if (jwtdata["usr"] != null) {
            await CustomInterceptors.setStoredCookies(
                GlobalConstants.apiHostUrl, tmp);
            return true;
          }
        }
      }
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: "Error",
          description: err.response?.data["message"],
          buttonText: "Okay",
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }

    return false;
  }

  void login() async {
    setState(() {
      _isLoading = true;
    });
    _showEmailError = false;
    _showPasswordError = false;
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailControllerMessage = 'Please fill email';
        _showEmailError = true;
        _isLoading = false;
      });
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordControllerMessage = 'Please fill password';
        _showPasswordError = true;
        _isLoading = false;
      });
      return;
    }

    final encoded = stringToBase64
        .encode("${_emailController.text}:${_passwordController.text}");
    try {
      final response = await ApiProvider()
          .get("/login", headers: {"Authorization": "Basic $encoded"});

      if (response.containsKey("jwt")) {
        Map jwtdata = parseJwt(response["jwt"]);

        // Todo: better user validation
        if (jwtdata.containsKey("usr")) {
          if (jwtdata["usr"] != null) {
            bool isOk = await getInFull(response["jwt"], response["user"]);
            if (isOk == true) {
              await _storage.write(key: 'email', value: jwtdata["usr"]);
              await _storage.write(key: 'api_key', value: response["api_key"]);
              Navigator.of(context).pushReplacementNamed('/poi-map');
              return;
            }
          }
        }
      }

      setState(() {
        _passwordControllerMessage = 'Invalid credentials';
        _showPasswordError = true;
        _isLoading = false;
      });
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: "Error",
          description: "Check internet connection, or try again later",
          buttonText: "Okay",
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    _tryAutoSignIn();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Get the email and the api_key from secure_storage
  void _tryAutoSignIn() async {
    setState(() {
      _isLoading = true;
    });
    var secureStorage = await _storage.readAll();
    _emailController.text = secureStorage["email"];

    if (secureStorage.containsKey("api_key")) {
      if (secureStorage["api_key"] != null) {
        try {
          final response = await ApiProvider().post("/refreshtoken", {},
              headers: {"X-API-KEY": secureStorage["api_key"]});

          Map jwtdata = parseJwt(response["jwt"]);
          // Todo: better user validation
          if (jwtdata.containsKey("usr")) {
            if (jwtdata["usr"] != null) {
              bool isOk = await getInPartial(response["jwt"]);
              if (isOk) {
                await _storage.write(key: 'email', value: jwtdata["usr"]);
                Navigator.of(context).pushReplacementNamed('/poi-map');
                return;
              } else {
                setState(() {
                  _isLoading = false;
                });
                return;
              }
            }
          }
        } on DioError catch (err) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    var szHeight = MediaQuery.of(context).size.height;

    final loginButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: login,
      child: Text(
        AppLocalizations.of(context).translate('submit_login'),
        style: TextStyle(
            color: Color(0xffe6a04e),
            fontSize: 18,
            fontFamily: 'Cormorant SC',
            fontWeight: FontWeight.bold),
      ),
    );

    final forgotLabel = TextButton(
      child: Text(
        AppLocalizations.of(context).translate('forgot_password_btn_label'),
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.bold,
          shadows: <Shadow>[
            Shadow(
              offset: Offset(1.0, 1.0),
              blurRadius: 3.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ],
        ),
      ),
      onPressed: () {
        Navigator.of(context).pushNamed('/forgot');
      },
    );

    final registerButton = TextButton(
      child: Text(
        AppLocalizations.of(context).translate('create_account_btn_label'),
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
        //Flame.audio.play('sfx/bookOpen_${(math.Random.secure().nextInt(2) + 1).toString()}.ogg');
        Navigator.of(context).pushNamed('/register');
      },
    );

    ///
    final termsButton = TextButton(
      child: Text(
        AppLocalizations.of(context).translate('terms_drawer_label'),
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
      onPressed: () {
        Flame.audio.play(
            'sfx/bookOpen_${(math.Random.secure().nextInt(2) + 1).toString()}.ogg');
        Navigator.of(context).pushNamed('/terms');
      },
    );

    // final googleButton = Padding(
    //   padding: EdgeInsets.all(0),
    //   child: RaisedButton(
    //     shape: OutlineInputBorder(
    //       borderSide: const BorderSide(color: Colors.white, width: 1.0),
    //       borderRadius: BorderRadius.circular(10),
    //     ),
    //     onPressed: _handleSignIn,
    //     padding: EdgeInsets.all(12),
    //     color: Colors.white,
    //     child: Row(
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         Image.asset(
    //           'assets/images/googleLoginIcon.png',
    //           width: 24,
    //         ),
    //         SizedBox(width: 10.0),
    //         Text(
    //           AppLocalizations.of(context).translate('google_sign_in_btn'),
    //           style: TextStyle(
    //             color: Colors.black,
    //             fontSize: 18,
    //             fontFamily: 'Cormorant SC',
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

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
        child: LoadingOverlay(
          isLoading: _isLoading,
          opacity: 0.5,
          color: Colors.black,
          progressIndicator: CircularProgressIndicator(
            backgroundColor: Colors.black,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xffe6a04e)),
          ),
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/forest_jungle.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  height: szHeight,
                  child: ListView(
                    //physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 90, left: 24.0, right: 24.0),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 0, left: 0, right: 0, top: 0),
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                GlobalConstants.appName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontFamily: 'Cormorant SC',
                                  fontWeight: FontWeight.bold,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Text(
                        AppLocalizations.of(context)
                            .translate('email_input_label'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                            )
                          ],
                        ),
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
                                controller: _emailController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Email"),
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
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  )
                                ],
                              ),
                            )
                          : Text(''),
                      SizedBox(height: 18.0),
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
                              color: Color.fromARGB(255, 0, 0, 0),
                            )
                          ],
                        ),
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
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Password"),
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
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  )
                                ],
                              ),
                            )
                          : Text(''),
                      SizedBox(height: 24.0),
                      loginButton,
                      SizedBox(height: 18.0),
                      forgotLabel,
                      SizedBox(height: 2.0),
                      registerButton,
                      SizedBox(height: 2.0),
                      termsButton,
                      SizedBox(height: 12.0),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50, left: 0),
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                // ignore: lines_longer_than_80_chars
                                "version: $_appVersion",
                                style: TextStyle(
                                    fontSize: 14.0, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
