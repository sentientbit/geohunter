/// based on https://medium.com/@afegbua/this-is-the-second-part-of-the-beautiful-list-ui-and-detail-page-article-ecb43e203915
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:geohunter/fonts/rpg_awesome_icons.dart';
//import 'package:logger/logger.dart';
import '../../models/blueprint.dart';

///
import '../../models/research.dart';
import '../../providers/api_provider.dart';
import '../../screens/inventory/study.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

///
class ResearchPage extends StatefulWidget {
  /// Widget name
  final String name = "research";

  @override
  _ResearchState createState() => _ResearchState();
}

///
class _ResearchState extends State<ResearchPage> {
  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  final ApiProvider _apiProvider = ApiProvider();

  /// Make sure back button is pressed twice
  bool ifPop = false;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ///
  final _techs = [];

  ///
  final _blueprints = [];

  @override
  void initState() {
    super.initState();
    _getTechResearches();
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

  Widget _makeListTile(BuildContext context, int index) {
    var netImg = (_techs[index].nrInvested > 0)
        ? Image(
            image: AssetImage('assets/images/research/${_techs[index].img}'),
            height: 76.0,
            width: 76.0,
          )
        : Image(
            image: AssetImage('assets/images/research/unknown.png'),
            height: 76.0,
            width: 76.0,
          );

    var currentPoints = _techs[index].nrInvested;
    var currentLvl = researchToCrafting(currentPoints);
    // Points needed to reach next level
    var neededPoints = craftingToResearch(currentLvl + 1);
    // Points needed to be at the current level (used as zero indicator)
    var lowerPoints = craftingToResearch(currentLvl);
    var percentage = (currentPoints - lowerPoints) / neededPoints;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                width: 1.0,
                color: Color(0xff333333),
              ),
            ),
          ),
          child: Stack(children: <Widget>[
            netImg,
            Positioned(
              right: 0.0,
              bottom: 0.0,
              child: Text(
                _techs[index].nrInvested.toString(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ])),
      title: Text(
        _techs[index].name,
        style: TextStyle(
          color: Colors.white,
          fontFamily: "Cormorant SC",
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              // tag: 'hero',
              child: LinearProgressIndicator(
                backgroundColor: Color.fromRGBO(209, 224, 224, 0.2),
                value: percentage,
                valueColor: AlwaysStoppedAnimation(Color(0xfffeb53b)),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                Research.skill(_techs[index].nrInvested),
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudyDetailPage(
              research: _techs[index],
              blueprints: _blueprints,
            ),
          ),
        );
      },
    );
  }

  Widget _makeCard(BuildContext context, int index) {
    return Card(
      color: Color.fromRGBO(19, 21, 20, 0.8),
      elevation: 8.0,
      margin: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 6.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          //color: Color.fromRGBO(19, 21, 20, 0.7),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 33.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: _makeListTile(context, index),
      ),
    );
  }

  Widget build(BuildContext context) {
    //ignore: omit_local_variable_types
    int currentTabIndex = 1;

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
      title: Text(
        "Research",
        style: Style.topBar,
      ),
    );

    /// What happens when clicking the Bottom Navbar
    onTapped(int index) {
      setState(() {
        currentTabIndex = index;
      });
      if (index == 0) {
        //Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed('/forge');
      }
      /* if index == 1 We are here: Research */
    }

    return Scaffold(
      backgroundColor: GlobalConstants.appBg,
      appBar: topBar,
      extendBodyBehindAppBar: true,
      body: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/book_candle.jpg'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Container(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: _techs.length,
            itemBuilder: (context, index) {
              return _makeCard(context, index);
            },
          ),
        )
      ]),
      key: _scaffoldKey,
      drawer: DrawerPage(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTapped,
        currentIndex: currentTabIndex,
        backgroundColor: GlobalConstants.appBg,
        selectedItemColor: Color(0xfffeb53b),
        selectedLabelStyle: TextStyle(fontSize: 14),
        unselectedItemColor: Colors.white,
        unselectedLabelStyle: TextStyle(fontSize: 14),
        items: [
          BottomNavigationBarItem(
            icon: Icon(RPGAwesome.anvil, color: Colors.white),
            label: 'Forge',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.import_contacts, color: Colors.white),
            label: 'Research',
          ),
        ],
      ),
    );
  }

  void _getTechResearches() async {
    final response = await _apiProvider.get('/research');

    var rscs = [];
    var blps = [];
    if (response.containsKey("success")) {
      if (response["success"] == true) {
        if (response.containsKey("techs")) {
          for (dynamic elem in response["techs"]) {
            final r = Research.fromJson(elem);
            rscs.add(r);
          }
        }
        if (response.containsKey("blueprints")) {
          for (dynamic elem in response["blueprints"]) {
            final b = Blueprint.fromJson(elem);
            blps.add(b);
          }
        }
      }
    }

    setState(() {
      _techs.clear();
      _techs.addAll(rscs.toList());
      _blueprints.clear();
      _blueprints.addAll(blps.toList());
    });
  }
}
