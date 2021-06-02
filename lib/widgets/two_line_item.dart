///
import 'package:flutter/material.dart';

///
import '../shared/constants.dart';

///
class TwoLineItem extends StatelessWidget {
  ///
  String firstText = "";
  String secondText = "";
  bool hasIcon = false;
  Icon iconResource = Icon(Icons.ac_unit);

  ///
  TwoLineItem({
    Key? key,
    required this.firstText,
    required this.secondText,
    required this.hasIcon,
    required this.iconResource,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          firstText,
          style: TextStyle(
            color: GlobalConstants.appFg,
            fontFamily: "Open Sans",
            fontWeight: FontWeight.bold,
            fontSize: 14,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Color.fromARGB(255, 0, 0, 0),
              )
            ],
          ),
        ),
        hasIcon
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  iconResource,
                  Text(
                    secondText,
                    style: TextStyle(
                      color: GlobalConstants.appFg,
                      fontFamily: "Open Sans",
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        )
                      ],
                    ),
                  ),
                ],
              )
            : Text(
                secondText,
                style: TextStyle(
                  color: GlobalConstants.appFg,
                  fontFamily: "Open Sans",
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    )
                  ],
                ),
              )
      ],
    );
  }
}
