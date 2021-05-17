/// based on https://medium.com/@afegbua/this-is-the-second-part-of-the-beautiful-list-ui-and-detail-page-article-ecb43e203915
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
//import 'package:logger/logger.dart';

///
import '../../models/friends.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';
import '../../providers/api_provider.dart';
import '../../screens/map_explore.dart' show PoiMap;

//import '../app_localizations.dart';

///
class PalDetailPage extends StatefulWidget {
  ///
  final Friend friend;

  ///
  PalDetailPage({Key key, this.friend}) : super(key: key);

  @override
  _PalDetailState createState() => _PalDetailState();
}

///
class _PalDetailState extends State<PalDetailPage> {
  TextEditingController _controller = new TextEditingController();

  //final Logger log = Logger(
  //    printer: PrettyPrinter(
  //        colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  final ApiProvider _apiProvider = ApiProvider();

  ///
  int currentLevel = 0;

  ///
  int nextExperienceLevel = 1;

  ///
  int currentExperience = 0;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _controller.text = '';
    super.initState();
    currentExperience = int.tryParse(widget.friend.xp) ?? 0;
    currentLevel = expToLevel(currentExperience);
    nextExperienceLevel = levelToExp(currentLevel + 1);
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

  Widget privacyWidget(Friend friend) {
    if ((friend.locationPrivacy & 1) == 1) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PoiMap(
                goToRemoteLocation: true,
                latitude: friend.lat,
                longitude: friend.lng,
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
    int xp,
    int currentExperience,
    int nextExperienceLevel,
    Color color,
  ) {
    // ignore: omit_local_variable_types
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
    var szWidth = MediaQuery.of(context).size.width;

    //ignore: omit_local_variable_types
    double halfScreenSize =
        (MediaQuery.of(context).size.height * 0.5) - 40 /* appbar is 80px */;

    /// Application top Bar
    final topBar = AppBar(
      leading: IconButton(
        color: GlobalConstants.appFg,
        icon: Icon(
          Icons.menu,
          // size: 32,
        ),
        onPressed: () => _scaffoldKey != null
            ? _scaffoldKey.currentState.openDrawer()
            : Navigator.of(context).pop(),
      ),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text(widget.friend.username, style: Style.topBar),
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
        "Lvl ${expToLevel(int.tryParse(widget.friend.xp) ?? 0)}",
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
                  'https://${GlobalConstants.apiHostUrl}${widget.friend.thumbnail}'),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(width: 16),
            privacyWidget(widget.friend),
          ],
        ),
        SizedBox(height: 20.0),
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
              flex: 6,
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
              flex: 6,
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
          padding: EdgeInsets.all(40.0),
          //width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Color(0xaa000000),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Raven Message',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xffe6a04e),
                    fontSize: 24,
                    fontFamily: 'Cormorant SC',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Stack(
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
                    Padding(
                      padding: EdgeInsets.only(
                        left: 50.0,
                        right: 50.0,
                        top: 21.0,
                      ),
                      child: Text(
                        "The kracken tall blond women axe kea axes scandinavia Leif Erikson horns. Lack the table terror Leif Erikson ikea terror ocean boats viking.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Cormorant SC',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 10,
                      child: TextFormField(
                        autofocus: false,
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Send up to 140 chars',
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
                      child: Icon(
                        Icons.flight_takeoff,
                        size: 32,
                        color: Colors.white,
                      ),
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
}
