///
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
//import 'package:logger/logger.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

///
import '../../app_localizations.dart';
import '../../fonts/rpg_awesome_icons.dart';
import '../../models/research.dart';
import '../../providers/api_provider.dart';
import '../../providers/stream_userdata.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';

///
class StudyDetailPage extends StatefulWidget {
  /// Widget name
  final String name = "Study";

  ///
  final Research research;

  ///
  List<dynamic> blueprints;

  ///
  StudyDetailPage({
    Key? key,
    required this.research,
    required this.blueprints,
  }) : super(key: key);

  @override
  _StudyDetailState createState() => _StudyDetailState();
}

///
class _StudyDetailState extends State<StudyDetailPage> {
  final _userdata = getIt.get<StreamUserData>();

  double _nrInvBlueprints = 0;
  String _btnDisText = "0";
  String _blueprintImg = "";
  String _blueprintName = "";
  int _currentPoints = 0;
  int _neededPoints = 1;
  int _lowerPoints = 0;
  int _nrAvailBlueprints = 0;
  int _maxNr = 0;

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  final ApiProvider _apiProvider = ApiProvider();

  /// Make sure back button is pressed twice
  bool ifPop = false;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _currentPoints = widget.research.nrInvested;
    var currentLvl = researchToCrafting(_currentPoints);
    // Points needed to reach next level
    _neededPoints = craftingToResearch(currentLvl + 1);
    // Points needed to be at the current level (used as zero indicator)
    _lowerPoints = craftingToResearch(currentLvl);
    //var percentage = currentXp / neededXp;

    for (dynamic blp in widget.blueprints) {
      if (widget.research.blueprint.id == blp.id) {
        _nrAvailBlueprints = blp.nr;
      }
    }

    if (_nrAvailBlueprints > (_neededPoints - _currentPoints)) {
      _maxNr = (_neededPoints - _currentPoints);
    } else {
      _maxNr = _nrAvailBlueprints;
    }

    _blueprintImg = widget.research.blueprint.img;
    _blueprintName = widget.research.blueprint.name;
    BackButtonInterceptor.add(myInterceptor,
        name: widget.name, context: context);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  // ignore: avoid_positional_boolean_parameters
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (stopDefaultButtonEvent) return false;
    if (ifPop) {
      return false;
    } else {
      setState(() => ifPop = true);
      if (_scaffoldKey != null) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(GlobalConstants.backButtonPage);
      }
    }
    return true;
  }

  Widget build(BuildContext context) {
    //ignore: omit_local_variable_types
    double halfScreenSize =
        (MediaQuery.of(context).size.height * 0.5) - 40 /* appbar is 80px */;

    /// Application top Bar
    final topBar = AppBar(
      leading: IconButton(
        color: GlobalConstants.appFg,
        icon: Icon(
          Icons.menu,
          // size: 32,
        ),
        onPressed: () => _scaffoldKey != null
            ? _scaffoldKey.currentState?.openDrawer()
            : Navigator.of(context).pop(),
      ),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text("Study", style: Style.topBar),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );

    final topContentText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        (widget.research.nrInvested > 0)
            ? Image(
                image:
                    AssetImage('assets/images/research/${widget.research.img}'),
                height: 180.0,
                width: 180.0,
              )
            : Image(
                image: AssetImage('assets/images/research/unknown.png'),
                height: 180.0,
                width: 180.0,
              ),
        Text(
          widget.research.name,
          style: TextStyle(
            color: GlobalConstants.appFg,
            fontSize: 24.0,
            fontFamily: "Cormorant SC",
            fontWeight: FontWeight.bold,
            shadows: <Shadow>[
              Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 3.0,
                  color: Color.fromARGB(255, 0, 0, 0))
            ],
          ),
        ),
        SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 40,
                width: 180,
                child: LinearPercentIndicator(
                  lineHeight: 14.0,
                  percent: ((_currentPoints - _lowerPoints) / _neededPoints),
                  center: Text(
                    "$_currentPoints / $_neededPoints",
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  backgroundColor: Colors.white,
                  progressColor: Colors.orange,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        Research.skill(widget.research.nrInvested),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(' '),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ],
    );

    final topContent = Stack(
      children: <Widget>[
        Container(
          height: halfScreenSize,
          padding: EdgeInsets.only(top: 10.0, left: 40.0, right: 40.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Color(0xcc222222)),
          child: Center(
            child: topContentText,
          ),
        ),
      ],
    );

    final researchButton = Padding(
      padding: EdgeInsets.all(0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding:
              EdgeInsets.only(top: 8.0, left: 0.0, bottom: 8.0, right: 0.0),
          backgroundColor: GlobalConstants.appBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(width: 1, color: Colors.white),
        ),
        onPressed: () => _studyResearch(context, widget.research.id),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(RPGAwesome.book, color: Color(0xffe6a04e)),
            Text(
              " ${_btnDisText}",
              style: TextStyle(
                  color: Color(0xffe6a04e),
                  fontSize: 24,
                  fontFamily: 'Cormorant SC',
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    final bottomContent = Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(40.0),
          //width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Color(0xcc000000)),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Study',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Color(0xffe6a04e),
                      fontSize: 24,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold),
                ),
                (_blueprintImg != "")
                    ? Image.asset(
                        "assets/images/blueprints/$_blueprintImg",
                        height: 180.0,
                        width: 180.0,
                      )
                    : Image.asset(
                        "assets/images/blueprints/nothing.png",
                        height: 180.0,
                        width: 180.0,
                      ),
                Text(
                  " ${_nrInvBlueprints.toInt().toString()} / $_nrAvailBlueprints $_blueprintName",
                  style:
                      TextStyle(color: GlobalConstants.appFg, fontSize: 18.0),
                ),
                SizedBox(height: 18),
                Text(
                  "Study enough blueprints to advance to the next "
                  "knowledge level. Better skills come with better bonuses.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/items/gold3coins.png",
                      height: 80.0,
                      width: 80.0,
                    ),
                    Text(
                      "${(_nrInvBlueprints * GlobalConstants.researchCost).toString()} Coins needed",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                (_maxNr > 0)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 180,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Color(0xffe6a04e),
                                inactiveTrackColor: Colors.white,
                                trackShape: RectangularSliderTrackShape(),
                                trackHeight: 4.0,
                                thumbColor: Color(0xffe6a04e),
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 12.0),
                                overlayColor: Colors.red.withAlpha(32),
                                overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 28.0),
                              ),
                              // min 0, max 100, div 5, means 20 per division
                              child: Slider(
                                min: 0,
                                max: _maxNr.toDouble(),
                                value: _nrInvBlueprints,
                                divisions: _maxNr,
                                onChanged: (value) {
                                  setState(() {
                                    _nrInvBlueprints = value;
                                    _btnDisText =
                                        _nrInvBlueprints.toInt().toString();
                                  });
                                },
                              ),
                            ),
                          ),
                          researchButton,
                        ],
                      )
                    : Column(
                        children: [
                          SizedBox(height: 12),
                          Text(
                            'Not enough blueprints',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: 58),
              ],
            ),
          ),
        ),
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
              image: AssetImage('assets/images/research_study.jpg'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(top: 80.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        topContent,
                        bottomContent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }

  void _studyResearch(context, researchId) async {
    var nrBlp = _nrInvBlueprints.toInt();

    if (nrBlp <= 0) {
      return;
    }

    dynamic response;
    try {
      response = await _apiProvider.post("/research/$researchId/$nrBlp", {});
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description: err.response?.data["message"],
          buttonText: "Okay",
          images: [],
          callback: () {},
        ),
      );
      return;
    }
    if (response["success"] == true) {
      if (response.containsKey("coins")) {
        _userdata.updateUserData(
          double.tryParse(response["coins"].toString()) ?? 0.0,
          0,
          response["guild"]["id"],
          response["xp"],
          response["unread"],
          response["attack"],
          response["defense"],
        );
      }
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: AppLocalizations.of(context)!.translate('congrats'),
          description: response["message"],
          buttonText: "Okay",
          images: [],
          callback: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/research');
          },
        ),
      );
    }
    return;
  }
}
