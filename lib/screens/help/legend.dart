///
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

///
import '../../shared/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/drawer.dart';

///
class LegendPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _appVersion = GlobalConstants.appVersion;

  final List<dynamic> _listViewData = [
    {
      "title": "Mined point",
      "subtitle":
          "When you see that icon it means that you already mined that point",
      "icon": '0.png'
    },
    {
      "title": "Metal",
      "subtitle": "Many items in the game are made of metal including tools, "
          "weapons and armor. The Ore is obtained from mining, "
          "and can be located through world exploration and/or using the map.",
      "icon": '1.png'
    },
    {
      "title": "Wood point",
      "subtitle": "Wood is a porous and fibrous structural tissue found "
          "in the stems and roots of trees and other woody plants.",
      "icon": '2.png'
    },
    {
      "title": "Dangerous Animal",
      "subtitle": "The game allows stalking, and harvesting animals "
          "with the weapons the player starts off with or has earned.",
      "icon": '3.png'
    },
    {
      "title": "Male player",
      "subtitle": "A human player, either a friend, a fellow guild companion, "
          "or someone brave or mad enough to remain in plain sight.",
      "icon": '4.png'
    },
    {
      "title": "Female player",
      "subtitle": "A female protagonist. Although her behavior is "
          "usual, she can set a trap for those who are off-guard.",
      "icon": '5.png'
    },
    {
      "title": "Ruins",
      "subtitle": "The Ruins are the last remnants of a forgotten "
          "civilization. Many powerful items may be hidden in these places, "
          "but most of them must be reassembled and researched.",
      "icon": '6.png'
    },
    {
      "title": "Library",
      "subtitle": "The library is a series of large rooms, where the walls are "
          "lined with books and scrolls. Knowledge can be gained in "
          "these locations in the form of plans and blueprints.",
      "icon": '7.png'
    },
    {
      "title": "Trader",
      "subtitle": "Various traders can be found wandering the land. Trading "
          "items with these merchants may be a good source of coins.",
      "icon": '8.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
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
                      CustomAppBar(Colors.white, Colors.white, _scaffoldKey)),
              SizedBox(
                height: 12,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(8.0),
                  children: _listViewData
                      .map((data) => ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 23),
                            leading: Image.asset(
                              'assets/images/markers/${data["icon"]}',
                              // color: Colors.white,
                            ),
                            title: Text(
                              data["title"],
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              data["subtitle"],
                              style: TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
                ),
              ),
              Text(
                // ignore: lines_longer_than_80_chars
                "version: $_appVersion",
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
