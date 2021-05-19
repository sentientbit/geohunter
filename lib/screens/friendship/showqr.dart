import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';

///
import '../../providers/api_provider.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

//import '../app_localizations.dart';

///
class ShowQRPage extends StatefulWidget {
  ///
  double latitude = 51.5;

  ///
  double longitude = 0.0;

  ///
  ShowQRPage({Key key, this.latitude, this.longitude}) : super(key: key);

  @override
  _ShowQRState createState() => _ShowQRState();
}

///
class _ShowQRState extends State<ShowQRPage> {
  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  final ApiProvider _apiProvider = ApiProvider();

  ///
  String _qrEndpoint = '';

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    generateNewQr();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  // ignore: avoid_positional_boolean_parameters
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.of(context).pop();
    return true;
  }

  Future<void> generateNewQr() async {
    if (!mounted) return;
    final response = await _apiProvider.post('/friends', {});
    if (response.containsKey("success")) {
      if (response["success"] == true) {
        if (response.containsKey("friendship_qr")) {
          setState(() {
            _qrEndpoint = response["friendship_qr"];
          });
        }
      }
    }
  }

  Widget build(BuildContext context) {
    /// Application top Bar
    final topBar = AppBar(
      leading: IconButton(
        color: GlobalConstants.appFg,
        icon: Icon(
          Icons.menu,
          // size: 32,
        ),
        onPressed: () => _scaffoldKey != null
            ? _scaffoldKey.currentState.openDrawer()
            : Navigator.of(context).pop(),
      ),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text("Show QR Code", style: Style.topBar),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );

    return Scaffold(
      backgroundColor: GlobalConstants.appBg,
      appBar: topBar,
      extendBodyBehindAppBar: true,
      body: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/reachout_hand.jpg'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(top: 90.0),
          child: Column(children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                top: 20.0, left: 40.0, right: 40.0),
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                'Scan QR Code to befriend',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: <Shadow>[
                                      Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(255, 0, 0, 0))
                                    ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      (_qrEndpoint.length > 0)
                          ? QrImage(
                              errorCorrectionLevel: QrErrorCorrectLevel.M,
                              data: _qrEndpoint,
                              version: QrVersions.auto,
                              size: 240,
                              gapless: true,
                              backgroundColor: Colors.white,
                            )
                          : SizedBox(height: 240.0),
                      SizedBox(height: 10.0),
                      Stack(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                top: 20.0, left: 40.0, right: 40.0),
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                "1. Open the application on friend's phone",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: <Shadow>[
                                      Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(255, 0, 0, 0))
                                    ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                top: 20.0, left: 40.0, right: 40.0),
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                "2. Go to Friends page and tap Scan",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: <Shadow>[
                                      Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(255, 0, 0, 0))
                                    ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                top: 20.0, left: 40.0, right: 40.0),
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                "3. Scan this QR code using the "
                                "application built-in reader.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: <Shadow>[
                                      Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(255, 0, 0, 0))
                                    ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }
}
