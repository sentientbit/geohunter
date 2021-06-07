///
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';

///
import '../../models/item.dart';
import '../../providers/api_provider.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

///
class EquipmentPage extends StatefulWidget {
  ///
  final int placement;

  ///
  final Item item;

  ///
  EquipmentPage({
    Key? key,
    required this.placement,
    required this.item,
  }) : super(key: key);

  @override
  _EquipmentState createState() => _EquipmentState();
}

///
class _EquipmentState extends State<EquipmentPage> {
  ///
  final ApiProvider _apiProvider = ApiProvider();

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ///
  final _items = [];

  List<String> _itemTypes = [
    "1",
    "2",
    "3",
    "4.13.14.16",
    "5",
    "6.15",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12"
  ];

  @override
  void initState() {
    super.initState();
    _getInventoryItems(_itemTypes[widget.placement]);
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
          Text(
            " Level ${_items[index].level}",
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
      trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {
        _wearItem(context, _items[index].id);
      },
    );
  }

  Widget build(BuildContext context) {
    /// Application top Bar
    final topBar = AppBar(
      brightness: Brightness.dark,
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
      title: Text("Select", style: Style.topBar),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );

    final unequipButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: () {
        _unequipItem(context, widget.placement);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.cached, color: Color(0xffe6a04e)),
          Text(
            " Unequip",
            style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
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
            child: Column(
              children: <Widget>[
                (_items.length > 0)
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: _items.length,
                        itemBuilder: _makeCard,
                      )
                    : Container(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 90),
                            Center(
                              child: Text(
                                "No suitable items found",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  shadows: <Shadow>[
                                    Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0))
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(child: unequipButton),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
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

  /// Wear the item and get back
  void _wearItem(BuildContext context, int itemId) async {
    final response = await _apiProvider.post('/equipment/$itemId', {});
    if (response.containsKey("success")) {
      if (response["success"] == true) {
        _items.clear();
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.of(context).pushNamed('/profile');
      }
    }
  }

  void _unequipItem(BuildContext context, int placement) async {
    // Our index start with 0 sa we add 1
    var slot = placement + 1;
    final response = await _apiProvider.delete('/equipment/$slot', {});
    //print(response['message']);
    if (response.containsKey("success")) {
      if (response["success"] == true) {
        _items.clear();
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.of(context).pushNamed('/profile');
      }
    }
  }
}
