/// based on https://medium.com/@afegbua/this-is-the-second-part-of-the-beautiful-list-ui-and-detail-page-article-ecb43e203915
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///
import '../../fonts/rpg_awesome_icons.dart';
import '../../models/blueprint.dart';
import '../../models/research.dart';
import '../../models/user.dart';
import '../../providers/research_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/inventory/study.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

///
class ResearchPage extends ConsumerStatefulWidget {
  /// Widget name
  final String name = "research";

  @override
  _ResearchState createState() => _ResearchState();
}

///
class _ResearchState extends ConsumerState<ResearchPage> {
  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _makeListTile(
      BuildContext context, Research tech, List<Blueprint> blueprints) {
    var netImg = (tech.nrInvested > 0)
        ? Image(
            image: AssetImage('assets/images/research/${tech.img}'),
            height: 76.0,
            width: 76.0,
          )
        : Image(
            image: AssetImage('assets/images/research/unknown.png'),
            height: 76.0,
            width: 76.0,
          );

    var currentPoints = tech.nrInvested;
    var currentLvl = researchToCrafting(currentPoints);
    // Points needed to reach next level
    var neededPoints = craftingToResearch(currentLvl + 1);
    // Points needed to be at the current level (used as zero indicator)
    var lowerPoints = craftingToResearch(currentLvl);
    var percentage = (currentPoints - lowerPoints) / neededPoints;

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
              child: Text(
                tech.nrInvested.toString(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ])),
      title: Text(
        tech.name,
        style: TextStyle(
          color: Colors.white,
          fontFamily: "Cormorant SC",
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              child: LinearProgressIndicator(
                backgroundColor: Color.fromRGBO(209, 224, 224, 0.2),
                value: percentage,
                valueColor: AlwaysStoppedAnimation(Color(0xfffeb53b)),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                Research.skill(tech.nrInvested),
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudyDetailPage(
              research: tech,
              blueprints: blueprints,
            ),
          ),
        );
      },
    );
  }

  Widget _makeCard(
      BuildContext context, Research tech, List<Blueprint> blueprints) {
    return Card(
      color: Color.fromRGBO(19, 21, 20, 0.8),
      elevation: 8.0,
      margin: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 6.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 33.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: _makeListTile(context, tech, blueprints),
      ),
    );
  }

  ///
  Widget leadingIcon(BuildContext context, UserData userDetails) {
    if (!GlobalConstants.menuHasNotification(userDetails)) {
      return IconButton(
        color: Colors.white,
        icon: Icon(
          Icons.menu,
          color: Colors.white,
        ),
        onPressed: () {
          if (_scaffoldKey.currentState != null) {
            _scaffoldKey.currentState?.openDrawer();
          } else {
            Navigator.of(context).pop();
          }
        },
      );
    }

    return InkWell(
      splashColor: Colors.lightBlue,
      onTap: () {
        if (_scaffoldKey.currentState != null) {
          _scaffoldKey.currentState?.openDrawer();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Center(
        child: Container(
          margin: EdgeInsets.only(left: 10),
          width: 40,
          height: 25,
          child: Stack(
            children: [
              Icon(
                Icons.menu,
                color: Colors.white,
              ),
              Positioned(
                left: 25,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  ///
  Widget build(BuildContext context) {
    final researchState = ref.watch(researchProvider);
    final user = ref.watch(userProvider).valueOrNull ?? User.blank();

    final techs = researchState.valueOrNull?.techs ?? [];
    final blueprints = researchState.valueOrNull?.blueprints ?? <Blueprint>[];

    int currentTabIndex = 1;

    /// Application top Bar
    final topBar = AppBar(
      leading: leadingIcon(context, user.details),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text(
        "Research",
        style: Style.topBar,
      ),
    );

    /// What happens when clicking the Bottom Navbar
    onTapped(int index) {
      setState(() {
        currentTabIndex = index;
      });
      if (index == 0) {
        context.go('/forge');
      }
      /* if index == 1 We are here: Research */
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/poi-map');
      },
      child: Scaffold(
        backgroundColor: GlobalConstants.appBg,
        appBar: topBar,
        extendBodyBehindAppBar: true,
        body: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/book_candle.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          researchState.isLoading
              ? Center(
                  child: Image.asset('assets/images/compass.gif', width: 150),
                )
              : researchState.hasError
                  ? Center(
                      child: Text('Failed to load research',
                          style: TextStyle(color: Colors.white)),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: techs.length,
                      itemBuilder: (context, index) =>
                          _makeCard(context, techs[index], blueprints),
                    ),
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
              icon: Icon(RPGAwesome.forging, color: Colors.white),
              label: 'Forge',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.import_contacts, color: Colors.white),
              label: 'Research',
            ),
          ],
        ),
      ),
    );
  }
}
