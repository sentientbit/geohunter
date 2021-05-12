/// based on https://medium.com/@afegbua/this-is-the-second-part-of-the-beautiful-list-ui-and-detail-page-article-ecb43e203915
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
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
  //final Logger log = Logger(
  //    printer: PrettyPrinter(
  //        colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  final ApiProvider _apiProvider = ApiProvider();

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  Widget privacyWidget(Friend friend) {
    if ((friend.locationPrivacy & 1) == 1) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(16),
          backgroundColor: GlobalConstants.appBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(width: 1, color: Colors.white),
        ),
        onPressed: () {
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
        child: Text(
          "Go to user location",
          style: TextStyle(
              color: Color(0xffe6a04e),
              fontSize: 18,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.bold),
        ),
      );
    }
    return Row(
      children: <Widget>[
        Icon(
          Icons.location_disabled,
          size: 24,
          color: Colors.white,
        ),
        SizedBox(width: 10.0),
        Text(
          'Location is private',
          style: TextStyle(color: GlobalConstants.appFg, fontSize: 18.0),
        ),
      ],
    );
  }

  Widget build(BuildContext context) {
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
          borderRadius: BorderRadius.circular(5.0)),
      child: Text(
        "Lvl ${expToLevel(int.tryParse(widget.friend.xp) ?? 0)}",
        style: TextStyle(color: GlobalConstants.appFg, fontSize: 18.0),
      ),
    );

    final topContentText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Image(
          image: NetworkImage(
              'https://${GlobalConstants.apiHostUrl}${widget.friend.thumbnail}'),
          height: 200.0,
          width: 200.0,
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Container(
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.keyboard_arrow_up,
                      size: 16,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        " Experience ${widget.friend.xp}",
                        style: TextStyle(
                            color: GlobalConstants.appFg, fontSize: 18.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(flex: 2, child: expLevel)
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
          decoration: BoxDecoration(color: Color(0xcc222222)),
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
          decoration: BoxDecoration(color: Color(0xcc000000)),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Explore together',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Color(0xffe6a04e),
                      fontSize: 24,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold),
                ),
                Image.asset(
                  "assets/images/scroll.png",
                  height: 180.0,
                  width: 180.0,
                ),
                privacyWidget(widget.friend),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[],
                ),
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
                      children: <Widget>[topContent, bottomContent],
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
