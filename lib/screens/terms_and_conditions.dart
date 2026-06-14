///
import 'package:flutter/material.dart';

//import 'package:flutter_html/style.dart';//tobeused in 1.0.0
// import 'package:logger/logger.dart';

///
import '../app_localizations.dart';
import '../models/app_error.dart';
import '../providers/api_provider.dart';
import '../shared/app_theme.dart';
import '../shared/constants.dart';
import '../shared/journal_html.dart';
import '../widgets/custom_app_bar.dart';

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

  @override
  void initState() {
    super.initState();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTerms();
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
                children: <Widget>[
                  Expanded(
                    child: kStoneButton(
                      onTap: () {
                        setState(() {
                          _showTerms = true;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.security, color: kGold),
                          const SizedBox(width: 6),
                          Text(
                            "Terms",
                            style: const TextStyle(
                              color: kGold,
                              fontSize: 18,
                              fontFamily: 'Cormorant SC',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: kStoneButton(
                      onTap: () {
                        setState(() {
                          _showTerms = false;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.person, color: kGold),
                          const SizedBox(width: 6),
                          Text(
                            "Privacy",
                            style: const TextStyle(
                              color: kGold,
                              fontSize: 18,
                              fontFamily: 'Cormorant SC',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Server returns HTML (h1/p/…); render it natively
                        // instead of dumping raw tags as text.
                        ...renderJournalHtml(
                          _showTerms ? _terms : _privacy,
                          textColor: Colors.white,
                          fontSize: 16,
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
    } on AppError catch (err) {
      err.show(context, title: 'Main Error');
    } catch (err) {
      debugPrint('_loadTerms unexpected error: $err');
    }
  }
}
