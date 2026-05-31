import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../fonts/rpg_awesome_icons.dart';
import '../../models/blueprint_page.dart';
import '../../models/user.dart';
import '../../providers/blueprint_pages_provider.dart';
import '../../providers/user_provider.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

///
class PagesPage extends ConsumerStatefulWidget {
  const PagesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PagesPage> createState() => _PagesState();
}

class _PagesState extends ConsumerState<PagesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _makeListTile(BlueprintPage page) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      leading: Container(
        padding: const EdgeInsets.only(right: 12.0),
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(width: 1.0, color: Color(0xff333333)),
          ),
        ),
        child: Stack(children: [
          Image(
            image: AssetImage('assets/images/blueprints/${page.img}'),
            height: 76.0,
            width: 76.0,
            errorBuilder: (_, __, ___) => Icon(RPGAwesome.scroll_unfurled,
                size: 76, color: Colors.white54),
          ),
          Positioned(
            right: 0.0,
            bottom: 0.0,
            child: Text(
              page.quantity.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ]),
      ),
      title: Text(
        page.name,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Cormorant SC',
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        'Assembles into a blueprint volume',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right,
          color: Colors.white, size: 30.0),
    );
  }

  Widget _makeCard(BlueprintPage page) {
    return Card(
      color: const Color.fromRGBO(19, 21, 20, 0.8),
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 33.0,
                offset: Offset(0.0, 10.0)),
          ],
        ),
        child: _makeListTile(page),
      ),
    );
  }

  Widget leadingIcon(UserData userDetails) {
    if (!GlobalConstants.menuHasNotification(userDetails)) {
      return IconButton(
        color: Colors.white,
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      );
    }
    return InkWell(
      splashColor: Colors.lightBlue,
      onTap: () => _scaffoldKey.currentState?.openDrawer(),
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(left: 10),
          width: 40,
          height: 25,
          child: Stack(children: [
            const Icon(Icons.menu, color: Colors.white),
            Positioned(
              left: 25,
              top: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagesState = ref.watch(blueprintPagesProvider);
    final user = ref.watch(userProvider).valueOrNull ?? User.blank();

    final pages = pagesState.valueOrNull ?? [];

    Widget body;
    if (pagesState.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (pagesState.hasError) {
      body = Center(
        child: Text(pagesState.error.toString(),
            style: const TextStyle(color: Colors.white)),
      );
    } else if (pages.isEmpty) {
      body = const Center(
        child: Text(
          'No blueprint pages yet.\nVisit Library mines to collect pages.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    } else {
      body = ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: pages.length,
        itemBuilder: (ctx, i) => _makeCard(pages[i]),
      );
    }

    onTapped(int index) {
      if (index == 0) context.go('/inventory');
      if (index == 1) context.go('/blueprints');
      if (index == 2) context.go('/materials');
      /* index == 3: we are here — Pages */
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/poi-map');
      },
      child: Scaffold(
        backgroundColor: GlobalConstants.appBg,
        appBar: AppBar(
          leading: leadingIcon(user.details),
          elevation: 0.1,
          backgroundColor: Colors.transparent,
          title: Text('Blueprint Pages', style: Style.topBar),
        ),
        extendBodyBehindAppBar: true,
        body: Stack(children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/book_candle.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          body,
        ]),
        key: _scaffoldKey,
        drawer: DrawerPage(),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTapped,
          currentIndex: 3,
          backgroundColor: GlobalConstants.appBg,
          selectedItemColor: const Color(0xfffeb53b),
          selectedLabelStyle: const TextStyle(fontSize: 14),
          unselectedItemColor: Colors.white,
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          items: const [
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
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined, color: Colors.white),
              label: 'Pages',
            ),
          ],
        ),
      ),
    );
  }
}
