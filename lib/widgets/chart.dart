import 'package:flutter/material.dart';

///
class Chart extends StatelessWidget {
  ///
  final String imgUrl;

  ///
  Chart({this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Image.network(
          imgUrl,
          fit: BoxFit.fill,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      margin: EdgeInsets.all(10),
    );
  }
}
