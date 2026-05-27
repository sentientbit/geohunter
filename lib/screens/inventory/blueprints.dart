///
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
///
import '../../models/app_error.dart';
import '../../models/blueprint.dart';
import '../../providers/api_provider.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

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
  ///
  final ApiProvider _apiProvider = ApiProvider();

  ///
  final _storage = FlutterSecureStorage();

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ///
  final _blueprints = [];

  @override
  void initState() {
    super.initState();
    _getBlueprints();
  }

  @override
  void dispose() {
    super.dispose();
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
      onTap: () => _openBlueprint(context, _blueprints[index]),
    );
  }

  void choiceAction(PopupMenuChoice choice) {}

  void _openBlueprint(BuildContext context, Blueprint blp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GlobalConstants.appBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage('assets/images/blueprints/${blp.img}'),
              height: 120,
              width: 120,
            ),
            SizedBox(height: 12),
            Text(
              blp.name,
              style: TextStyle(
                color: GlobalConstants.appFg,
                fontSize: 22,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'You have ${blp.nr}',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 24),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                backgroundColor: GlobalConstants.appBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(width: 1, color: Colors.white),
              ),
              onPressed: () => _goForge(context, blp),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.construction, color: Color(0xffe6a04e)),
                  SizedBox(width: 8),
                  Text(
                    'Go to Forge',
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
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _goForge(BuildContext context, Blueprint blp) async {
    await _storage.write(key: 'forgeBlueprintId', value: blp.id.toString());
    await _storage.write(key: 'forgeBlueprintImg', value: blp.img);
    await _storage.write(key: 'forgeBlueprintName', value: blp.name);
    if (!mounted) return;
    Navigator.of(context).pop(); // close bottom sheet
    context.go('/forge');
  }

  Widget build(BuildContext context) {
    //ignore: omit_local_variable_types
    int currentTabIndex = 1;

    /// What happens when clicking the Bottom Navbar
    onTapped(int index) {
      setState(() {
        currentTabIndex = index;
      });
      if (index == 0) {
        context.go('/inventory');
      }
      /* else index == 1 We are here: Blueprints */
      else if (index == 2) {
        context.go('/materials');
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
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/poi-map');
      },
      child: Scaffold(
        backgroundColor: GlobalConstants.appBg,
        appBar: topBar,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/research_study.jpg'),
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
      ),
    );
  }

  void _getBlueprints() async {
    // 17 is intermediate items
    // (save a bit of bandwidth as we only need the blueprints)
    try {
      final response = await _apiProvider.post('/inventory', {"types": [17]});

      var tmp = [];
      if (response.containsKey("blueprints")) {
        for (dynamic elem in response["blueprints"]) {
          final itm = Blueprint.fromJson(elem);
          tmp.add(itm);
        }
      }
      setState(() {
        _blueprints.clear();
        _blueprints.addAll(tmp.toList());
      });
    } on AppError catch (err) {
      debugPrint(err.toString());
    } catch (err) {
      debugPrint('_getBlueprints unexpected error: $err');
    }
  }
}
