import 'package:flutter/material.dart';
import 'shared/constants.dart';

///
class Style {
  ///
  final bool log = false;

  ///
  static final TextStyle baseTextStyle =
      const TextStyle(fontFamily: 'Open Sans');

  ///
  static final TextStyle smallTextStyle = commonTextStyle.copyWith(
    decoration: TextDecoration.none,
    fontSize: 12.0,
  );

  ///
  static final TextStyle averageTextStyle = commonTextStyle.copyWith(
    decoration: TextDecoration.none,
    fontSize: 14.0,
    color: GlobalConstants.appFg,
  );

  ///
  static final TextStyle menuTextStyle = baseTextStyle.copyWith(
      decoration: TextDecoration.none,
      color: Colors.white,
      fontSize: 18.0,
      fontFamily: "Cormorant SC",
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
            offset: Offset(1.0, 1.0),
            blurRadius: 3.0,
            color: Color.fromARGB(255, 0, 0, 0))
      ]);

  ///
  static final TextStyle topBar = baseTextStyle.copyWith(
    color: GlobalConstants.appFg,
    fontFamily: "Cormorant SC",
    fontWeight: FontWeight.bold,
    shadows: <Shadow>[
      Shadow(
        offset: Offset(1.0, 1.0),
        blurRadius: 3.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
    ],
  );

  ///
  static final TextStyle commonTextStyle = baseTextStyle.copyWith(
      decoration: TextDecoration.none,
      color: Colors.white,
      fontSize: 14.0,
      fontWeight: FontWeight.normal);

  ///
  static final TextStyle titleTextStyle = baseTextStyle.copyWith(
      decoration: TextDecoration.none,
      color: const Color(0xffe6a04e),
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Cormorant SC');

  ///
  static final TextStyle headerTextStyle = baseTextStyle.copyWith(
      decoration: TextDecoration.none,
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.w400);
}
