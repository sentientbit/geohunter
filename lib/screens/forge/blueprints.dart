import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/blueprint.dart';
import '../../providers/blueprint_list_provider.dart';
import '../../shared/app_theme.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

class BlueprintSelectPage extends ConsumerStatefulWidget {
  BlueprintSelectPage({Key? key}) : super(key: key);

  @override
  _BlueprintSelectState createState() => _BlueprintSelectState();
}

class _BlueprintSelectState extends ConsumerState<BlueprintSelectPage> {
  final _storage = FlutterSecureStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _makeCard(BuildContext context, int index, List<Blueprint> blueprints) {
    return Card(
      color: const Color.fromRGBO(19, 21, 20, 0.8),
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 33.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: _makeListTile(context, index, blueprints),
      ),
    );
  }

  Widget _makeListTile(BuildContext context, int index, List<Blueprint> blueprints) {
    final blp = blueprints[index];
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      leading: Container(
        padding: const EdgeInsets.only(right: 12.0),
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(width: 1.0, color: Color(0xff333333)),
          ),
        ),
        child: Stack(children: <Widget>[
          Image(
            image: AssetImage('assets/images/blueprints/${blp.img}'),
            height: 76.0,
            width: 76.0,
          ),
          Positioned(
            right: 0.0,
            bottom: 0.0,
            child: Text(blp.nr.toString(),
                style: const TextStyle(color: Colors.white)),
          ),
        ]),
      ),
      title: Text(
        blp.name,
        style: TextStyle(
          color: GlobalConstants.appFg,
          fontFamily: 'Cormorant SC',
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: const Text(' Blp', style: TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () => _chooseBlueprint(context, blp.id, blp.img, blp.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blueprintsAsync = ref.watch(blueprintListProvider);

    final topBar = AppBar(
      leading: IconButton(
        color: GlobalConstants.appFg,
        icon: const Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text('Select Blueprint', style: Style.topBar),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/research_study.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          blueprintsAsync.when(
            data: (blueprints) => ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: blueprints.length,
              itemBuilder: (ctx, i) => _makeCard(ctx, i, blueprints),
            ),
            loading: () => Center(child: kCompassLoader()),
            error: (e, _) => Center(
              child: Text('Error loading blueprints',
                  style: const TextStyle(color: Colors.white54)),
            ),
          ),
        ],
      ),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }

  void _chooseBlueprint(
      BuildContext context, int blpId, String blpImg, String blpName) async {
    await _storage.write(key: 'forgeBlueprintId', value: blpId.toString());
    await _storage.write(key: 'forgeBlueprintImg', value: blpImg);
    await _storage.write(key: 'forgeBlueprintName', value: blpName);
    if (mounted) Navigator.pop(context, true);
  }
}
