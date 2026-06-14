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
  final bool hasNotification;

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

  /// White icon with a black shadow halo, legible on any map background.
  static const List<Shadow> _iconHalo = [
    Shadow(color: Colors.black, blurRadius: 4),
    Shadow(color: Colors.black, blurRadius: 4),
  ];

  ///
  Widget leadingIcon(BuildContext context) {
    if (!hasNotification) {
      return IconButton(
        icon: Icon(
          icon.icon ?? Icons.menu,
          color: Colors.white,
          shadows: _iconHalo,
        ),
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
                shadows: _iconHalo,
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

  /// App name rendered as white text with a black outline (stroke behind fill),
  /// so it stays legible on any background — bright satellite or dark tiles.
  Widget _outlinedTitle() {
    const base = TextStyle(
      fontSize: 26,
      fontFamily: "Cormorant SC",
      fontWeight: FontWeight.w800,
    );
    return Stack(
      children: <Widget>[
        // Black outline. A leaner stroke (2.2) relative to the bigger/bolder
        // letters so it edges the glyphs without swallowing their white fill.
        Text(
          GlobalConstants.appName,
          style: base.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.2
              ..color = Colors.black,
          ),
        ),
        // White fill, plus a soft dark shadow for extra separation on busy tiles.
        Text(
          GlobalConstants.appName,
          style: base.copyWith(
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _outlinedTitle(),
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0.0,
      leading: leadingIcon(context),
    );
  }
}
