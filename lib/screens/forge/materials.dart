///
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

///
import '../../models/materialmodel.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';
import '../../providers/api_provider.dart';

//import '../app_localizations.dart';

///
class MaterialSelectPage extends StatefulWidget {
  ///
  int blueprintId = 0;

  ///
  int placement = 0;

  ///
  int mat0 = 0;

  ///
  MaterialSelectPage({
    Key? key,
    required this.blueprintId,
    required this.placement,
    required this.mat0,
  }) : super(key: key);

  @override
  _MaterialSelectState createState() => _MaterialSelectState();
}

///
class _MaterialSelectState extends State<MaterialSelectPage> {
  /// Secure Storage for User Data
  final _storage = FlutterSecureStorage();

  ///
  final ApiProvider _apiProvider = ApiProvider();

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ///
  final _materials = [];

  @override
  void initState() {
    super.initState();
    _getMaterials();
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
          child: Stack(children: <Widget>[
            netImg,
            Positioned(
                right: 0.0,
                bottom: 0.0,
                child: Text(_materials[index].nr.toString(),
                    style: TextStyle(color: Colors.white))),
          ])),
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
            " Material",
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
      trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {
        _chooseMaterial(context, _materials[index].id, _materials[index].img,
            _materials[index].name);
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
        onPressed: () => _scaffoldKey != null
            ? _scaffoldKey.currentState?.openDrawer()
            : Navigator.of(context).pop(),
      ),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text("Select Materials", style: Style.topBar),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.pop(context);
          },
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
    );
  }

  void _getMaterials() async {
    final response = await _apiProvider
        .get('/forge/${widget.blueprintId}/${widget.mat0.toString()}');

    var tmp = [];
    if (response.containsKey("success")) {
      if (response["success"] == true) {
        if (response.containsKey("materials")) {
          for (dynamic elem in response["materials"]) {
            final mat = Materialmodel.fromJson(elem);
            if (mat.nr > 0) {
              tmp.add(mat);
            }
          }
        }
      }
    }
    setState(() {
      _materials.clear();
      _materials.addAll(tmp.toList());
    });
  }

  /// Wear the item and get back
  void _chooseMaterial(
      BuildContext context, int matId, String matImg, String matName) async {
    await _storage.write(
      key: "forgeMaterial${widget.placement.toString()}Id",
      value: matId.toString(),
    );
    await _storage.write(
      key: "forgeMaterial${widget.placement.toString()}Img",
      value: matImg,
    );
    await _storage.write(
      key: "forgeMaterial${widget.placement.toString()}Name",
      value: matName,
    );

    setState(() {
      _materials.clear();
    });
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.of(context).pushNamed('/forge');
  }
}
