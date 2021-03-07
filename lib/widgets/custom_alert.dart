///
import 'package:flutter/material.dart';

///
class CustomAlert extends StatelessWidget {
  ///
  final String title, description, firstButtonText;

  ///
  final String secondButtonText;

  ///
  final VoidCallback callback;

  ///
  CustomAlert({
    @required this.title,
    @required this.description,
    @required this.firstButtonText,
    this.callback,
    this.secondButtonText = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    // set up the button
    Widget firstButton = FlatButton(
      child: Text(firstButtonText),
      onPressed: () {
        Navigator.of(context).pop();
        if (callback != null) {
          callback();
        }
      },
    );
    Widget secondButton = FlatButton(
      child: Text(secondButtonText),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cormorant SC',
            fontSize: 24,
            fontWeight: FontWeight.bold),
      ),
      content: Text(
        description,
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'Open Sans',
            fontSize: 16,
            fontWeight: FontWeight.bold),
      ),
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.9),
      actions: [firstButton, secondButton],
    );
  }
}
