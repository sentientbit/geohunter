/// based on https://medium.com/@afegbua/this-is-the-second-part-of-the-beautiful-list-ui-and-detail-page-article-ecb43e203915
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geohunter/fonts/rpg_awesome_icons.dart';
//import 'package:logger/logger.dart';

///
import '../../app_localizations.dart';
import '../../models/item.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';
import '../../providers/api_provider.dart';

///
class ItemDetailPage extends StatefulWidget {
  ///
  final Item item;

  ///
  ItemDetailPage({Key key, this.item}) : super(key: key);

  @override
  _ItemDetailState createState() => _ItemDetailState();
}

///
class _ItemDetailState extends State<ItemDetailPage> {
  double _nrDisItems = 0;
  String _btnDisText = "0";
  String _description = "";
  String _blueprintImg = "";
  String _blueprintName = "";
  final _misc = [];

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  final ApiProvider _apiProvider = ApiProvider();

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getItemDetails(widget.item.id);
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

  Widget build(BuildContext context) {
    //print(widget.item.img);

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
            ? _scaffoldKey.currentState.openDrawer()
            : Navigator.of(context).pop(),
      ),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text("Inventory", style: Style.topBar),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );

    final coursePrice = Container(
      padding: const EdgeInsets.all(7.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(5.0)),
      child: Text(
        "${widget.item.nr.toString()} pcs",
        style: TextStyle(color: GlobalConstants.appFg, fontSize: 18.0),
      ),
    );

    final topContentText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Image(
          //image: NetworkImage('https://${GlobalConstants.apiHostUrl}/img/items/${widget.item.img}'),
          image: AssetImage('assets/images/items/${widget.item.img}'),
          height: 180.0,
          width: 180.0,
        ),
        Text(
          widget.item.name ?? "Item",
          style: TextStyle(
            color: Item.color(widget.item.rarity),
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
              flex: 6,
              child: Container(
                child: Row(
                  children: <Widget>[
                    for (var i = 0; i < widget.item.rarity; i++)
                      Icon(Icons.star_border, color: Colors.white),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        " Level ${widget.item.level}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(flex: 2, child: coursePrice)
          ],
        ),
      ],
    );

    final topContent = Stack(
      children: <Widget>[
        Container(
          height: halfScreenSize,
          padding: EdgeInsets.only(top: 0.0, left: 40.0, right: 40.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Color(0xcc222222)),
          child: Center(
            child: topContentText,
          ),
        ),
      ],
    );

    final disassembleButton = Padding(
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
        onPressed: () => _deleteItem(context, widget.item.id),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(RPGAwesome.recycle, color: Color(0xffe6a04e)),
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
                SizedBox(height: 18),
                Text(
                  _description ?? "N/A",
                  style:
                      TextStyle(color: GlobalConstants.appFg, fontSize: 18.0),
                ),
                for (var misc in _misc)
                  Text(
                    misc ?? "",
                    style:
                        TextStyle(color: GlobalConstants.appFg, fontSize: 18.0),
                  ),
                SizedBox(height: 18),
                Text(
                  'Crafting',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Color(0xffe6a04e),
                      fontSize: 24,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold),
                ),
                if (_blueprintImg != "")
                  Image.asset(
                    "assets/images/blueprints/$_blueprintImg",
                    height: 180.0,
                    width: 180.0,
                  ),
                Text(
                  _blueprintName ?? "Blueprint",
                  style:
                      TextStyle(color: GlobalConstants.appFg, fontSize: 18.0),
                ),
                SizedBox(height: 18),
                Text(
                  'Disassemble',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Color(0xffe6a04e),
                      fontSize: 24,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 18),
                Text(
                  "Disassemble this item to get materials and blueprints."
                  "After that, with enough skill you can forge a better one.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 18),
                Row(
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
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 12.0),
                          overlayColor: Colors.red.withAlpha(32),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 28.0),
                        ),
                        child: Slider(
                          min: 0,
                          max: widget.item.nr * 1.0,
                          value: _nrDisItems,
                          divisions: widget.item.nr.round(),
                          onChanged: (value) {
                            setState(() {
                              _nrDisItems = value;
                              _btnDisText = _nrDisItems.toInt().toString();
                            });
                          },
                        ),
                      ),
                    ),
                    disassembleButton,
                  ],
                ),
                SizedBox(height: 18),
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
              image: AssetImage('assets/images/friend_campfire.jpg'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(top: 90.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: <Widget>[topContent, bottomContent],
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

  void _deleteItem(context, itemId) async {
    var nrItems = _nrDisItems.toInt();

    if (nrItems <= 0) {
      return;
    }

    dynamic response;
    try {
      response = await _apiProvider.delete("/inventory/$itemId/$nrItems", {});
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description: err?.response?.data['message'],
          buttonText: "Okay",
        ),
      );
      return;
    }

    //ignore: omit_local_variable_types
    List<Image> imagesArr = [];

    if (response["materials"].isNotEmpty) {
      for (dynamic value in response["materials"]) {
        if (value.containsKey("img") && value["img"] != "") {
          imagesArr.add(Image.asset("assets/images/materials/${value['img']}"));
        }
      }
    }

    if (response["blueprints"].isNotEmpty) {
      for (dynamic value in response["blueprints"]) {
        if (value.containsKey("img") && value["img"] != "" && value["id"] > 0) {
          imagesArr
              .add(Image.asset("assets/images/blueprints/${value['img']}"));
        }
      }
    }

    if (response["success"] == true) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: AppLocalizations.of(context).translate('congrats'),
          description: response["message"],
          buttonText: "Okay",
          images: imagesArr,
          callback: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/inventory');
          },
        ),
      );
    }
  }

  void _getItemDetails(int itemId) async {
    if (itemId <= 0) {
      return;
    }
    final response = await _apiProvider.get('/itemdetails/$itemId');

    //var props = [];
    if (response.containsKey("success")) {
      if (response["success"] == true) {
        // for (var elem in response["misc"]) {
        //   //TODO
        //   iterable misc_html
        //   props.add(elem);
        // }
        // log.d(props);
        setState(() {
          _misc.clear();
          //_misc.addAll(props);
          _description = response["description"]["en"];
          _blueprintName = response["blueprint"]["name"];
          _blueprintImg = response["blueprint"]["img"];
        });
      }
    }
  }
}
