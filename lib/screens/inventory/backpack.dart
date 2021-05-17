/// based on https://proandroiddev.com/flutter-thursday-02-beautiful-list-ui-and-detail-page-a9245f5ceaf0
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';

///
import '../../models/item.dart';
import '../../models/user.dart';
import '../../screens/inventory/itemdetail.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';
import '../../providers/api_provider.dart';

//import '../app_localizations.dart';

///
enum PopupMenuChoice {
  ///
  allItems,

  ///
  mainHand,

  ///
  intermediate
}

///
class InventoryPage extends StatefulWidget {
  ///
  final String name = 'inventory';

  ///
  final Item item;

  ///
  InventoryPage({Key key, this.item}) : super(key: key);

  @override
  _InventoryState createState() => _InventoryState();
}

///
class _InventoryState extends State<InventoryPage> {
  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  final ApiProvider _apiProvider = ApiProvider();

  /// Make sure back button is pressed twice
  bool ifPop = false;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Curent loggedin user
  User _user;

  ///
  final _items = [];

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    _getInventoryItems("0");
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
    var netImg = Image(
      //image: NetworkImage('https://${GlobalConstants.apiHostUrl}/img/items/${_items[index].img}'),
      image: AssetImage('assets/images/items/${_items[index].img}'),
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
                child: Text(_items[index].nr.toString(),
                    style: TextStyle(color: Colors.white))),
          ])),
      title: Text(
        _items[index].name,
        style: TextStyle(
          color: Item.color(_items[index].rarity),
          fontFamily: "Cormorant SC",
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: <Widget>[
          for (var i = 0; i < _items[index].rarity; i++)
            Icon(Icons.star_border, color: Colors.white),
          Text(" Level ${_items[index].level}",
              style: TextStyle(color: Colors.white))
        ],
      ),
      trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailPage(item: _items[index]),
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

  void choiceAction(PopupMenuChoice choice) {
    if (choice == PopupMenuChoice.allItems) {
      _getInventoryItems("0");
    } else if (choice == PopupMenuChoice.mainHand) {
      _getInventoryItems("4.13.14.16");
    } else if (choice == PopupMenuChoice.intermediate) {
      _getInventoryItems("17");
    }
  }

  Widget build(BuildContext context) {
    //ignore: omit_local_variable_types
    int currentTabIndex = 0;

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
        "Inventory",
        style: Style.topBar,
      ),
      actions: <Widget>[
        PopupMenuButton<PopupMenuChoice>(
          onSelected: choiceAction,
          itemBuilder: (context) => <PopupMenuEntry<PopupMenuChoice>>[
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.allItems,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.business_center,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'All Items',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.mainHand,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.flash_on,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Main hand',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.intermediate,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.category,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Intermediate',
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

    /// What happens when clicking the Bottom Navbar
    onTapped(int index) {
      setState(() {
        currentTabIndex = index;
      });
      /* if index == 0 We are here: Items */
      if (index == 1) {
        Navigator.of(context).pushReplacementNamed('/blueprints');
      } else if (index == 2) {
        Navigator.of(context).pushReplacementNamed('/materials');
      }
    }

    return Scaffold(
      backgroundColor: GlobalConstants.appBg,
      appBar: topBar,
      extendBodyBehindAppBar: true,
      body: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/backpack.jpg'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Container(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: _items.length,
            itemBuilder: _makeCard,
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

  void _getUserDetails() async {
    final user = await _apiProvider.getStoredUser();
    setState(() {
      _user = user;
    });
  }

  void _getInventoryItems(String types) async {
    final response = await _apiProvider.get('/inventory/$types');

    var tmp = [];
    if (response.containsKey("success")) {
      if (response["success"] == true) {
        if (response.containsKey("items")) {
          for (dynamic elem in response["items"]) {
            final itm = Item.fromJson(elem);
            tmp.add(itm);
          }
        }
      }
    }
    setState(() {
      _items.clear();
      _items.addAll(tmp.toList());
    });
  }
}
