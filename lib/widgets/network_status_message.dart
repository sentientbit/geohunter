import 'package:flutter/material.dart';

///
class NetworkStatusMessage extends StatelessWidget {
  ///
  const NetworkStatusMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(children: <Widget>[
        Positioned(
          height: 44.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            color: Color(0xFFEE4400),
            child: Center(
              child: Text(
                "PLEASE CHECK YOUR WIFI OR MOBILE DATA",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        )
      ]),
    );
  }
}
