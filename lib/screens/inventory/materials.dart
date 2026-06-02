///
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:logger/logger.dart';

///
import '../../models/app_error.dart';
import '../../models/materialmodel.dart';
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
class MaterialListPage extends StatefulWidget {
  ///
  MaterialListPage({
    Key? key,
  }) : super(key: key);

  @override
  _MaterialListState createState() => _MaterialListState();
}

///
class _MaterialListState extends State<MaterialListPage> {
  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));


  ///
  final ApiProvider _apiProvider = ApiProvider();

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ///
  final _materials = [];

  @override
  void initState() {
    super.initState();
    _getMaterials("0");
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
      image: AssetImage('assets/images/materials/${_materials[index].img}'),
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
        child: Stack(
          children: <Widget>[
            netImg,
            Positioned(
              right: 0.0,
              bottom: 0.0,
              child: Text(
                _materials[index].nr.toString(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      title: Text(
        _materials[index].name,
        style: TextStyle(
          color: GlobalConstants.appFg,
          fontFamily: "Cormorant SC",
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: <Widget>[
          Text(
            " Level ${_materials[index].level}",
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
      trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {},
    );
  }

  void choiceAction(PopupMenuChoice choice) {
    if (choice == PopupMenuChoice.all) {
      _getMaterials("0");
    } else if (choice == PopupMenuChoice.weak) {
      _getMaterials("1");
    } else if (choice == PopupMenuChoice.common) {
      _getMaterials("2");
    } else if (choice == PopupMenuChoice.strong) {
      _getMaterials("3");
    }
  }

  Widget build(BuildContext context) {
    //ignore: omit_local_variable_types
    int currentTabIndex = 2;

    /// What happens when clicking the Bottom Navbar
    onTapped(int index) {
      setState(() {
        currentTabIndex = index;
      });
      if (index == 0) {
        context.replace('/inventory');
      } else if (index == 1) {
        context.replace('/blueprints');
      }
      /* else index == 2 We are here: Materials */
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
      title: Text("Materials", style: Style.topBar),
      actions: <Widget>[
        PopupMenuButton<PopupMenuChoice>(
          iconColor: Colors.white,
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
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ],
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.pop();
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
                  image: AssetImage('assets/images/ruins_shadow.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _materials.length,
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

  void _getMaterials(String types) async {
    try {
    final response = await _apiProvider.get('/materials/$types');

    var tmp = [];
    if (response.containsKey("materials")) {
      for (dynamic elem in response["materials"]) {
        final mat = Materialmodel.fromJson(elem);
        if (mat.nr > 0) {
          tmp.add(mat);
        }
      }
    }
    setState(() {
      _materials.clear();
      _materials.addAll(tmp.toList());
    });
    } on AppError catch (err) {
      debugPrint(err.toString());
    } catch (err) {
      debugPrint('_getMaterials unexpected error: $err');
    }
  }
}
