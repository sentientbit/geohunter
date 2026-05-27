///
import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';

///
import '../widgets/custom_app_bar.dart';

///
class EmptyPage extends StatefulWidget {
  ///
  static String tag = 'empty';
  @override
  _EmptyPageState createState() => _EmptyPageState();
}

class _EmptyPageState extends State<EmptyPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    // final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/tools.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Column(
            children: <Widget>[
              ConstrainedBox(
                  // height: 0,
                  constraints: BoxConstraints(maxHeight: 80),
                  child: CustomAppBar(
                    Colors.white,
                    Colors.white,
                    _scaffoldKey,
                    icon: Icon(Icons.arrow_back),
                  )),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    // height: deviceSize.height,
                    // width: deviceSize.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        for (var i = 1; i <= 100; i++)
                          Text(
                            "Empty page",
                            style: TextStyle(color: Colors.white),
                          )
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
