///
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

///
import '../../app_localizations.dart';
import '../../models/user.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

///
class LegendPage extends StatelessWidget {
  ///
  User _user = User.blank();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<dynamic> _listViewData = [
    {
      "title": "Mined point",
      "subtitle":
          "When you see that icon it means that you already mined that point",
      "icon": 'assets/images/markers/0.png'
    },
    {
      "title": "Metal",
      "subtitle": "Many items in the game are made of metal including tools, "
          "weapons and armor. The Ore is obtained from mining, "
          "and can be located through world exploration and/or using the map.",
      "icon": 'assets/images/markers/1.png'
    },
    {
      "title": "Wood point",
      "subtitle": "Wood is a porous and fibrous structural tissue found "
          "in the stems and roots of trees and other woody plants.",
      "icon": 'assets/images/markers/2.png'
    },
    {
      "title": "Dangerous Animal",
      "subtitle": "The game allows stalking, and harvesting animals "
          "with the weapons the player starts off with or has earned.",
      "icon": 'assets/images/markers/3.png'
    },
    {
      "title": "Male player",
      "subtitle": "A human player, either a friend, a fellow guild companion, "
          "or someone brave or mad enough to remain in plain sight.",
      "icon": 'assets/images/markers/4.png'
    },
    {
      "title": "Female player",
      "subtitle": "A female protagonist. Although her behavior is "
          "usual, she can set a trap for those who are off-guard.",
      "icon": 'assets/images/markers/5.png'
    },
    {
      "title": "Ruins",
      "subtitle": "The Ruins are the last remnants of a forgotten "
          "civilization. Many powerful items may be hidden in these places, "
          "but most of them must be reassembled and researched.",
      "icon": 'assets/images/markers/6.png'
    },
    {
      "title": "Library",
      "subtitle": "The library is a series of large rooms, where the walls are "
          "lined with books and scrolls. Knowledge can be gained in "
          "these locations in the form of plans and blueprints.",
      "icon": 'assets/images/markers/7.png'
    },
    {
      "title": "Trader",
      "subtitle": "Various traders can be found wandering the land. Trading "
          "items with these merchants may be a good source of coins.",
      "icon": 'assets/images/markers/8.png'
    },
  ];

  ///
  Widget leadingIcon(BuildContext context) {
    // print(" ${_user.details.daily}");
    if (!GlobalConstants.menuHasNotification(_user.details)) {
      return IconButton(
        color: Colors.white,
        icon: Icon(
          Icons.menu,
          color: Colors.white,
        ),
        onPressed: () {
          if (_scaffoldKey.currentState != null) {
            _scaffoldKey.currentState?.openDrawer();
          } else {
            Navigator.of(context).pop();
          }
        },
      );
    }

    return InkWell(
      splashColor: Colors.lightBlue,
      onTap: () {
        if (_scaffoldKey.currentState != null) {
          _scaffoldKey.currentState?.openDrawer();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Center(
        child: Container(
          margin: EdgeInsets.only(left: 10),
          width: 40,
          height: 25,
          child: Stack(
            children: [
              Icon(
                Icons.menu,
                color: Colors.white,
              ),
              Positioned(
                left: 25,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 10,
                      height: 10,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final deviceSize = MediaQuery.of(context).size;

    /// Application top Bar
    final topBar = AppBar(
      brightness: Brightness.dark,
      leading: leadingIcon(context),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text(
        "Help",
        style: Style.topBar,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      //appBar: topBar,
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/moon_light.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Column(
            children: <Widget>[
              ConstrainedBox(
                // height: 0,
                constraints: BoxConstraints(maxHeight: 80),
                child:
                    topBar, //CustomAppBar(Colors.white, Colors.white, _scaffoldKey),
              ),
              SizedBox(
                height: 12,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(8.0),
                  children: _listViewData
                      .map(
                        (data) => ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 23),
                          leading: Image.asset(
                            data["icon"],
                            // color: Colors.white,
                          ),
                          title: Text(
                            data["title"],
                            style: TextStyle(
                              color: Colors.white,
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
                          subtitle: Text(
                            data["subtitle"],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
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
                      )
                      .toList(),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('terms_drawer_label'),
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
                      Navigator.of(context).pushNamed('/terms');
                    },
                  )
                ],
              ),
              Text(
                "version: ${GlobalConstants.appVersion}",
                style: TextStyle(fontSize: 14.0, color: Colors.white),
              ),
            ],
          )
        ],
      ),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }
}
