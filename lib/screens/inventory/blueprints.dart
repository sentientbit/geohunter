///
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
///
import '../../models/blueprint.dart';
import '../../providers/blueprint_list_provider.dart';
import '../../shared/app_theme.dart';
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
class BlueprintListPage extends ConsumerStatefulWidget {
  ///
  BlueprintListPage({
    Key? key,
  }) : super(key: key);

  @override
  _BlueprintListState createState() => _BlueprintListState();
}

///
class _BlueprintListState extends ConsumerState<BlueprintListPage> {
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
        child: _makeListTile(context, blueprints[index]),
      ),
    );
  }

  Widget _makeListTile(BuildContext context, Blueprint blp) {
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
      subtitle: const Row(
        children: <Widget>[
          Text(' Blp', style: TextStyle(color: Colors.white)),
        ],
      ),
      trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () => _openBlueprint(context, blp),
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
            kStoneButton(
              onTap: () => _goForge(context, blp),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.construction, color: kGold),
                  SizedBox(width: 8),
                  Text(
                    'Go to Forge',
                    style: TextStyle(
                      color: kGold,
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
    context.replace('/forge');
  }

  @override
  Widget build(BuildContext context) {
    final blueprintsAsync = ref.watch(blueprintListProvider);
    int currentTabIndex = 1;

    /// What happens when clicking the Bottom Navbar
    onTapped(int index) {
      setState(() {
        currentTabIndex = index;
      });
      if (index == 0) {
        context.replace('/inventory');
      }
      /* else index == 1 We are here: Blueprints */
      else if (index == 2) {
        context.replace('/materials');
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
            error: (e, _) => const Center(
              child: Text('Error loading blueprints',
                  style: TextStyle(color: Colors.white54)),
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

}
