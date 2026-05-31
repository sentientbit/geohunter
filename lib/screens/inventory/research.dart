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
    // All threshold values come from the Research model (server is source of truth).
    final currentPoints = tech.nrInvested;
    final neededPoints = tech.nextLevelThreshold;
    final lowerPoints = tech.currentLevelFloor;
    final percentage = (neededPoints > lowerPoints)
        ? ((currentPoints - lowerPoints) / (neededPoints - lowerPoints))
            .clamp(0.0, 1.0)
        : 1.0;
    final skillLabel = Research.skill(currentPoints); // label still local until backend sends it on list
    final isLocked = tech.craftingLevel == 0 && tech.blueprint.pagesRequired > 0;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              StudyDetailPage(research: tech, blueprints: blueprints),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Tech image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ColorFiltered(
                colorFilter: isLocked
                    ? const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ])
                    : const ColorFilter.mode(
                        Colors.transparent, BlendMode.multiply),
                child: Image(
                  image: AssetImage(currentPoints > 0
                      ? 'assets/images/research/${tech.img}'
                      : 'assets/images/research/unknown.png'),
                  height: 56,
                  width: 56,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name + progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tech.name,
                          style: TextStyle(
                            color: isLocked
                                ? Colors.white38
                                : Colors.white,
                            fontFamily: 'Cormorant SC',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Mastery badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isLocked
                              ? Colors.white10
                              : const Color(0xff3a2800),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: isLocked
                                  ? Colors.white12
                                  : const Color(0xffe6a04e),
                              width: 0.5),
                        ),
                        child: Text(
                          isLocked ? 'Locked' : skillLabel,
                          style: TextStyle(
                            color: isLocked
                                ? Colors.white24
                                : const Color(0xffe6a04e),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: isLocked ? 0.0 : percentage,
                            backgroundColor:
                                Colors.white12,
                            valueColor:
                                const AlwaysStoppedAnimation(
                                    Color(0xffe6a04e)),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$currentPoints / $neededPoints',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLocked
                  ? Icons.lock_outline
                  : Icons.keyboard_arrow_right,
              color: isLocked
                  ? Colors.white24
                  : Colors.white54,
              size: 22,
            ),
          ],
        ),
      ),
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
