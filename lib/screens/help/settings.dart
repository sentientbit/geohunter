///
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

//import 'package:logger/logger.dart';

///
import '../../app_localizations.dart';
import '../../models/app_error.dart';
import '../../models/player_stats.dart';
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../shared/app_theme.dart';
import '../../shared/equipment_loader.dart';
import '../../providers/custom_interceptors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/journal_provider.dart';
import '../../providers/user_provider.dart';
import '../../shared/constants.dart';
import '../../shared/sfx.dart';
import '../../text_style.dart';
import '../../widgets/drawer.dart';

///
class SettingsPage extends ConsumerStatefulWidget {
  ///
  final String name = "settings";

  ///
  SettingsPage({
    Key? key,
  }) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

///
class _SettingsState extends ConsumerState<SettingsPage> {
  ///
  math.Random rndBattleNumber = math.Random.secure();

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  final ApiProvider _apiProvider = ApiProvider();

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Curent loggedin user
  User _user = User.blank();

  // Sounds + vibrate are DEVICE-LOCAL settings: the backend only persists
  // music and notification levels (its responses hardcode the rest to 0),
  // so these two come from secure storage, never from the server.
  bool _soundsEnabled = false;

  bool _vibrateEnabled = false;

  int notificationLevel = 0;

  int musicLevel = 0;

  // Account language ('en'/'ro'). Persisted server-side via PUT /profile — the
  // same mechanism the Profile page uses (the API DOES support this, so it is
  // not internal-only). Drives server-rendered content (the Keeper's Journal,
  // item/material names) and, via main.dart, the app's own UI locale.
  String _language = 'en';

  static const _localStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _soundsEnabled = Sfx.enabled;
    _loadVibrate();
    _getUserDetails();
  }

  void _loadVibrate() async {
    final v = await _localStorage.read(key: 'vibrate_enabled');
    if (mounted) setState(() => _vibrateEnabled = v == '1');
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    /// Application top Bar
    final topBar = AppBar(
      leading: IconButton(
        color: GlobalConstants.appFg,
        icon: const Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text(
        AppLocalizations.of(context)!.translate('drawer_settings'),
        style: Style.topBar,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ],
    );

    final saveButton = kStoneButton(
      onTap: _updateSettings,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.done, color: Color(0xffe6a04e)),
          Text(
            " ${AppLocalizations.of(context)!.translate('save')}",
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

    return Scaffold(
      backgroundColor: GlobalConstants.appBg,
      resizeToAvoidBottomInset: false,
      appBar: topBar,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/closet.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(top: 90.0),
            child: Column(
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
                          SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: SwitchListTile(
                                  activeTrackColor: Colors.white,
                                  activeThumbColor: Color(0xffe6a04e),
                                  title: const Text(
                                    'Notifications',
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
                                  value: (notificationLevel > 0),
                                  onChanged: (toggle) {
                                    setState(() {
                                      notificationLevel = (!toggle) ? 0 : 100;
                                    });
                                  },
                                  secondary: Icon(
                                    (notificationLevel > 0)
                                        ? Icons.notifications_none
                                        : Icons.notifications_off_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(),
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: SwitchListTile(
                                  activeTrackColor: Colors.white,
                                  activeThumbColor: Color(0xffe6a04e),
                                  title: const Text(
                                    'Sounds',
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
                                  value: _soundsEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _soundsEnabled = value;
                                    });
                                  },
                                  secondary: const Icon(Icons.volume_down,
                                      color: Colors.white),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(),
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: SwitchListTile(
                                  activeTrackColor: Colors.white,
                                  activeThumbColor: Color(0xffe6a04e),
                                  title: const Text(
                                    'Music',
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
                                  value: (musicLevel > 0),
                                  onChanged: (toggle) {
                                    setState(() {
                                      musicLevel = (!toggle) ? 0 : 100;
                                    });
                                  },
                                  secondary: Icon(
                                    (musicLevel > 0)
                                        ? Icons.music_note
                                        : Icons.music_off,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(),
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: SwitchListTile(
                                  activeTrackColor: Colors.white,
                                  activeThumbColor: Color(0xffe6a04e),
                                  title: const Text(
                                    'Vibrate',
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
                                  value: _vibrateEnabled,
                                  onChanged: (toggle) {
                                    setState(() {
                                      _vibrateEnabled = toggle;
                                    });
                                  },
                                  secondary: const Icon(Icons.vibration,
                                      color: Colors.white),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(),
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.language,
                                      color: Colors.white),
                                  title: const Text(
                                    'Language',
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
                                  trailing: DropdownButton<String>(
                                    dropdownColor: GlobalConstants.appBg,
                                    value: _language,
                                    underline: const SizedBox.shrink(),
                                    style: const TextStyle(
                                        color: Color(0xffe6a04e), fontSize: 16),
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Color(0xffe6a04e)),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'en', child: Text('English')),
                                      DropdownMenuItem(
                                          value: 'ro', child: Text('Română')),
                                      DropdownMenuItem(
                                          value: 'fr', child: Text('Français')),
                                    ],
                                    onChanged: (v) =>
                                        setState(() => _language = v ?? 'en'),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(),
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                          // kStoneButton is full-width; never put it bare in a
                          // Row — unbounded width breaks layout in release.
                          saveButton,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }

  void _updateSettings() async {
    // Capture before mutating _user so we only hit /profile when it changed.
    final languageChanged = _language != _user.details.language;

    _user.details.language = _language;
    _user.details.settings = PlayerSettings(
      music: musicLevel,
      notifications: notificationLevel,
      sounds: _soundsEnabled ? 100 : 0,
      vibrate: _vibrateEnabled ? 1 : 0,
    );

    CustomInterceptors.setStoredCookies(
        GlobalConstants.apiHostUrl, _user.toMap());

    // Sounds + vibrate persist locally (the backend ignores them).
    await Sfx.setEnabled(_soundsEnabled);
    await _localStorage.write(
        key: 'vibrate_enabled', value: _vibrateEnabled ? '1' : '0');

    try {
      await ApiProvider().put('/settings', {
        "music": _user.details.settings.music,
        "notification": _user.details.settings.notifications,
      });
    } on AppError catch (err) {
      if (!mounted) return;
      err.show(context);
    } catch (err) {
      debugPrint('_updateSettings unexpected error: $err');
    }

    // Account language lives on the profile. Send the full profile field set
    // (same shape the Profile page uses) so we don't blank the other fields.
    if (languageChanged) {
      try {
        await ApiProvider().put('/profile', {
          "username": _user.details.username,
          "sex": _user.details.sex,
          "location_privacy": _user.details.locationPrivacy,
          "language": _language,
          "status": _user.details.status,
        });
      } on AppError catch (err) {
        if (!mounted) return;
        err.show(context);
      } catch (err) {
        debugPrint('_updateSettings language update error: $err');
      }
    }

    if (!mounted) return;
    ref.invalidate(userProvider);
    // Server-rendered content (Journal pages, item names) is language-keyed,
    // so force the Journal to refetch in the new language.
    if (languageChanged) ref.invalidate(journalProvider);
    context.pop();
  }

  ///
  void _getUserDetails() async {
    _user = await ApiProvider().getStoredUser();

    dynamic response;
    try {
      response = await _apiProvider.get('/equipment');
    } on AppError catch (err) {
      if (!mounted) return;
      err.show(context);
      return;
    } catch (err) {
      debugPrint('_getUserDetails unexpected error: $err');
      return;
    }

    // Apply common fields via shared loader.
    // Note: applyEquipmentResponse writes settings only when the server sends
    // them. The else-branch below handles the missing-settings fallback.
    applyEquipmentResponse(_user, response as Map<String, dynamic>);

    // Settings-specific fallback: if the server didn't send a settings key,
    // rebuild the settings object from the current local slider values so we
    // don't lose any in-progress slider state the user set before saving.
    if (!(response as Map).containsKey('settings')) {
      _user.details.settings = PlayerSettings(
        music: musicLevel,
        notifications: notificationLevel,
        sounds: _soundsEnabled ? 100 : 0,
        vibrate: _vibrateEnabled ? 1 : 0,
      );
    }

    if (!mounted) return;
    ref.invalidate(userProvider);

    setState(() {
      musicLevel = _user.details.settings.music;
      notificationLevel = _user.details.settings.notifications;
      _language = (_user.details.language == 'ro') ? 'ro' : 'en';
      // _soundsEnabled / _vibrateEnabled are device-local — the server
      // hardcodes them to 0 in its settings array, so never read them here.
    });
  }
}
