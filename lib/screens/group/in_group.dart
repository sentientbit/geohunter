import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:go_router/go_router.dart';
import 'package:geohunter/models/friends.dart';

//import 'package:logger/logger.dart';

///
import '../../app_localizations.dart';
import '../../models/app_error.dart';
import '../../models/guild.dart';
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../providers/guild_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../screens/friendship/paldetail.dart';
import '../../screens/group/no_group.dart';
import '../../shared/constants.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';
import '../../widgets/network_status_message.dart';

///
class InGroup extends ConsumerStatefulWidget {
  ///
  final String name = 'in-group';
  @override
  _InGroupState createState() => _InGroupState();
}

class _InGroupState extends ConsumerState<InGroup> {
  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _guildNameController = TextEditingController();
  String _guildNameControllerMessage = '';
  bool _showGuildNameError = false;

  /// if the Guild is public or not
  int _isHidden = 0;
  void _isHiddenChanged(bool toggle) {
    if (!toggle) {
      setState(() {
        _isHidden = 0;
      });
      return;
    }
    setState(() {
      _isHidden = 1;
    });
    return;
  }

  /// if the Guild is public or not
  int _isLocked = 0;
  void _isLockedChanged(bool toggle) {
    if (!toggle) {
      setState(() {
        _isLocked = 0;
      });
      return;
    }
    setState(() {
      _isLocked = 1;
    });
    return;
  }

  final _passwordController = TextEditingController();
  String _passwordControllerMessage = '';
  bool _showPasswordError = false;

  /// If the user is this guild's Leader
  bool _isGroupOwner = false;

  final ApiProvider _apiProvider = ApiProvider();

  /// Current guild (kept for mutation methods that need guild.id)
  Guild _currentGuild = Guild.blank();

  /// Guards one-time form initialization from provider data
  bool _initialized = false;

  //final Logger log = Logger(
  //    printer: PrettyPrinter(
  //        colors: true, printEmojis: true, printTime: true, lineLength: 80));

  @override
  void initState() {
    super.initState();
  }

  void _initFormFromGuild(Guild guild, User user) {
    _guildNameController.text = guild.name;
    _isHidden = guild.isHidden;
    _isLocked = guild.isLocked;
    _passwordController.text = "";
    _isGroupOwner = (guild.leaderId == user.details.id);
    _currentGuild = guild;
    _initialized = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _makeCard(BuildContext context, GuildUser member) {
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
        child: _makeListTile(context, member),
      ),
    );
  }

  Widget _makeListTile(BuildContext context, GuildUser member) {
    var netImg = Image(
      image: NetworkImage(
          'https://${GlobalConstants.apiHostUrl}${member.thumbnail}'),
      height: 76.0,
      width: 76.0,
    );

    var seniority = timeAgoSinceDate(member.created);
    var friend = Friend.fromGuildUser(member);

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
        member.username,
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
            "${member.role()}",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10.0),
          Text(
            "Seniority: $seniority",
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
      trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PalDetailPage(friend: friend),
          ),
        );
      },
    );
  }

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
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 10,
                      height: 10,
                    ),
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final guildAsync = ref.watch(guildProvider);
    final user = ref.watch(userProvider).valueOrNull ?? User.blank();

    final guild = guildAsync.valueOrNull?.guild ?? Guild.blank();
    final members = guild.users;
    final guildUid = (guild.guid != "0" && guild.guid.isNotEmpty) ? guild.guid : "Unique ID";

    // One-time form initialization when guild data first loads
    if (guildAsync.hasValue && !_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_initialized) setState(() => _initFormFromGuild(guild, user));
      });
    }

    // Button to save and update the guild's details
    final saveButton = Padding(
      padding: EdgeInsets.all(0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(16),
          backgroundColor: GlobalConstants.appBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(width: 1, color: Colors.white),
        ),
        onPressed: _saveGuildDetails,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.check, color: Color(0xffe6a04e)),
            Text(
              'Save',
              style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    // Button to delete the guild and all members associated with it
    final deleteButton = Padding(
      padding: EdgeInsets.all(0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(16),
          backgroundColor: GlobalConstants.appBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(width: 1, color: Colors.white),
        ),
        onPressed: () {
          _confirmDelete(_scaffoldKey.currentContext);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.delete_outline, color: Color(0xffe6a04e)),
            Text(
              "Delete",
              style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    final leaveButton = Padding(
      padding: EdgeInsets.all(0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(16),
          backgroundColor: GlobalConstants.appBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(width: 1, color: Colors.white),
        ),
        onPressed: () {
          _confirmLeave(_scaffoldKey.currentContext!);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.undo, color: Color(0xffe6a04e)),
            Text(
              "Leave Guild",
              style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    final browseButton = Padding(
      padding: EdgeInsets.all(0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(16),
          backgroundColor: GlobalConstants.appBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(width: 1, color: Colors.white),
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NoGroup()));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.list, color: Color(0xffe6a04e)),
            Text(
              "Browse",
              style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    /// Application top Bar
    final topBar = AppBar(
      leading: leadingIcon(context, user.details),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text("Guild - $guildUid",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Cormorant SC",
            fontWeight: FontWeight.bold,
          )),
      actions: [
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
        resizeToAvoidBottomInset: false,
        appBar: topBar,
        body: OfflineBuilder(
        connectivityBuilder: (
          context,
          connectivity,
          child,
        ) {
          if (connectivity.isEmpty || connectivity.contains(ConnectivityResult.none)) {
            return Stack(children: <Widget>[
              child,
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                    color: Colors.black.withValues(alpha: 0),
                    // child: child,
                    child: NetworkStatusMessage()),
              )
            ]);
          } else {
            return child;
          }
        },
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/friends.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    // reverse: true,
                    child: Padding(
                      padding:
                          EdgeInsets.only(bottom: bottom, left: 25, right: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 18.0),
                          Text(
                            'Guild name',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.bold,
                                shadows: <Shadow>[
                                  Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0))
                                ]),
                          ),
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: TextField(
                                    enabled: _isGroupOwner,
                                    controller: _guildNameController,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Guild Name"),
                                    onSubmitted: (text) {},
                                  ),
                                )
                              ],
                            ),
                          ),
                          if (_showGuildNameError)
                            _showGuildNameError
                                ? Text(
                                    _guildNameControllerMessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontFamily: 'Open Sans',
                                        fontWeight: FontWeight.bold,
                                        shadows: <Shadow>[
                                          Shadow(
                                              offset: Offset(1.0, 1.0),
                                              blurRadius: 3.0,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0))
                                        ]),
                                  )
                                : Text(''),
                          SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Text(
                                'Visibility',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.bold,
                                    shadows: <Shadow>[
                                      Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(255, 0, 0, 0))
                                    ]),
                              ),
                              _isGroupOwner
                                  ? Switch(
                                      value: (_isHidden > 0),
                                      onChanged: _isHiddenChanged,
                                      activeTrackColor: Colors.white,
                                      activeThumbColor: Color(0xffe6a04e),
                                    )
                                  : Row(
                                      children: <Widget>[
                                        Text("  "),
                                        (_isHidden > 0)
                                            ? Icon(Icons.visibility_off,
                                                color: Colors.white)
                                            : Icon(Icons.visibility,
                                                color: Colors.white),
                                        Text("  ")
                                      ],
                                    ),
                              Text(
                                (_isHidden > 0) ? 'Hidden' : 'Public',
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Open Sans',
                                  fontWeight: FontWeight.bold,
                                  shadows: <Shadow>[
                                    Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0))
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Text(
                                'Security',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.bold,
                                    shadows: <Shadow>[
                                      Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(255, 0, 0, 0))
                                    ]),
                              ),
                              _isGroupOwner
                                  ? Switch(
                                      value: (_isLocked > 0),
                                      onChanged: _isLockedChanged,
                                      activeTrackColor: Colors.white,
                                      activeThumbColor: Color(0xffe6a04e),
                                    )
                                  : Row(
                                      children: <Widget>[
                                        Text("  "),
                                        (_isLocked > 0)
                                            ? Icon(Icons.lock_outline,
                                                color: Colors.white)
                                            : Icon(Icons.lock_open,
                                                color: Colors.white),
                                        Text("  ")
                                      ],
                                    ),
                              Text(
                                (_isLocked > 0) ? 'Locked' : 'Open',
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Open Sans',
                                  fontWeight: FontWeight.bold,
                                  shadows: <Shadow>[
                                    Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0))
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if ((_isLocked > 0) && _isGroupOwner)
                            Text(
                              AppLocalizations.of(context)!
                                  .translate('password_input_label'),
                              semanticsLabel: 'Password',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Open Sans',
                                  fontWeight: FontWeight.bold,
                                  shadows: <Shadow>[
                                    Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0))
                                  ]),
                            ),
                          if ((_isLocked > 0) && _isGroupOwner)
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Pass"),
                                      onSubmitted: (text) {},
                                    ),
                                  )
                                ],
                              ),
                            ),
                          if ((_isLocked > 0) && _isGroupOwner)
                            _showPasswordError
                                ? Text(
                                    _passwordControllerMessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontFamily: 'Open Sans',
                                        fontWeight: FontWeight.bold,
                                        shadows: <Shadow>[
                                          Shadow(
                                              offset: Offset(1.0, 1.0),
                                              blurRadius: 3.0,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0))
                                        ]),
                                  )
                                : Text(''),
                          SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              browseButton,
                              _isGroupOwner ? saveButton : leaveButton,
                              if (_isGroupOwner)
                                Center(
                                  child: deleteButton,
                                )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Members',
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
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          for (final member in members)
                            _makeCard(context, member),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
        key: _scaffoldKey,
        drawer: DrawerPage(),
      ),
    );
  }

  void _saveGuildDetails() async {
    _showGuildNameError = false;
    if (_guildNameController.text.isEmpty) {
      setState(() {
        _guildNameControllerMessage = 'Please choose a guild name';
        _showGuildNameError = true;
      });
      return;
    }
    _showPasswordError = false;
    if ((_isLocked > 0) && _passwordController.text.isEmpty) {
      setState(() {
        _passwordControllerMessage = 'Please enter a password';
        _showPasswordError = true;
      });
      return;
    }
    try {
      var data = {
        "guild_id": _currentGuild.id,
        "name": _guildNameController.text,
        "is_hidden": _isHidden,
        "is_locked": _isLocked,
      };
      if ((_isLocked > 0) && _passwordController.text != "") {
        data["password"] = _passwordController.text;
      }
      final response = await _apiProvider.put("/guild", data);

      // if (_image != null) {
      //   try {
      //     await _apiProvider.uploadPicture('/emblem', 'emblemfile', 'guild_id',
      //         _image, int.parse(addGuild["guild_id"].toString()));
      //   } on DioException catch (err) {
      //     log.e(err.response);
      //   }
      // }

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: AppLocalizations.of(context)!.translate('congrats'),
          description: response["message"],
          buttonText: "Okay",
          images: [],
          callback: () {},
        ),
      );
      // _images.clear();
    } on AppError catch (err) {
      err.show(context);
    } catch (err) {
      debugPrint('_saveGuildDetails unexpected error: $err');
    }
  }

  void _confirmDelete(BuildContext? context) {
    showDialog<void>(
      context: context!,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Please confirm",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Cormorant SC',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this Guild?",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Open Sans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.9),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: GlobalConstants.appBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                side: BorderSide(width: 1, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.close, color: Color(0xffe6a04e)),
                  Text(
                    " No",
                    style: TextStyle(
                        color: Color(0xffe6a04e),
                        fontSize: 18,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: GlobalConstants.appBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                side: BorderSide(width: 1, color: Colors.white),
              ),
              onPressed: () {
                _deleteGuild(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.done, color: Color(0xffe6a04e)),
                  Text(
                    " Yes",
                    style: TextStyle(
                        color: Color(0xffe6a04e),
                        fontSize: 18,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmLeave(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Please confirm",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Cormorant SC',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to leave this Guild?",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Open Sans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.9),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: GlobalConstants.appBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                side: BorderSide(width: 1, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.close, color: Color(0xffe6a04e)),
                  Text(
                    " No",
                    style: TextStyle(
                        color: Color(0xffe6a04e),
                        fontSize: 18,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: GlobalConstants.appBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                side: BorderSide(width: 1, color: Colors.white),
              ),
              onPressed: () {
                _unjoinGuild(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.done, color: Color(0xffe6a04e)),
                  Text(
                    " Yes",
                    style: TextStyle(
                        color: Color(0xffe6a04e),
                        fontSize: 18,
                        fontFamily: 'Cormorant SC',
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteGuild(BuildContext context) async {
    try {
      final response =
          await _apiProvider.delete("/guild/${_currentGuild.id}", {});

      if (response["success"] == true) {
        ref.invalidate(guildProvider);
        ref.invalidate(userProvider);
      }

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: AppLocalizations.of(context)!.translate('congrats'),
          description: response["message"],
          buttonText: "Okay",
          images: [],
          callback: () {
            Navigator.of(context).pop();
            context.go('/no-group');
          },
        ),
      );
    } on AppError catch (err) {
      err.show(context);
    } catch (err) {
      debugPrint('_deleteGuild unexpected error: $err');
    }
  }

  void _unjoinGuild(BuildContext context) async {
    try {
      final userId = ref.read(userProvider).valueOrNull?.details.id ?? 0;
      final response = await _apiProvider
          .delete("/membership/${_currentGuild.id}/$userId", {});

      ref.invalidate(guildProvider);
      ref.invalidate(userProvider);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: AppLocalizations.of(context)!.translate('congrats'),
          description: response["message"]?.toString() ?? "Done",
          buttonText: "Okay",
          images: [],
          callback: () {
            Navigator.of(context).pop();
            context.go('/no-group');
          },
        ),
      );
    } on AppError catch (err) {
      err.show(context);
    } catch (err) {
      debugPrint('_unjoinGuild unexpected error: $err');
    }
  }
}
