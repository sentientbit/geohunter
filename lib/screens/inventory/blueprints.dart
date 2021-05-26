///
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

///
import '../../models/blueprint.dart';
import '../../models/materialmodel.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';
import '../../providers/api_provider.dart';

//import '../app_localizations.dart';

///
enum PopupMenuChoice {
  ///
  all,

  ///
  weak,

  ///
  common,

  ///
  strong
}

///
class BlueprintListPage extends StatefulWidget {
  ///
  BlueprintListPage({
    Key? key,
  }) : super(key: key);

  @override
  _BlueprintListState createState() => _BlueprintListState();
}

///
class _BlueprintListState extends State<BlueprintListPage> {
  /// Secure Storage for User Data
  final _storage = FlutterSecureStorage();

  ///
  final ApiProvider _apiProvider = ApiProvider();

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ///
  final _blueprints = [];

  @override
  void initState() {
    super.initState();
    _getBlueprints();
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

  Widget _makeListTile(BuildContext context, int index) {
    var netImg = Image(
      image: AssetImage('assets/images/blueprints/${_blueprints[index].img}'),
      height: 76.0,
      width: 76.0,
    );

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
                child: Text(_blueprints[index].nr.toString(),
                    style: TextStyle(color: Colors.white))),
          ])),
      title: Text(
        _blueprints[index].name,
        style: TextStyle(
          color: GlobalConstants.appFg,
          fontFamily: "Cormorant SC",
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: <Widget>[
          Text(
            " Blp",
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
      trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {},
    );
  }

  void choiceAction(PopupMenuChoice choice) {}

  Widget build(BuildContext context) {
    //ignore: omit_local_variable_types
    int currentTabIndex = 1;

    /// What happens when clicking the Bottom Navbar
    onTapped(int index) {
      setState(() {
        currentTabIndex = index;
      });
      if (index == 0) {
        Navigator.of(context).pushReplacementNamed('/inventory');
      }
      /* else index == 1 We are here: Blueprints */
      else if (index == 2) {
        Navigator.of(context).pushReplacementNamed('/materials');
      }
    }

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
      title: Text("Blueprints", style: Style.topBar),
      actions: <Widget>[
        PopupMenuButton<PopupMenuChoice>(
          onSelected: choiceAction,
          itemBuilder: (context) => <PopupMenuEntry<PopupMenuChoice>>[
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.all,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.all_inclusive,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'All',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.weak,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.stop_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Weak',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.common,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.stop_circle_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Common',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.strong,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.star_half,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Strong',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
          color: GlobalConstants.appBg,
        ),
      ],
    );
    return Scaffold(
      backgroundColor: GlobalConstants.appBg,
      appBar: topBar,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/ruins_shadow.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _blueprints.length,
              itemBuilder: _makeCard,
            ),
          ),
        ],
      ),
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
            icon: Icon(Icons.format_list_bulleted, color: Colors.white),
            label: 'Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined, color: Colors.white),
            label: 'Blueprints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets, color: Colors.white),
            label: 'Materials',
          )
        ],
      ),
    );
  }

  void _getBlueprints() async {
    // 17 is intermediate items
    // (save a bit of bandwidth as we only need the blueprints)
    final response = await _apiProvider.get('/inventory/17');

    var tmp = [];
    if (response.containsKey("success")) {
      if (response["success"] == true) {
        if (response.containsKey("blueprints")) {
          for (dynamic elem in response["blueprints"]) {
            final itm = Blueprint.fromJson(elem);
            tmp.add(itm);
          }
        }
      }
    }
    setState(() {
      _blueprints.clear();
      _blueprints.addAll(tmp.toList());
    });
  }
}
