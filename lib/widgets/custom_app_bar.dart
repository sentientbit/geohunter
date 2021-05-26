///
import 'package:flutter/material.dart';

import 'package:logger/logger.dart';

///
import '../shared/constants.dart';

// final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

///
class CustomAppBar extends StatelessWidget {
  ///
  final Color textColor;

  ///
  final Color iconColor;

  ///
  final Brightness systemHeaderBrightness;

  ///
  final GlobalKey<ScaffoldState> scaffoldKey;

  ///
  final Icon icon;

  ///
  CustomAppBar(
    this.textColor,
    this.iconColor,
    this.scaffoldKey, {
    Key? key,
    this.systemHeaderBrightness = Brightness.dark,
    this.icon = const Icon(
      Icons.menu,
      // size: 32,
    ),
  }) : super(key: key);

  final Logger log = Logger(
      printer: PrettyPrinter(
          colors: true, printEmojis: true, printTime: true, lineLength: 80));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      brightness: systemHeaderBrightness,
      title: Text(
        GlobalConstants.appName,
        style: TextStyle(
          color: textColor,
          fontFamily: "Cormorant SC",
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0.0,
      leading: IconButton(
        color: iconColor,
        icon: icon,
        onPressed: () {
          if (scaffoldKey.currentState != null) {
            scaffoldKey.currentState?.openDrawer();
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
