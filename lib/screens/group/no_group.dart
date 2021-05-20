///
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geohunter/models/guild.dart';
//import 'package:logger/logger.dart';

///
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../providers/custom_interceptors.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';
import 'create_group.dart';
import 'join_group.dart';

//import '../app_localizations.dart';

///
class NoGroup extends StatefulWidget {
  @override
  _NoGroupState createState() => _NoGroupState();
}

class _NoGroupState extends State<NoGroup> {
  final ApiProvider _apiProvider = ApiProvider();

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _guilds = [];

  //final Logger log = Logger(
  //    printer: PrettyPrinter(
  //        colors: true, printEmojis: true, printTime: true, lineLength: 80));

  /// Curent loggedin user
  User _user;

  String userGuildId = "0";

  ///
  int maxNrGuilds = 100;

  @override
  void initState() {
    super.initState();
    _getUserDetails(context);
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

  Widget _makeCard(BuildContext context, int index) {
    if (_guilds.isEmpty) {
      return SizedBox(width: 1);
    }
    return Card(
      color: Color.fromRGBO(19, 21, 20, 0.8),
      elevation: 8.0,
      margin: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 6.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          //color: Color.fromRGBO(19, 21, 20, 0.7),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 33.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: _makeListTile(context, index),
      ),
    );
  }

  Widget _makeListTile(BuildContext context, int index) {
    var netImg = Image(
      image: AssetImage('assets/images/guild-ornament.jpg'),
      height: 76.0,
      width: 76.0,
    );

    var nrUsers = _guilds[index].nrUsers.toString();
    var locked = (_guilds[index].isLocked > 0) ? "Password locked" : "Open";

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      leading: Container(
        padding: EdgeInsets.only(right: 12.0),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              width: 1.0,
              color: Color(0xff333333),
            ),
          ),
        ),
        child: Stack(
          children: <Widget>[
            netImg,
            Positioned(
              right: 0.0,
              bottom: 0.0,
              child: Text(
                '123',
              ),
            ),
          ],
        ),
      ),
      title: Text(
        _guilds[index].name,
        style: TextStyle(
          color: Color(0xffe6a04e),
          fontFamily: "Cormorant SC",
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10.0),
          Text(
            "Nr. users: $nrUsers",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10.0),
          Text(
            locked,
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
      trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JoinGroup(
              guid: _guilds[index].guid,
              isLocked: _guilds[index].isLocked,
              title: _guilds[index].name,
            ),
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    ///
    void _goJoin(BuildContext context) {
      //Navigator.of(context).pushNamed('/quests-full-page', arguments: quest);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinGroup(
            guid: "",
            isLocked: 0,
            title: "",
          ),
        ),
      );
    }

    ///
    void _goCreate(BuildContext context) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateGroup()));
    }

    final myguildButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/in-group');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.redo, color: Color(0xffe6a04e)),
          Text(
            " My guild",
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

    final createButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: () => _goCreate(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.add, color: Color(0xffe6a04e)),
          Text(
            " Create new",
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

    final joinButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: () => _goJoin(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.redo, color: Color(0xffe6a04e)),
          Text(
            " Join private",
            style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

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
      title: Text("Guilds", style: Style.topBar),
    );

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
                image: AssetImage('assets/images/bar.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(40.0),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Welcome to Guilds",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cormorant SC',
                    fontWeight: FontWeight.bold,
                    fontSize: 40.0,
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
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Guilds are special groups of players "
                  "bounded by a common goal.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.bold,
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
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 0),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      (userGuildId != "0") ? myguildButton : createButton,
                      (userGuildId != "0") ? Text("") : joinButton,
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: CustomScrollView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: false,
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'List of Public Guilds',
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
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            for (var i = 0;
                                i <
                                    ((_guilds.length > maxNrGuilds)
                                        ? maxNrGuilds
                                        : _guilds.length);
                                i++)
                              _makeCard(context, i),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }

  void _getAllGuilds() async {
    _guilds.clear();
    try {
      final response = await _apiProvider.get('/guilds');

      final guilds = [];
      if (response.containsKey("success")) {
        if (response["success"] == true) {
          for (dynamic elem in response["guilds"]) {
            guilds.add(
              Guild(
                id: int.tryParse(elem["id"]) ?? 0,
                guid: elem["guid"],
                name: elem["name"],
                isHidden: int.tryParse(elem["is_hidden"]) ?? 0,
                isLocked: int.tryParse(elem["is_locked"]) ?? 0,
                nrUsers: elem["users"].length,
              ),
            );
          }
        }
      }
      setState(() {
        _guilds.addAll(guilds.toList());
      });
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data["message"]);
      } else {
        print(e.response.statusCode);
        print(e.message);
      }
    }
  }

  void _getUserDetails(BuildContext context) async {
    final response = await _apiProvider.get('/profile');
    final tmp =
        await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl);

    if (response.containsKey("success")) {
      if (response["success"] == true) {
        tmp["jwt"] = response["jwt"];
        tmp["user"] = response["user"];
        await CustomInterceptors.setStoredCookies(
            GlobalConstants.apiHostUrl, tmp);
      }
    }

    setState(() {
      _user = User.fromJson(tmp);
      userGuildId = _user.details.guildId;
    });

    //log.d('--- user ---');
    //log.d(_user.user);
    /// Make sure if we are in No-Group Screen
    /// but we should be in a guild do a redirect
    // if (_user.details.guildId != "0") {
    //   Navigator.of(context).pushReplacementNamed('/in-group');
    //   return;
    // }

    await _getAllGuilds();
  }
}
