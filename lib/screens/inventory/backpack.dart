/// based on https://proandroiddev.com/flutter-thursday-02-beautiful-list-ui-and-detail-page-a9245f5ceaf0
import 'package:flutter/material.dart';
import '../../shared/item_image.dart';
import '../../app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

///
import '../../models/item.dart';
import '../../models/user.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/inventory/itemdetail.dart';
import '../../shared/app_theme.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

///
enum PopupMenuChoice {
  ///
  allItems,

  ///
  mainHand,

  ///
  intermediate
}

/// item_type_ids for Main Hand weapons (matches server-side type list)
const _mainHandTypes = [4, 13, 14, 16];

/// item_type_ids for Intermediate / crafting items
const _intermediateTypes = [17];

///
class InventoryPage extends ConsumerStatefulWidget {
  ///
  final String name = 'inventory';

  ///
  InventoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<InventoryPage> createState() => _InventoryState();
}

///
class _InventoryState extends ConsumerState<InventoryPage> {
  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ///
  PopupMenuChoice _selectedFilter = PopupMenuChoice.allItems;

  /// Returns the currently visible items based on the selected filter.
  /// Filtering is done client-side from the full inventory already in memory.
  List<Item> _applyFilter(List<Item> all) {
    if (_selectedFilter == PopupMenuChoice.mainHand) {
      return all.where((i) => _mainHandTypes.contains(i.itemTypeId)).toList();
    }
    if (_selectedFilter == PopupMenuChoice.intermediate) {
      return all.where((i) => _intermediateTypes.contains(i.itemTypeId)).toList();
    }
    return all; // allItems — no filter
  }

  Widget _makeListTile(BuildContext context, Item item) {
    final netImg = Image(
      image: itemImageProvider(item.img),
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
                child: Text(item.nr.toString(),
                    style: TextStyle(color: Colors.white))),
            // Gold lock badge — top-right corner, visible when item is locked
            if (item.locked)
              const Positioned(
                right: 0.0,
                top: 0.0,
                child: Icon(Icons.lock,
                    size: 16, color: Color(0xffe6a04e)),
              ),
          ])),
      title: Text(
        item.name,
        style: TextStyle(
          color: Item.color(item.rarity),
          fontFamily: "Cormorant SC",
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: <Widget>[
          for (var i = 0; i < item.rarity; i++)
            Icon(Icons.star_border, color: Colors.white),
          Flexible(
            child: Text(" Level ${item.level}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailPage(item: item),
          ),
        );
      },
    );
  }

  Widget _makeCard(BuildContext context, Item item) {
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
        child: _makeListTile(context, item),
      ),
    );
  }

  void choiceAction(PopupMenuChoice choice) {
    setState(() {
      _selectedFilter = choice;
    });
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

  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryProvider);
    final user = ref.watch(userProvider).valueOrNull ?? User.blank();

    final allItems = inventoryState.valueOrNull?.items ?? [];
    final displayedItems = _applyFilter(allItems);

    //ignore: omit_local_variable_types
    int currentTabIndex = 0;

    /// What happens when clicking the Bottom Navbar
    onTapped(int index) {
      setState(() {
        currentTabIndex = index;
      });
      /* if index == 0 We are here: Items */
      if (index == 1) {
        context.replace('/blueprints');
      } else if (index == 2) {
        context.replace('/materials');
      }
    }

    Widget body;
    if (inventoryState.isLoading) {
      body = Center(child: kCompassLoader());
    } else if (inventoryState.hasError) {
      body = Center(
        child: Text(
          inventoryState.error.toString(),
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      body = ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: displayedItems.length,
        itemBuilder: (ctx, i) => _makeCard(ctx, displayedItems[i]),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.pop();
      },
      child: Scaffold(
        backgroundColor: GlobalConstants.appBg,
        appBar: AppBar(
          leading: leadingIcon(context, user.details),
          elevation: 0.1,
          backgroundColor: Colors.transparent,
          title: Text(
            AppLocalizations.of(context)!.translate('drawer_inventory'),
            style: Style.topBar,
          ),
          actions: <Widget>[
            PopupMenuButton<PopupMenuChoice>(
              iconColor: Colors.white,
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
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/tools.jpg'),
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
            ),
          ],
        ),
      ),
    );
  }
}
