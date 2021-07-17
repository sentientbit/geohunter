///
import 'package:flutter/material.dart';

//import 'package:logger/logger.dart';

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
  bool hasNotification = false;

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
    this.hasNotification = false,
  }) : super(key: key);

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  Widget leadingIcon(BuildContext context) {
    if (!hasNotification) {
      return IconButton(
        color: iconColor,
        icon: icon,
        onPressed: () {
          if (scaffoldKey.currentState != null) {
            scaffoldKey.currentState?.openDrawer();
          } else {
            Navigator.of(context).pop();
          }
        },
      );
    }

    return InkWell(
      splashColor: Colors.lightBlue,
      onTap: () {
        if (scaffoldKey.currentState != null) {
          scaffoldKey.currentState?.openDrawer();
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
      leading: leadingIcon(context),
    );
  }
}
