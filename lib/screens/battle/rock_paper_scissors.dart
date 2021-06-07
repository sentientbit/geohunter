///
import 'dart:async';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:geohunter/models/visitevent.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

//import 'package:logger/logger.dart';

///
import '../../fonts/rpg_awesome_icons.dart';
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../providers/stream_userdata.dart';
import '../../providers/stream_visit.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';

///
class RockPaperScissorsPage extends StatefulWidget {
  ///
  final String name = "battle";

  ///
  int rndMap = 0;

  ///
  int mineId = 0;

  ///
  RockPaperScissorsPage({
    Key? key,
    required this.rndMap,
    required this.mineId,
  }) : super(key: key);

  @override
  _RockPaperScissorsState createState() => _RockPaperScissorsState();
}

///
class _RockPaperScissorsState extends State<RockPaperScissorsPage> {
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

  ///
  final _visiteventdata = getIt.get<StreamVisit>();

  /// Curent loggedin user
  User _user = User.blank();

  ///
  double playerHealth = 100.0;

  ///
  double enemyHealth = 100.0;

  ///
  String playerString = "";

  ///
  String enemyString = "";

  ///
  String resultString = "";

  ///
  int currentLevel = 0;

  ///
  int nextExperienceLevel = 1;

  ///
  int currentExperience = 0;

  ///
  double myAtk = 0.0;

  ///
  double myDef = 0.0;

  List<String> consoleStrings = [];

  String monsterName = "Giant Rat";

  ScrollController _scrollController = ScrollController();

  bool isWinner = false;

  bool isLooser = false;

  ///
  List<String> actionStrings = [
    "Attack" /*rock*/,
    "Defend" /*paper*/,
    "Grab" /*scissors*/,
  ];

  bool tap = false;

  @override
  void initState() {
    super.initState();
    loadUser();
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
      //Navigator.of(context).pushNamed(GlobalConstants.backButtonPage);
    }
    return true;
  }

  String dp(double val, int places) {
    double mod = double.tryParse(math.pow(10.0, places).toString()) ?? 0.0;
    var out = ((val * mod).round().toDouble() / mod);
    return out.toString();
  }

  /// 1 is win, 0 is draw, -1 is loss
  int hitOrMiss(int playerAction, int enemyAction) {
    if (playerAction == 0 /* rock - attack */) {
      if (enemyAction == 1 /* paper - shield */) {
        return -1;
      } else if (enemyAction == 2 /* scissors - grab */) {
        return 1;
      }
      return 0;
    } else if (playerAction == 1 /* paper - shield */) {
      if (enemyAction == 0 /* rock - attack */) {
        return 1;
      } else if (enemyAction == 2 /* scissors - grab */) {
        return -1;
      }
      return 0;
    } else /* scissors - grab */ {
      if (enemyAction == 0 /* rock - attack */) {
        return -1;
      } else if (enemyAction == 1 /* paper - shield */) {
        return 1;
      }
      return 0;
    }
  }

  void loadUser() async {
    final tmp = await _apiProvider.getStoredUser();
    // log.d(tmp.details.unread);

    _getUserDetails();

    _user = tmp;
    setState(() {
      _user = tmp;
      _user.details.coins = tmp.details.coins;
      _user.details.xp = tmp.details.xp;
      _user.details.unread = tmp.details.unread;
      _user.details.attack = tmp.details.attack;
      _user.details.defense = tmp.details.defense;
      _user.details.daily = tmp.details.daily;
    });
  }

  void actionGo(int playerAction) {
    setState(() {
      tap = true;
    });

    var rnd = rndBattleNumber.nextInt(300);
    //print(rnd);
    var enemyAction = rnd.remainder(3);
    //print(enemyAction);
    var result = hitOrMiss(playerAction, enemyAction);

    if (result == 1) {
      FlameAudio.audioCache.play('sfx/sword_1.mp3');
    } else if (result == -1) {
      FlameAudio.audioCache.play('sfx/bookOpen_1.mp3');
    } else {
      FlameAudio.audioCache.play('sfx/cloth_3.mp3');
    }

    if (_user.details.attack.length > 1) {
      myAtk = rndBattleNumber.nextDouble() *
              (_user.details.attack[1] - _user.details.attack[0]) +
          _user.details.attack[0];
    }

    if (_user.details.defense.length > 1) {
      myDef = rndBattleNumber.nextDouble() *
              (_user.details.defense[1] - _user.details.defense[0]) +
          _user.details.defense[0];
    }

    double theirDef = rndBattleNumber.nextDouble() * (10 - 5) + 5;

    double theirAtk = rndBattleNumber.nextDouble() * (10 - 5) + 5;

    // _scrollController.addListener(() {
    //   print('bbb');
    // });

    setState(() {
      playerString = actionStrings[playerAction];
      enemyString = actionStrings[enemyAction];
      if (result == 1) {
        resultString = "Hit";
        enemyHealth = enemyHealth - damageHealth(myAtk, theirDef);
        if (enemyHealth <= 0) {
          isWinner = true;
        }
        consoleStrings.add(
            "${_user.details.username}: $playerString vs $monsterName: $enemyString");
        consoleStrings.add(
            "${_user.details.username}: Hit for ${dp(myAtk, 2)} against ${dp(theirDef, 2)} armor");
      } else if (result == -1) {
        resultString = "Miss";
        playerHealth = playerHealth - damageHealth(theirAtk, myDef);
        if (playerHealth <= 0) {
          isLooser = true;
        }
        consoleStrings.add(
            "${_user.details.username}: $playerString vs $monsterName: $enemyString");
        if (enemyAction == 1) {
          consoleStrings.add(
              "$monsterName: Bash for ${dp(theirAtk, 2)} against ${dp(myDef, 2)} armor");
        } else {
          consoleStrings.add(
              "$monsterName: Hit for ${dp(theirAtk, 2)} against ${dp(myDef, 2)} armor");
        }
      } else {
        resultString = "Draw";
        consoleStrings.add(
            "${_user.details.username}: $playerString vs $monsterName: $enemyString");
        consoleStrings.add("Draw");
      }
    });

    Timer(Duration(milliseconds: 200), () {
      setState(() {
        tap = false;
      });
      FlameAudio.audioCache
          .play('sfx/rat_${(rndBattleNumber.nextInt(3) + 1).toString()}.mp3');
    });
  }

  Widget healthBar(
    double current,
    double next,
    Color color,
  ) {
    // ignore: omit_local_variable_types
    double percentage = current / next;
    if (percentage < 0) {
      percentage = 0.0;
    } else if (percentage > 1) {
      percentage = 1.0;
    }
    int currentInt = current.round();
    if (currentInt < 0) {
      currentInt = 0;
    }
    int nextInt = next.round();
    return SizedBox(
      height: 40,
      width: 180,
      child: LinearPercentIndicator(
        lineHeight: 14.0,
        percent: percentage,
        center: Text(
          "$currentInt / $nextInt",
          style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
        ),
        linearStrokeCap: LinearStrokeCap.roundAll,
        backgroundColor: Colors.white,
        progressColor: color,
      ),
    );
  }

  Widget actionMenu() {
    if (isLooser == true && isWinner == false) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: SizedBox(),
            ),
            Expanded(
              flex: 3,
              child: Padding(
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
                    _visiteventdata.updateEvent(
                      VisitEvent(-1, "3", widget.mineId),
                    );
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(RPGAwesome.skull, color: Color(0xffe6a04e)),
                      Text(
                        ' Defeat',
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
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(),
            ),
          ],
        ),
      );
    } else if (isLooser == false && isWinner == true) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: SizedBox(),
            ),
            Expanded(
              flex: 3,
              child: Padding(
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
                    _visiteventdata.updateEvent(
                      VisitEvent(1, "3", widget.mineId),
                    );
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(RPGAwesome.horn_call, color: Color(0xffe6a04e)),
                      Text(
                        ' Victory',
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
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(),
            ),
          ],
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: FloatingActionButton.extended(
            heroTag: "Attack",
            onPressed: () {
              actionGo(0);
              _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.ease);
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: Colors.black,
            label: Text(
              "Attack",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            icon: Icon(
              RPGAwesome.broadsword,
              size: 36.0,
              color: Colors.red,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: FloatingActionButton.extended(
            heroTag: "Defend",
            onPressed: () {
              actionGo(1);
              _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.ease);
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: Colors.black,
            label: Text(
              "Defend",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            icon: Icon(
              RPGAwesome.shield,
              size: 36.0,
              color: Color(0xff0da3d8),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: FloatingActionButton.extended(
            heroTag: "Grab",
            onPressed: () {
              actionGo(2);
              _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.ease);
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: Colors.black,
            label: Text(
              "Grab",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            icon: Icon(
              RPGAwesome.hand,
              size: 36.0,
              color: Color(0xffe6a04e),
            ),
          ),
        ),
      ],
    );
  }

  Widget battleLog(szHeight) {
    return SizedBox(
      height: szHeight / 4,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            for (var i = 0; i < consoleStrings.length; i++)
              Row(
                children: <Widget>[
                  Text(
                    consoleStrings[i],
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    var szHeight = MediaQuery.of(context).size.height;

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
        "Fight",
        style: Style.topBar,
      ),
    );

    double width(BuildContext context) {
      return MediaQuery.of(context).size.width;
    }

    double height(BuildContext context) {
      return MediaQuery.of(context).size.height;
    }

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
                image: AssetImage('assets/images/fight_${widget.rndMap}.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: szHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 0, left: 0, right: 0, top: 90),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.center,
                                child: battleLog(szHeight),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                monsterName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: healthBar(
                              enemyHealth,
                              100.0,
                              Colors.red,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: SizedBox(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(flex: 1, child: SizedBox()),
                            Expanded(
                              flex: 5,
                              child: (isWinner == false)
                                  ? Image.asset(
                                      'assets/images/enemies/rat.png',
                                      height: width(context) / 1.5 < 260
                                          ? width(context) / 1.5
                                          : 260,
                                      color: tap ? Color(0x80FFFFFF) : null,
                                    )
                                  : SizedBox(height: 260),
                            ),
                            Expanded(flex: 1, child: SizedBox()),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  _user.details.username,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: healthBar(
                                playerHealth,
                                100.0,
                                Colors.red,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: SizedBox(),
                            ),
                          ],
                        ),
                        actionMenu(),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
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

    if (response.containsKey("coins")) {
      // update local data
      _user.details.coins =
          double.tryParse(response["coins"].toString()) ?? 0.0;
      _user.details.guildId = response["guild"]["id"];
      _user.details.xp = response["xp"];
      _user.details.unread = response["unread"];
      _user.details.attack = response["attack"];
      _user.details.defense = response["defense"];
      _user.details.daily = response["daily"];

      if (_user.details.attack.length > 1) {
        myAtk = rndBattleNumber.nextDouble() *
                (_user.details.attack[1] - _user.details.attack[0]) +
            _user.details.attack[0];
      }

      if (_user.details.defense.length > 1) {
        myDef = rndBattleNumber.nextDouble() *
                (_user.details.defense[1] - _user.details.defense[0]) +
            _user.details.defense[0];
      }

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
    }

    setState(() {
      /// update controller data
      currentExperience = _user.details.xp;
      currentLevel = expToLevel(currentExperience);
      nextExperienceLevel = levelToExp(currentLevel + 1);
    });

    return;
  }
}
