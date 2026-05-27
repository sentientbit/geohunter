///
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
///
import '../../models/app_error.dart';
import '../../models/blueprint.dart';
import '../../providers/api_provider.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

//import '../app_localizations.dart';

///
class BlueprintSelectPage extends StatefulWidget {
  ///
  BlueprintSelectPage({Key? key}) : super(key: key);

  @override
  _BlueprintSelectState createState() => _BlueprintSelectState();
}

///
class _BlueprintSelectState extends State<BlueprintSelectPage> {
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
      onTap: () {
        _chooseBlueprint(context, _blueprints[index].id, _blueprints[index].img,
            _blueprints[index].name);
      },
    );
  }

  Widget build(BuildContext context) {
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
      title: Text("Select Blueprint", style: Style.topBar),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        )
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

  /// Wear the item and get back
  void _chooseBlueprint(
      BuildContext context, int blpId, String blpImg, String blpName) async {
    await _storage.write(key: 'forgeBlueprintId', value: blpId.toString());
    await _storage.write(key: 'forgeBlueprintImg', value: blpImg);
    await _storage.write(key: 'forgeBlueprintName', value: blpName);
    if (mounted) Navigator.pop(context, true);
  }
}
