///
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///
import '../../models/guild_list_response.dart';
import '../../models/user.dart';
import '../../providers/guild_provider.dart';
import '../../providers/user_provider.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';
import 'create_group.dart';
import 'join_group.dart';

///
class NoGroup extends ConsumerStatefulWidget {
  @override
  _NoGroupState createState() => _NoGroupState();
}

class _NoGroupState extends ConsumerState<NoGroup> {
  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ///
  final int maxNrGuilds = 100;

  Widget _makeCard(BuildContext context, GuildSummary guild) {
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
        child: _makeListTile(context, guild),
      ),
    );
  }

  Widget _makeListTile(BuildContext context, GuildSummary guild) {
    var netImg = Image(
      image: AssetImage('assets/images/guild-ornament.jpg'),
      height: 76.0,
      width: 76.0,
    );

    var nrUsers = guild.nrUsers.toString();
    var locked = (guild.isLocked > 0) ? "Password locked" : "Open";

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
        child: Stack(
          children: <Widget>[
            netImg,
            Positioned(
              right: 0.0,
              bottom: 0.0,
              child: Text('123'),
            ),
          ],
        ),
      ),
      title: Text(
        guild.name,
        style: TextStyle(
          color: Color(0xffe6a04e),
          fontFamily: "Cormorant SC",
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10.0),
          Text(
            "Nr. users: $nrUsers",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10.0),
          Text(
            locked,
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
      trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JoinGroup(
              guid: guild.guid,
              isLocked: guild.isLocked,
              title: guild.name,
            ),
          ),
        );
      },
    );
  }

  Widget leadingIcon(BuildContext context, UserData userDetails) {
    if (!GlobalConstants.menuHasNotification(userDetails)) {
      return IconButton(
        color: Colors.white,
        icon: Icon(Icons.menu, color: Colors.white),
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
              Icon(Icons.menu, color: Colors.white),
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
    final guildListState = ref.watch(guildListProvider);
    final user = ref.watch(userProvider).valueOrNull ?? User.blank();

    final guilds = guildListState.valueOrNull?.guilds ?? [];
    final userGuildId = user.details.guildId;

    ///
    void _goJoin(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinGroup(
            guid: "",
            isLocked: 0,
            title: "",
          ),
        ),
      );
    }

    ///
    void _goCreate(BuildContext context) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateGroup()));
    }

    final myguildButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: () {
        context.go('/in-group');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.redo, color: Color(0xffe6a04e)),
          Text(
            " My guild",
            style: TextStyle(
              color: Color(0xffe6a04e),
              fontSize: 18,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    final createButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: () => _goCreate(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.add, color: Color(0xffe6a04e)),
          Text(
            " Create new",
            style: TextStyle(
              color: Color(0xffe6a04e),
              fontSize: 18,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    final joinButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: GlobalConstants.appBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 1, color: Colors.white),
      ),
      onPressed: () => _goJoin(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.redo, color: Color(0xffe6a04e)),
          Text(
            " Join private",
            style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    /// Application top Bar
    final topBar = AppBar(
      leading: leadingIcon(context, user.details),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text("Guilds", style: Style.topBar),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/poi-map');
      },
      child: Scaffold(
        backgroundColor: GlobalConstants.appBg,
        resizeToAvoidBottomInset: false,
        appBar: topBar,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/inn.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(40.0)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Welcome to Guilds",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold,
                      fontSize: 40.0,
                      color: Colors.white,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Guilds are special groups of players "
                    "bounded by a common goal.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, left: 0),
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        (userGuildId != "0") ? myguildButton : createButton,
                        (userGuildId != "0") ? Text("") : joinButton,
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: guildListState.isLoading
                      ? Center(
                          child: Image.asset('assets/images/compass.gif',
                              width: 150),
                        )
                      : CustomScrollView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: false,
                          slivers: <Widget>[
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'List of Public Guilds',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Color(0xffe6a04e),
                                        fontSize: 24,
                                        fontFamily: 'Cormorant SC',
                                        fontWeight: FontWeight.bold,
                                        shadows: <Shadow>[
                                          Shadow(
                                            offset: Offset(1.0, 1.0),
                                            blurRadius: 3.0,
                                            color:
                                                Color.fromARGB(255, 0, 0, 0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  for (final guild
                                      in guilds.take(maxNrGuilds))
                                    _makeCard(context, guild),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
        key: _scaffoldKey,
        drawer: DrawerPage(),
      ),
    );
  }
}
