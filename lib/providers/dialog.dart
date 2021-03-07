// import 'package:flutter/material.dart';

// class DialogProvider extends StatefulWidget {
//   static String tag = 'login-page';
//   Exception _err;
//   DialogProvider(Exception err) {
//     this._err = err;
//   }
//   @override
//   _DialogProviderState createState() => new _DialogProviderState();
// }

// class _DialogProviderState extends State<DialogProvider> {
//   showErr() async {
//     showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(widget._err.toString().replaceAll("Exception:", "")),
//           content: Text(widget._err.toString().replaceAll("Exception:", "")),
//           actions: <Widget>[
//             FlatButton(
//               child: Text('Ok'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 // MaterialPageRoute(builder: (context) => PoiMap()),
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return showErr();
//   }
// }
