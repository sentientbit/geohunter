///
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

//import 'package:flutter_html/style.dart';//tobeused in 1.0.0
// import 'package:logger/logger.dart';

///
import '../app_localizations.dart';
import '../providers/api_provider.dart';
import '../shared/constants.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_dialog.dart';

///
class TermsAndPrivacyPage extends StatefulWidget {
  ///
  static String tag = 'terms';
  @override
  _TermsAndPrivacyPageState createState() => _TermsAndPrivacyPageState();
}

class _TermsAndPrivacyPageState extends State<TermsAndPrivacyPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  final ApiProvider _apiProvider = ApiProvider();
  String _terms = '';
  String _privacy = '';
  bool _showTerms = true;
  bool _showPrivacy = false;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTerms();
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
                image: AssetImage('assets/images/black_night.jpg'),
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
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      backgroundColor: GlobalConstants.appBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      side: BorderSide(width: 1, color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        _showPrivacy = false;
                        _showTerms = true;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.security, color: Color(0xffe6a04e)),
                        Text(
                          " Terms",
                          style: TextStyle(
                            color: Color(0xffe6a04e),
                            fontSize: 18,
                            fontFamily: 'Cormorant SC',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      backgroundColor: GlobalConstants.appBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      side: BorderSide(width: 1, color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        _showPrivacy = true;
                        _showTerms = false;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.person, color: Color(0xffe6a04e)),
                        Text(
                          " Privacy",
                          style: TextStyle(
                            color: Color(0xffe6a04e),
                            fontSize: 18,
                            fontFamily: 'Cormorant SC',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    // height: deviceSize.height,
                    // width: deviceSize.width,
                    padding: EdgeInsets.only(
                        top: 10.0, left: 10.0, bottom: 10.0, right: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _showTerms ? _terms : _privacy,
                          style: TextStyle(
                            color: Color(0xffffffff),
                            fontSize: 18,
                            fontFamily: 'Cormorant SC',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _loadTerms() async {
    try {
      // print();
      final requestTerms = await _apiProvider.get(
          "https://${GlobalConstants.apiHostUrl}/api/docs?docname=terms&lang=${AppLocalizations.of(context)!.locale.languageCode}");
      final requesPrivacyt = await _apiProvider.get(
          "https://${GlobalConstants.apiHostUrl}/api/docs?docname=privacy&lang=${AppLocalizations.of(context)!.locale.languageCode}");
      // log.d(request["message"]);
      setState(() {
        _terms = requestTerms["message"];
        _privacy = requesPrivacyt["message"];
      });
      // print();
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Main Error',
          description: err.error.toString(),
          buttonText: "Okay",
          images: [],
          callback: () {},
        ),
      );
    }
  }
}
