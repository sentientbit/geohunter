///
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';

///
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../providers/custom_interceptors.dart';
import '../../screens/group/createGroup.dart';
import '../../screens/group/joinGroup.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

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

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  /// Curent loggedin user
  User _user;

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

  Widget build(BuildContext context) {
    ///
    void _goJoin(BuildContext context) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => JoinGroup()));
    }

    ///
    void _goCreate(BuildContext context) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateGroup()));
    }

    final createButton = RaisedButton(
      shape: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white, width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: () => _goCreate(context),
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
    );

    final joinButton = RaisedButton(
      shape: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white, width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: () => _goJoin(context),
      padding: EdgeInsets.all(16),
      color: Colors.black,
      child: Text(
        'Join',
        style: TextStyle(
            color: Color(0xffe6a04e),
            fontSize: 18,
            fontFamily: 'Cormorant SC',
            fontWeight: FontWeight.bold),
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
                padding: EdgeInsets.all(80.0),
                child: Image.asset("assets/images/scroll.png"),
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
                          color: Color.fromARGB(255, 0, 0, 0))
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Since you are not in a guild, you can select either "
                  "to join an existing one or create a brand new guild.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: <Shadow>[
                      Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0))
                    ],
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 50, left: 0),
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        createButton,
                        joinButton,
                      ],
                    ),
                  )),
            ],
          ),
        ],
      ),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }

  void _getUserDetails(BuildContext context) async {
    final response = await _apiProvider.get('/profile');
    final tmp =
        await CustomInterceptors.getStoredCookies(GlobalConstants.apiHostUrl);

    if (response["success"] == true) {
      tmp["jwt"] = response["jwt"];
      tmp["expiresAt"] = response["expiresAt"];
      tmp["user"] = response["user"];
      await CustomInterceptors.setStoredCookies(
          GlobalConstants.apiHostUrl, tmp);
    }

    setState(() {
      _user = User.fromJson(tmp);
    });

    //log.d('--- user ---');
    //log.d(_user.user);
    /// Make sure if we are in No-Group Screen
    /// but we should be in a guild do a redirect
    if (_user.details.guild.id != "0") {
      Navigator.of(context).pushReplacementNamed('/in-group');
    }
  }
}
