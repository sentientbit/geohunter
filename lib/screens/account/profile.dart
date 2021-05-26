///
import 'dart:ui';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

// import 'package:logger/logger.dart';

///
import '../../app_localizations.dart';
import '../../models/item.dart';
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../providers/custom_interceptors.dart';
import '../../providers/stream_userdata.dart';
import '../../screens/account/equipment.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';
import '../../widgets/network_status_message.dart';

/// 12 User equiped items with 0 as a starting index
List<Item> _equipments = List<Item>.filled(12, Item.blank());

///
class ProfilePage extends StatefulWidget {
  ///
  final String name = 'profile';

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userdata = getIt.get<StreamUserData>();

  ///
  final ApiProvider _apiProvider = ApiProvider();

  ImageProvider _avatar = AssetImage("assets/images/avatars/default01.jpg");

  /// Make sure back button is pressed twice
  bool ifPop = false;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _usernameController = TextEditingController();
  final _statusTextController = TextEditingController();
  String _usernameControllerMessage = '';
  bool _showEmailError = false;

  String _currentSex = "1";

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  /// Curent loggedin user
  User _user = User.blank();

  ///
  List<DropdownMenuItem<String>> _locationPrivacies = [];
  List<DropdownMenuItem<String>> _sexes = [];
  List<DropdownMenuItem<String>> _languages = [];

  ///
  int currentLevel = 0;

  ///
  int nextExperienceLevel = 1;

  ///
  int currentExperience = 0;

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
      if (_scaffoldKey != null) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(GlobalConstants.backButtonPage);
      }
    }
    return true;
  }

  bool isValidGender(String input) {
    if (input == "1") {
      return true;
    } else if (input == "2") {
      return true;
    }
    return false;
  }

  bool isValidLanguage(String input) {
    if (input == "en") {
      return true;
    } else if (input == "ro") {
      return true;
    }
    return false;
  }

  Container _normalDown() => Container(
        margin: EdgeInsets.only(right: 15),
        child: DropdownButton<String>(
          isDense: false,
          isExpanded: true,
          underline: Container(
            height: 1.0,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.transparent, width: 0.0),
              ),
            ),
          ),
          hint: Text('Select gender'),
          dropdownColor: GlobalConstants.appBg,
          style: TextStyle(
            fontSize: 16,
            color: GlobalConstants.appFg,
          ),
          items: _sexes,
          onChanged: (value) {
            setState(
              () {
                _user.details.sex = value ?? "0";
                _currentSex = value ?? "0";
              },
            );
          },
          value: _user != null
              ? (isValidGender(_user.details.sex) ? _user.details.sex : "1")
              : "1",
        ),
      );

  Container _locationDown() => Container(
        margin: EdgeInsets.only(right: 15),
        child: DropdownButton<String>(
          isDense: false,
          isExpanded: true,
          underline: Container(
            height: 1.0,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.transparent, width: 0.0),
              ),
            ),
          ),
          hint: Text('Location'),
          dropdownColor: GlobalConstants.appBg,
          style: TextStyle(
            fontSize: 16,
            color: GlobalConstants.appFg,
          ),
          items: _locationPrivacies,
          onChanged: (value) {
            setState(
              () {
                _user.details.locationPrivacy = value ?? "0";
              },
            );
          },
          value: _user.details.locationPrivacy,
        ),
      );

  Container _languageDown() => Container(
        margin: EdgeInsets.only(right: 15),
        child: DropdownButton<String>(
          isDense: false,
          isExpanded: true,
          underline: Container(
            height: 1.0,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.transparent, width: 0.0),
              ),
            ),
          ),
          hint: Text('Language'),
          dropdownColor: GlobalConstants.appBg,
          style: TextStyle(
            fontSize: 16,
            color: GlobalConstants.appFg,
          ),
          items: _languages,
          onChanged: (value) {
            setState(
              () {
                _user.details.language = value ?? "en";
              },
            );
          },
          value: (isValidLanguage(_user.details.language)
              ? _user.details.language
              : "en"),
        ),
      );

  Widget itemLogo(double szWidth, int index, Item eqp) {
    var rarity = (eqp.id > 0) ? (int.tryParse(eqp.rarity.toString()) ?? 0) : 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EquipmentPage(placement: index, item: eqp),
          ),
        );
      },
      child: Container(
        height: (szWidth - 60) / 3,
        decoration: (eqp.id != 0)
            ? BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                border: Border.all(
                  color: Item.color(rarity),
                  width: 1,
                  style: BorderStyle.solid,
                ),
                // gradient: LinearGradient(
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                //   colors: [Item.gradientTop(rarity), Item.gradientBottom(rarity)],
                // ),
                gradient: RadialGradient(
                  radius: 0.5,
                  colors: [
                    Item.gradientTop(rarity), // yellow sun
                    Item.gradientBottom(rarity), // blue sky
                  ],
                  stops: [0.4, 1.0],
                ),
                image: DecorationImage(
                  image: ExactAssetImage("assets/images/items/${eqp.img}"),
                  fit: BoxFit.cover,
                ),
              )
            : BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                border: Border.all(
                  color: Color(0xff444444),
                  width: 1,
                  style: BorderStyle.solid,
                ),
                image: DecorationImage(
                  image: ExactAssetImage(
                      "assets/images/placeholders/${index.toString()}.png"),
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget expBar(
    int xp,
    int currentExperience,
    int nextExperienceLevel,
    Color color,
  ) {
    double percentage = xp / nextExperienceLevel;
    return SizedBox(
      height: 40,
      width: 180,
      child: LinearPercentIndicator(
        lineHeight: 14.0,
        percent: percentage,
        center: Text(
          "${currentExperience.toString()} / ${nextExperienceLevel.toString()}",
          style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
        ),
        linearStrokeCap: LinearStrokeCap.roundAll,
        backgroundColor: Colors.white,
        progressColor: color,
      ),
    );
  }

  Widget build(BuildContext context) {
    // Determining the screen width & height
    var szWidth = MediaQuery.of(context).size.width;

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
      title: Text(
        AppLocalizations.of(context)!.translate('profile'),
        style: Style.topBar,
      ),
    );

    setState(() {
      _sexes = [
        DropdownMenuItem<String>(
          value: "1",
          child:
              Text(AppLocalizations.of(context)!.translate('gender_male_text')),
        ),
        DropdownMenuItem<String>(
          value: "2",
          child: Text(
              AppLocalizations.of(context)!.translate('gender_female_text')),
        )
      ];
      _locationPrivacies = [
        DropdownMenuItem<String>(
          value: "0",
          child: Text(
            AppLocalizations.of(context)!
                .translate('location_privacy_nobody_text'),
          ),
        ),
        DropdownMenuItem<String>(
          value: "1",
          child: Text(AppLocalizations.of(context)!
              .translate('location_privacy_just_friends_text')),
        ),
        DropdownMenuItem<String>(
          value: "3",
          child: Text(AppLocalizations.of(context)!
              .translate('location_privacy_friends_and_guild_text')),
        ),
        DropdownMenuItem<String>(
          value: "15",
          child: Text(AppLocalizations.of(context)!
              .translate('location_privacy_public_text')),
        ),
      ];
      _languages = [
        DropdownMenuItem<String>(
          value: "en",
          child: Text("English"),
        ),
        DropdownMenuItem<String>(
          value: "ro",
          child: Text("Română"),
        )
      ];
    });

    final updateProfileButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: _updateProfile,
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
      resizeToAvoidBottomInset: false,
      backgroundColor: GlobalConstants.appBg,
      appBar: topBar,
      extendBodyBehindAppBar: true,
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
                  image: AssetImage('assets/images/forest_road.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(top: 0),
              child: SingleChildScrollView(
                // reverse: true,
                child: Padding(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 80.0,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            radius: szWidth / 5,
                            backgroundImage: _avatar,
                            backgroundColor: Colors.transparent,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Icon(
                              Icons.school,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: expBar(
                              currentExperience,
                              currentExperience,
                              nextExperienceLevel,
                              Colors.orange,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              ' XP',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Icon(
                              Icons.healing,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: expBar(
                              100,
                              100,
                              100,
                              Colors.red,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              ' Health',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Equipment',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color(0xffe6a04e),
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
                      SizedBox(height: 18),
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: (_currentSex == "1")
                                    ? AssetImage(
                                        'assets/images/male_silhouette.png')
                                    : AssetImage(
                                        'assets/images/female_silhouette.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Container(
                            color: Color(0x991c1411),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 10,
                                      child:
                                          itemLogo(szWidth, 0, _equipments[0]),
                                    ),
                                    Spacer(flex: 1),
                                    Expanded(
                                      flex: 10,
                                      child:
                                          itemLogo(szWidth, 1, _equipments[1]),
                                    ),
                                    Spacer(flex: 1),
                                    Expanded(
                                      flex: 10,
                                      child:
                                          itemLogo(szWidth, 2, _equipments[2]),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 10,
                                      child:
                                          itemLogo(szWidth, 3, _equipments[3]),
                                    ),
                                    Spacer(flex: 1),
                                    Expanded(
                                      flex: 10,
                                      child:
                                          itemLogo(szWidth, 4, _equipments[4]),
                                    ),
                                    Spacer(flex: 1),
                                    Expanded(
                                      flex: 10,
                                      child:
                                          itemLogo(szWidth, 5, _equipments[5]),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 10,
                                      child:
                                          itemLogo(szWidth, 6, _equipments[6]),
                                    ),
                                    Spacer(flex: 1),
                                    Expanded(
                                      flex: 10,
                                      child:
                                          itemLogo(szWidth, 7, _equipments[7]),
                                    ),
                                    Spacer(flex: 1),
                                    Expanded(
                                      flex: 10,
                                      child:
                                          itemLogo(szWidth, 8, _equipments[8]),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 10,
                                      child:
                                          itemLogo(szWidth, 9, _equipments[9]),
                                    ),
                                    Spacer(flex: 1),
                                    Expanded(
                                      flex: 10,
                                      child: itemLogo(
                                          szWidth, 10, _equipments[10]),
                                    ),
                                    Spacer(flex: 1),
                                    Expanded(
                                      flex: 10,
                                      child: itemLogo(
                                          szWidth, 11, _equipments[11]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Player details',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color(0xffe6a04e),
                          fontSize: 24,
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
                      SizedBox(height: 18),
                      // Username
                      Text(
                        AppLocalizations.of(context)!
                            .translate('update_profile_username_label'),
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
                      // Username
                      Card(
                        elevation: 8,
                        color: GlobalConstants.appBg,
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
                                style: TextStyle(
                                    fontSize: 16, color: GlobalConstants.appFg),
                                controller: _usernameController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Username"),
                                onSubmitted: (text) {},
                              ),
                            )
                          ],
                        ),
                      ),
                      if (_showEmailError)
                        _showEmailError
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
                      SizedBox(
                        height: 18.0,
                      ),
                      // Gender
                      Text(
                        AppLocalizations.of(context)!
                            .translate('update_profile_gender_label'),
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
                      // Gender
                      Card(
                        elevation: 8,
                        color: GlobalConstants.appBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(
                              width: 20,
                            ),
                            // SizedBox(
                            //   width: 15,
                            // ),
                            Expanded(child: _normalDown())
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 18,
                        height: 18,
                      ),
                      // Location Privacy
                      Text(
                        AppLocalizations.of(context)!
                            .translate('update_profile_location_privacy_label'),
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
                      // Location privacy
                      Card(
                        elevation: 8,
                        color: GlobalConstants.appBg,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(child: _locationDown())
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 18,
                        height: 18,
                      ),
                      // Language
                      Text(
                        AppLocalizations.of(context)!
                            .translate('update_profile_language_label'),
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
                      // Language
                      Card(
                        elevation: 8,
                        color: GlobalConstants.appBg,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(child: _languageDown())
                          ],
                        ),
                      ),
                      SizedBox(width: 18, height: 18),
                      Text(
                        AppLocalizations.of(context)!
                            .translate('update_profile_status_text_label'),
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
                        color: GlobalConstants.appBg,
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
                                style: TextStyle(color: GlobalConstants.appFg),
                                controller: _statusTextController,
                                decoration: InputDecoration(
                                    fillColor: GlobalConstants.appBg,
                                    border: InputBorder.none,
                                    hintText: "Hi"),
                                onSubmitted: (text) {},
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[updateProfileButton],
                      ),
                      SizedBox(height: 58),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }

  void _updateProfile() async {
    _showEmailError = false;
    if (_usernameController.text.isEmpty) {
      setState(() {
        _usernameControllerMessage = 'Please fill username';
        _showEmailError = true;
      });
      return;
    } else if (_usernameController.text.length > 12) {
      setState(() {
        _usernameControllerMessage = 'Max username length is 12';
        _showEmailError = true;
      });
      return;
    } else {
      _showEmailError = false;
    }

    try {
      _user.details.username = _usernameController.text;
      _user.details.status = _statusTextController.text;

      await ApiProvider().put('/profile', {
        "username": _usernameController.text,
        "sex": _user.details.sex,
        "location_privacy": _user.details.locationPrivacy,
        "language": _user.details.language,
        "status": _user.details.status
      });

      // print(updateRequest);
      // print(_user.toMap());
      CustomInterceptors.setStoredCookies(
          GlobalConstants.apiHostUrl, _user.toMap());
      showDialog<void>(
        context: context,
        builder: (context) {
          return CustomDialog(
            title: 'Success',
            description: 'Profile updated succesfully',
            buttonText: 'Okay',
            images: [],
            callback: () {},
          );
        },
      );
      // Navigator.of(context).pop();

      // Navigator.of(context).pushNamed('/poi-list');
      // log.d(body);
    } on DioError catch (err) {
      showDialog<void>(
        context: context,
        builder: (context) {
          return CustomDialog(
            title: 'Error',
            description: err.response?.data["message"],
            buttonText: 'Okay',
            images: [],
            callback: () {},
          );
        },
      );
    }
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

    _equipments = List<Item>.filled(12, Item.blank());

    if (response["equipment"].isEmpty) {
      print('No equipment found');
    } else if (response["equipment"][0] != null) {
      if (response["equipment"].length > 0) {
        for (var eqp in response["equipment"]) {
          final itm = Item.fromJson(eqp);
          // GridView Index starts with 0 so we substract 1
          int idx = eqp['placement'] - 1;
          _equipments[idx] = itm;
        }
      }
    }

    if (response.containsKey("coins")) {
      // update local data
      _user.details.coins =
          double.tryParse(response["coins"].toString()) ?? 0.0;
      _user.details.xp = response["xp"];
      _user.details.unread = response["unread"];
      // log.d(_user.details.unread);

      // update global data
      _userdata.updateUserData(
        _user.details.coins,
        0,
        response["guild"]["id"],
        _user.details.xp,
        _user.details.unread,
      );
    }

    setState(() {
      /// update controller data
      _usernameController.text = _user.details.username;
      _currentSex = _user.details.sex;
      _statusTextController.text = _user.details.status;
      currentExperience = _user.details.xp;
      currentLevel = expToLevel(currentExperience);
      nextExperienceLevel = levelToExp(currentLevel + 1);
      _avatar = NetworkImage(
          'https://${GlobalConstants.apiHostUrl}${_user.details.picture}');
    });

    return;
  }
}
