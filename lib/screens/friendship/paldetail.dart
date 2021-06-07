/// based on https://medium.com/@afegbua/this-is-the-second-part-of-the-beautiful-list-ui-and-detail-page-article-ecb43e203915
import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

//import 'package:logger/logger.dart';

///
import '../../fonts/rpg_awesome_icons.dart';
import '../../models/friends.dart';
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../providers/stream_userdata.dart';
import '../../screens/map_explore.dart' show PoiMap;
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';

//import '../app_localizations.dart';

///
class PalDetailPage extends StatefulWidget {
  ///
  final Friend friend;

  ///
  PalDetailPage({
    Key? key,
    required this.friend,
  }) : super(key: key);

  @override
  _PalDetailState createState() => _PalDetailState();
}

///
class _PalDetailState extends State<PalDetailPage> {
  TextEditingController _controller = new TextEditingController();

  // Define the focus node. To manage the lifecycle, create the FocusNode in
  // the initState method, and clean it up in the dispose method.
  late FocusNode myFocusNode;

  //final Logger log = Logger(
  //    printer: PrettyPrinter(
  //        colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  final ApiProvider _apiProvider = ApiProvider();

  final _userdata = getIt.get<StreamUserData>();

  /// Curent loggedin user
  User _user = User.blank();

  ///
  bool firstTimeCraaw = true;

  ///
  int currentLevel = 0;

  ///
  int nextExperienceLevel = 1;

  ///
  String receivedMessage = "";

  ///
  String sentMessage = "";

  ///
  bool isNewMessage = false;

  ///
  bool friendReceived = false;

  ///
  Friend currentFriend = Friend.blank();

  ///
  IconData buttonIcon = Icons.done;

  ///
  Timer? poorManTimer;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _controller.text = '';
    super.initState();
    currentFriend = widget.friend;
    currentLevel = expToLevel(currentFriend.xp);
    nextExperienceLevel = levelToExp(currentLevel + 1);
    BackButtonInterceptor.add(myInterceptor);
    getMessages(currentFriend.id);
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    poorManTimer?.cancel();
    super.dispose();
  }

  // ignore: avoid_positional_boolean_parameters
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.of(context).pop();
    return true;
  }

  Widget privacyWidget() {
    if ((currentFriend.locationPrivacy & 1) == 1) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PoiMap(
                goToRemoteLocation: true,
                latitude: currentFriend.lat,
                longitude: currentFriend.lng,
              ),
            ),
          );
        },
        child: Column(
          children: <Widget>[
            Icon(
              Icons.my_location_outlined,
              size: 24,
              color: Colors.white,
            ),
            SizedBox(width: 10.0),
            Text(
              'Go to',
              style: TextStyle(color: GlobalConstants.appFg, fontSize: 18.0),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => {},
      child: Column(
        children: <Widget>[
          Icon(
            Icons.location_disabled,
            size: 24,
            color: Colors.white,
          ),
          SizedBox(width: 10.0),
          Text(
            'Hidden',
            style: TextStyle(color: GlobalConstants.appFg, fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  Widget expBar(
    int currentExperience,
    int nextExperienceLevel,
    Color color,
  ) {
    // ignore: omit_local_variable_types
    double percentage = currentExperience / nextExperienceLevel;
    return SizedBox(
      height: 40,
      width: 180,
      child: LinearPercentIndicator(
        lineHeight: 14.0,
        percent: percentage,
        center: Text(
          "$currentExperience / $nextExperienceLevel",
          style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
        ),
        linearStrokeCap: LinearStrokeCap.roundAll,
        backgroundColor: Colors.white,
        progressColor: color,
      ),
    );
  }

  Widget sendButton(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding:
            EdgeInsets.only(top: 10.0, bottom: 10.0, left: 2.0, right: 2.0),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: () async {
        sendMessage(currentFriend.id);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(buttonIcon, color: Color(0xffe6a04e)),
          Text(
            "",
            style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    var szWidth = MediaQuery.of(context).size.width;

    if (isNewMessage && firstTimeCraaw == true) {
      FlameAudio.audioCache.play('sfx/raven_1.mp3');
      firstTimeCraaw = false;
    }

    //ignore: omit_local_variable_types
    double halfScreenSize =
        (MediaQuery.of(context).size.height * 0.5) - 40 /* appbar is 80px */;

    /// Application top Bar
    final topBar = AppBar(
      brightness: Brightness.dark,
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
      title: Text(currentFriend.username, style: Style.topBar),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );

    final expLevel = Container(
      padding: const EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.black,
      ),
      child: Text(
        "Lvl ${expToLevel(currentFriend.xp)}",
        style: TextStyle(
          color: GlobalConstants.appFg,
          fontSize: 18.0,
          backgroundColor: Colors.black,
        ),
      ),
    );

    final topContentText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            expLevel,
            SizedBox(width: 16),
            CircleAvatar(
              radius: szWidth / 5,
              backgroundImage: NetworkImage(
                  'https://${GlobalConstants.apiHostUrl}${currentFriend.thumbnail}'),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(width: 16),
            privacyWidget(),
          ],
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Icon(
                RPGAwesome.hearts,
                size: 24,
                color: Colors.white,
              ),
            ),
            Expanded(
              flex: 4,
              child: expBar(
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
                currentFriend.xp,
                nextExperienceLevel,
                Colors.orange,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                ' Xp',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final topContent = Stack(
      children: <Widget>[
        Container(
          height: halfScreenSize,
          padding: EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Color(0x00000055),
          ),
          child: Center(
            child: topContentText,
          ),
        ),
      ],
    );

    final bottomContent = Stack(
      children: <Widget>[
        Container(
          padding:
              EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0, bottom: 20.0),
          //width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Color(0xaa000000),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: isNewMessage
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.center,
                  children: <Widget>[
                    if (isNewMessage)
                      Image.asset(
                        "assets/images/raven.png",
                        width: 80,
                        height: 80,
                      ),
                    //Icon(RPGAwesome.raven, color: Colors.red),
                    Text(
                      " Raven Message",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xffe6a04e),
                        fontSize: 24,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 80),
                  ],
                ),
                GestureDetector(
                  onTap: () => myFocusNode.requestFocus(),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        //width: 800,
                        height: 222,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/scroll.png',
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 50.0,
                            right: 50.0,
                            top: 21.0,
                          ),
                          child: Text(
                            receivedMessage,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Cormorant SC',
                              fontWeight: FontWeight.w900,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 1.0,
                                  color: Color.fromRGBO(0, 0, 0, 210),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        focusNode: myFocusNode,
                        autofocus: false,
                        controller: _controller,
                        onChanged: (value) async {
                          if (value.length > 0) {
                            setState(() {
                              buttonIcon = Icons.send;
                            });
                          } else if (friendReceived == true) {
                            setState(() {
                              buttonIcon = Icons.done_all;
                            });
                          } else {
                            setState(() {
                              buttonIcon = Icons.done;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: sentMessage,
                          hintStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: sendButton(context),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Text(
                  'Trading',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Color(0xffe6a04e),
                      fontSize: 24,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 18),
                Text(
                  "Coins and items. Coming soon.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[],
                ),
                SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: GlobalConstants.appBg,
      appBar: topBar,
      extendBodyBehindAppBar: true,
      body: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/friend_campfire.jpg'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(top: 90.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        topContent,
                        bottomContent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }

  void getMessages(int friendId) async {
    /// populate initial data from cookies
    _user = await ApiProvider().getStoredUser();

    var ravenSound = false;
    try {
      final response = await _apiProvider.get('/message/$friendId');

      if (response.containsKey("success")) {
        if (response["success"] == true) {
          // update local data
          _user.details.coins =
              double.tryParse(response["coins"].toString()) ?? 0.0;
          _user.details.guildId = response["guild"]["id"];
          _user.details.xp = response["xp"];
          _user.details.unread = response["unread"];
          _user.details.attack = response["attack"];
          _user.details.defense = response["defense"];
          _user.details.daily = response["daily"];

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
          ravenSound =
              (response["received_ack"] == 0 && response["received"].length > 0)
                  ? true
                  : false;

          //log.d(response);
          setState(() {
            receivedMessage = response["received"];
            sentMessage = (response["sent"].length > 0)
                ? response["sent"]
                : "Send up to 140 chars";
            isNewMessage = ravenSound;
            if (response["seen_friend"] > 0) {
              friendReceived = true;
              buttonIcon = Icons.done_all;
            }
          });
        }
      }
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: "Error",
          description: err.response?.data["message"],
          buttonText: "Okay",
          images: [],
          callback: () {},
        ),
      );
    }
  }

  void sendMessage(int friendId) async {
    if (_controller.text.isEmpty) {
      setState(() {
        sentMessage = "Please enter a message";
      });
      return;
    }
    try {
      final response = await _apiProvider.post(
        '/message',
        {
          "friend_id": friendId.toString(),
          "message": _controller.text,
        },
      );

      if (response.containsKey("success")) {
        if (response["success"] == true) {
          setState(() {
            _controller.text = "";
            buttonIcon = Icons.done;
            sentMessage = (_controller.text.length > 0)
                ? _controller.text
                : "Send up to 140 chars";
          });
          // Poor man's polling: one time after 10 seconds
          poorManTimer = Timer(Duration(milliseconds: 10000), () {
            getMessages(friendId);
          });
        }
      }
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: "Error",
          description: err.response?.data["message"],
          buttonText: "Okay",
          images: [],
          callback: () {},
        ),
      );
    }
  }
}
