///
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flame_audio/bgm.dart';
import 'package:flutter/material.dart';
import 'package:geohunter/fonts/rpg_awesome_icons.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:user_location/user_location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

//import 'package:logger/logger.dart';

///
import '../../app_localizations.dart';
import '../../models/app_error.dart';
import '../../models/location.dart';
import '../../shared/app_theme.dart';
import '../../models/mine.dart';
import '../../models/user.dart';
import '../../models/visitevent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/api_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/mine_repository.dart';
import '../../providers/radar_repository.dart';
import '../../providers/user_provider.dart';
import '../../providers/visit_provider.dart';
import '../../utils/mine_result_helper.dart';
import '../battle/rock_paper_scissors.dart';
import '../../shared/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';

final _debouncer = Debouncer(milliseconds: 500);

///
class PoiMap extends ConsumerStatefulWidget {
  /// Widget name
  final String name = "poi-map";

  ///
  final bool goToRemoteLocation;

  ///
  final double latitude;

  ///
  final double longitude;

  ///
  PoiMap({
    Key? key,
    required this.goToRemoteLocation,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _PoiMapState createState() => _PoiMapState();
}

class _PoiMapState extends ConsumerState<PoiMap>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  MapController mapController = MapController();

  /// user_location
  //UserLocationOptions userLocationOptions;
  List<Marker> markers = [];
  //MapboxMapController mapController;
  //GoogleMapController mapController;
  //BitmapDescriptor myIcon;

  //CameraPosition _position;
  //MyLocationTrackingMode _myLocationTrackingMode = MyLocationTrackingMode.None;
  //bool _isMoving = false;
  //final CameraTargetBounds _cameraTargetBounds = CameraTargetBounds.unbounded;

  LtLn _userLocation = LtLn(51.5, 0);

  double _mapZoom = 14.0;
  LatLng _displayWindowCenter = LatLng(51.5, 0.0);

  /// final _storage = FlutterSecureStorage();
  /// await _storage.write(key: 'key', value: 'value');
  /// var secureStorage = await _storage.readAll();
  final List<PinLocation> _pinsToBeAdded = [];

  /// 0 = day (light tiles)   1 = night (dark tiles)
  /// Initialised from system brightness in initState.
  int _mapStyleState = 0;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _textFieldController = TextEditingController();

  // Mutable copies of widget params (widget fields are final/immutable)
  late bool _goToRemoteLocation;
  late double _remoteLat;
  late double _remoteLng;

  ///
  bool _isOnline = true;
  bool _commentIsEmpty = false;
  bool _infoWindowVisible = false;
  bool _recenterBtnPressed = false;
  bool _showRecenterBtn = false;

  Timer? timer;
  Color _customAppBarTextColor = Colors.black;
  Color _customAppBarIconColor = Colors.black;
  Brightness _systemHeaderBrightness = Brightness.light;
  final _pois = [];
  final _players = [];

  final _apiProvider = ApiProvider();
  //int _screenRebuilded = 1;
  final List<File> _images = [];
  final List<String> _thumbnails = [];

  /// Background music player — owned here so it survives for the entire
  /// session (SplashScreen is disposed on navigation, so it can't own it).
  final Bgm _musicBg = Bgm();

  Mine _mine = Mine.blank();
  int _mineIdx = -1;
  int _mineId = 0;
  String _mineUid = "";

  /// Curent loggedin user
  User _user = User.blank();

  String mapType = "outdoors";

  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Future _loadPois(LtLn location) async {
    // print("--- log. Loading pois ---");
    if (location.latitude == 51.5 && location.longitude == 0) {
      return;
    }

    var d = 39136000 *
        math.cos(location.longitude * oneRad) /
        math.pow(2, _mapZoom);
    if (d > 10000000) {
      d = 10000000;
      /* cap to 10km */
    }

    final neLat = _displayWindowCenter.latitude +
        ((d / terraRadius) * (180.0 / math.pi)); /* max lat */
    final swLat = _displayWindowCenter.latitude -
        ((d / terraRadius) * (180.0 / math.pi)); /* min lat */

    final neLng = _displayWindowCenter.longitude +
        radianToDeg(math.asin(d / terraRadius) /
            math.cos(
                degToRadian(_displayWindowCenter.latitude))); /* max lng */
    final swLng = _displayWindowCenter.longitude -
        radianToDeg(math.asin(d / terraRadius) /
            math.cos(
                degToRadian(_displayWindowCenter.latitude))); /* min lng */
    // await _storage.write(key: 'swLng', value: swLng.toString());
    // await _storage.write(key: 'swLat', value: swLat.toString());
    // await _storage.write(key: 'neLng', value: neLng.toString());
    // await _storage.write(key: 'neLat', value: neLat.toString());
    // await _storage.write(key: 'mapZoom', value: _mapZoom.toString());

    final features = [];
    final players = [];
    if (_isOnline) {
      try {
        final result = await ref.read(radarRepositoryProvider).getRadar(
          userLocation: _userLocation,
          zoom: _mapZoom,
          swLat: swLat,
          swLng: swLng,
          neLat: neLat,
          neLng: neLng,
        );
        features.addAll(result.pois);
        players.addAll(result.players);
      } on AppError catch (err) {
        if (err.isNetworkError) return;
        if (err.isUnauthorized) {
          context.go('/login');
          return;
        }
        return;
      } catch (err) {
        debugPrint('_loadPois unexpected error: $err');
        return;
      }

      var _locationMarker = Marker(
          height: 60.0,
          width: 60.0,
          point: LatLng(_userLocation.latitude, _userLocation.longitude),
          child: Builder(builder: (BuildContext context) {
            return Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x8864b5f6),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }));

      markers.clear();
      markers.add(_locationMarker);

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      setState(() {
        _pois.clear();
        _pois.addAll(features.toList());
        _players.clear();
        _players.addAll(players.toList());
      });
    }
  }

  final _markerIcons = [];

  // What happens when the user clicks on a location tag
  void _onClickMarker(int idx, Mine selectedMine) {
    if (selectedMine.category != 1) {
      selectPlayer();
      return;
    }

    // First select Point
    selectPoint(
      idx,
      selectedMine.id,
      LtLn(
        selectedMine.geometry.coordinates[1],
        selectedMine.geometry.coordinates[0],
      ),
      selectedMine.properties.comment,
    );

    _mine = selectedMine;
    _mineIdx = idx;

    // Then complete details
    setState(() {
      _textFieldController.text = selectedMine.properties.comment;
      _mineUid = selectedMine.properties.uid;
    });

    // Fetch full mine details (including player photos) from the API.
    // The radar response is a bulk sweep and does not include pictures.
    _fetchMineDetails(selectedMine.id);
  }

  /// Fetches landmark pictures for [mineId] from GET /landmark/{mineId}
  /// and updates [_thumbnails] with any player-uploaded photos.
  void _fetchMineDetails(int mineId) async {
    try {
      final response = await _apiProvider.get('/landmark/$mineId');
      final pics = (response['pictures'] as List?) ?? [];
      if (!mounted) return;
      setState(() {
        _thumbnails.clear();
        for (final pic in pics) {
          final thumb = pic['thumbnail'] as String?;
          if (thumb != null && thumb.isNotEmpty) _thumbnails.add(thumb);
        }
      });
    } catch (e) {
      debugPrint('_fetchMineDetails error: $e');
    }
  }

  // // Infowindow generator
  // InfoWindow _generatorInfoMarker(int idx, Properties mineProps,
  //     int mineCategory, double meters, Geometry mineGeometry) {
  //   //print('_generatorInfoMarker');
  //   //print(idx);
  //   if (mineCategory == 1) {
  //     //log.d(mineProps.toJson());

  //     return InfoWindow(
  //       title: mineProps.comment /*mine.properties.title*/,
  //       snippet: "Distance: ${distanceInMeters(meters)}",
  //     );
  //   } else if (mineCategory == 2) {
  //     return InfoWindow(
  //         title: mineProps.title, snippet: " ${mineProps.comment}");
  //   }
  //   return null;
  // }

  ///
  bool isInPoisList(int i) {
    if (i < 0) {
      return false;
    }

    List tmp = _pois.asMap().keys.toList();
    var isInList = false;
    for (dynamic elem in tmp) {
      if (elem == i) {
        isInList = true;
      }
    }

    return isInList;
  }

  // Future<void> _createMarkerImageFromAsset(BuildContext context, ico) async {
  //   // if (_markerIcons.isNotEmpty && _markerIcons[ico] == null) {
  //   final imageConfiguration = createLocalImageConfiguration(context);
  //   final bitmap = await BitmapDescriptor.fromAssetImage(
  //       imageConfiguration, "assets/images/markers/$ico.png");
  //   setState(() {
  //     _markerIcons.add(bitmap);
  //   });
  //   // }
  // }

  // GPS and battle-outcome streams are now Riverpod providers.
  // Subscriptions are set up via ref.listen() in build().

  @override
  void didChangeDependencies() {
    if (_markerIcons.length == 0) {
      _loadBitmapDescriptor();
      //} else { // log.d("No need for update");
    }

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    _musicBg.initialize();

    // Set initial theme from phone system brightness (dark mode → night tiles).
    _mapStyleState =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? 1
            : 0;

    _goToRemoteLocation = widget.goToRemoteLocation;
    _remoteLat = widget.latitude;
    _remoteLng = widget.longitude;

    // GPS + visit-event streams are wired via ref.listen() in build().

    timer = Timer.periodic(
      Duration(minutes: 30),
      (t) => dayAndNight(_userLocation),
    );

    dayAndNight(_userLocation);

    // Refresh user profile whenever the app returns to the foreground.
    // This clears the daily-reward badge if the player claimed on the web
    // portal while the app was backgrounded.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(userProvider);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    _pois.clear();
    _musicBg.dispose();
    //if (mapController != null) { mapController.removeListener(_onMapChanged); }
    super.dispose();
  }

  /// Apply music on/off based on user settings.
  /// Safe to call repeatedly — guards against double-play and double-stop.
  void _applyMusicSetting(User user) {
    if (user.details.settings.isMusicOn) {
      if (!_musicBg.isPlaying) {
        _musicBg.play('audio/music/aWayThrough.mp3');
      }
    } else {
      if (_musicBg.isPlaying) {
        _musicBg.stop();
      }
    }
  }

  // Upload all the pins from when you were offline
  void changeOnlineStatus() {
    if (_isOnline && _pinsToBeAdded.length > 0) {
      for (var pin in _pinsToBeAdded) {
        _modifyPin(pin);
      }
      _pinsToBeAdded.clear();
    }
  }

  // When clicking on a map or called from a mine
  void selectPoint(int idx, int id, LtLn ltln, String comment) {
    //print('selectPoint $idx');
    setState(() {
      _mineId = id;
      _images.clear();
      _thumbnails.clear();
      _textFieldController.text = comment;
      _commentIsEmpty = false;
    });
  }

  void selectPlayer() {
    setState(() {
      _mineId = 0;
      _mineUid = _user.details.id;
      _images.clear();
      _thumbnails.clear();
    });
  }

  // Applies the current map style (day/night) to the app bar and tiles.
  // Style follows system brightness at startup and the manual toggle after;
  // it is NOT driven by sun position.
  void dayAndNight(LtLn location) async {
    if (_mapStyleState == 1 /* night */) {
      setState(() {
        _customAppBarTextColor = Colors.white;
        _customAppBarIconColor = Colors.white;
        _systemHeaderBrightness = Brightness.dark;
        mapType = 'dark';
      });
    } else /* day (0) or any unknown state — default to light */ {
      setState(() {
        _customAppBarTextColor = Colors.black;
        _customAppBarIconColor = Colors.black;
        _systemHeaderBrightness = Brightness.light;
        mapType = 'outdoors';
      });
    }
  }

  /// Human-readable name for a POI type icon value.
  String _mineTypeName(String ico) {
    switch (ico) {
      case GlobalConstants.pointMine:    return 'Mine';
      case GlobalConstants.pointWood:    return 'Wood';
      case GlobalConstants.pointBattle:  return 'Battle';
      case GlobalConstants.pointBoy:     return 'Campfire';
      case GlobalConstants.pointGirl:    return 'Campfire';
      case GlobalConstants.pointRuins:   return 'Ruins';
      case GlobalConstants.pointLibrary: return 'Library';
      case GlobalConstants.pointTrader:      return 'Trader';
      case GlobalConstants.pointBattleground: return 'Battleground';
      default:                               return 'Point';
    }
  }

  /// Format a decimal degree value to DMS string, e.g. 45°37'34.3"N
  String _toDMS(double decimal, bool isLat) {
    final abs = decimal.abs();
    final deg = abs.toInt();
    final minFull = (abs - deg) * 60;
    final min = minFull.toInt();
    final sec = (minFull - min) * 60;
    final dir = isLat
        ? (decimal >= 0 ? 'N' : 'S')
        : (decimal >= 0 ? 'E' : 'W');
    return "$deg°${min.toString().padLeft(2, '0')}'${sec.toStringAsFixed(1)}\"$dir";
  }

  Widget popupTitle() {
    final pending = '.' * _pinsToBeAdded.length;

    if (_mineId > 0 && _mineIdx >= 0 && _mineIdx < _pois.length) {
      final typeName = _mineTypeName(_pois[_mineIdx].properties.ico);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            typeName,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Cormorant SC',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Point $_mineId',
            style: TextStyle(
              color: kSilverDim,
              fontFamily: 'Open Sans',
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ],
      );
    }

    // New point — show user's current GPS coords
    final lat = _toDMS(_userLocation.latitude, true);
    final lng = _toDMS(_userLocation.longitude, false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$lat  $lng',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Open Sans',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'New Point$pending',
          style: TextStyle(
            color: kSilverDim,
            fontFamily: 'Open Sans',
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget mapButton(String tag, Function func, IconData icon) {
    return FloatingActionButton(
      heroTag: tag,
      onPressed: () {
        func();
      },
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.black,
      child: Icon(
        icon,
        size: 36.0,
        color: Colors.white,
      ),
    );
  }

  _onMapTypeButtonPressed() {
    setState(() {
      _mapStyleState = _mapStyleState == 0 ? 1 : 0; // toggle day ↔ night
      dayAndNight(_userLocation);
    });
  }

  /// Returns the correct tile URL for the current map style.
  /// dark/night → CartoDB Dark Matter; terrain → OpenTopoMap; otherwise OSM.
  String get _effectiveTileUrl {
    if (mapType == 'outdoors') {
      return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    } else if (mapType == 'dark') {
      return 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
    } else if (mapType == 'terrain') {
      return 'https://a.tile.opentopomap.org/{z}/{x}/{y}.png';
    }
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  _onAddPinButtonPressed() {
    // Set the creator to be the current player
    if (_mineId > 0) {
      //print('original creator');
      _mineUid = _mine.properties.uid;
    } else {
      //print('current player');
      _mineUid = _user.details.id;
    }
    setState(() {
      _infoWindowVisible = true;
    });
  }

  LatLng _centerOfMap() {
    if (_goToRemoteLocation == true) {
      _showRecenterBtn = true;
      // Sync _displayWindowCenter and _mapZoom to the remote location BEFORE
      // calling _loadPois — the bounding-box math inside _loadPois uses
      // _displayWindowCenter, so if it still points at the GPS position the
      // radar request fires with the wrong viewport and returns no POIs.
      _displayWindowCenter = LatLng(_remoteLat, _remoteLng);
      _mapZoom = 16;
      _loadPois(LtLn(_remoteLat, _remoteLng));
      _goToRemoteLocation = false;
      // initialCenter races against the GPS listener in flutter_map 8.x —
      // belt-and-suspenders: also move via controller after first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          mapController.move(LatLng(_remoteLat, _remoteLng), 16);
        }
      });
      return LatLng(_remoteLat, _remoteLng);
    }

    return LatLng(_userLocation.latitude, _userLocation.longitude);
  }

  ///
  Future _goMine(int idx) async {
    final mineId      = _pois[idx].id;
    final mineComment = _pois[idx]?.properties?.comment ?? '';
    if (mineId < 1) return;

    try {
      final result = await ref.read(mineRepositoryProvider).getMine(mineId);

      // Mark this point as depleted on the local map
      _pois[idx].properties.ico = '0';
      _pois[idx].lastVisited =
          DateTime.parse(DateTime.now().toUtc().toIso8601String())
              .toLocal()
              .toString();
      selectPoint(-1, 0, _userLocation, '');
      setState(() {
        _infoWindowVisible = false;
        _textFieldController.text = '';
        _images.clear();
      });

      // Invalidate providers and show the Congrats dialog.
      // delayed: true — give the map animation 1 second to settle first.
      MineResultHelper.handle(
        context, ref,
        mineId:  mineId,
        result:  result,
        comment: mineComment,
        delayed: true,
      );
    } on AppError catch (err) {
      Timer(Duration(seconds: 1), () {
        if (!mounted) return;
        // COOLDOWN_ACTIVE → err.message has "Visited Xs ago. Wait Ys"
        // FORBIDDEN       → err.message has "Did you somehow teleported X km ?"
        err.show(context);
      });
    } catch (err) {
      debugPrint('foundMine unexpected error: $err');
    }
  }

  /// the CTA of the Popup
  Widget _actionWidget(BuildContext context) {
    var info = "n/a";
    var now = DateTime.parse(
      DateTime.now().toUtc().toIso8601String(),
    ).toLocal();
    var timeFromLastMine = 65535;
    // ignore: omit_local_variable_types
    double meters = 65535.0;
    // ignore: omit_local_variable_types
    var actionText = "Mine";
    var actionIcon = RPGAwesome.match;

    if (isInPoisList(_mineIdx)) {
      if (_pois[_mineIdx].lastVisited != null) {
        timeFromLastMine = now
            .difference(
              DateTime.parse(_pois[_mineIdx].lastVisited),
            )
            .inSeconds;
      }

      meters = _pois[_mineIdx].distanceToPoint;
      final showDistanceIn = (meters > 1000)
          ? '${(meters / 1000).toStringAsFixed(1)}km'
          : '${meters.toStringAsFixed(1)}m';

      final cooldownStr = (timeFromLastMine > 3600)
          ? '${(timeFromLastMine / 3600).toStringAsFixed(1)}h'
          : ((timeFromLastMine > 60)
              ? '${(timeFromLastMine / 60).toStringAsFixed(1)}min'
              : '${timeFromLastMine}s');
      info = showDistanceIn;
      if (timeFromLastMine < 65535) {
        info += "  ⏱ $cooldownStr";
      }

      //log.d(_pois[_mineIdx].properties.ico);
      //log.d(_pois[_mineIdx].properties.ico.runtimeType);
      if (_pois[_mineIdx].properties.ico == GlobalConstants.pointMine) {
        actionText = "Mine";
        actionIcon = RPGAwesome.shovel;
      } else if (_pois[_mineIdx].properties.ico == GlobalConstants.pointWood) {
        actionText = "Chop";
        actionIcon = RPGAwesome.battered_axe;
      } else if (_pois[_mineIdx].properties.ico ==
              GlobalConstants.pointBattle ||
          _pois[_mineIdx].properties.ico ==
              GlobalConstants.pointBattleground) {
        actionText = "Fight";
        actionIcon = RPGAwesome.broadsword;
      } else if (_pois[_mineIdx].properties.ico == GlobalConstants.pointBoy) {
        actionText = "Campfire";
        actionIcon = RPGAwesome.campfire;
      } else if (_pois[_mineIdx].properties.ico == GlobalConstants.pointGirl) {
        actionText = "Campfire";
        actionIcon = RPGAwesome.campfire;
      } else if (_pois[_mineIdx].properties.ico == GlobalConstants.pointRuins) {
        actionText = "Search";
        actionIcon = RPGAwesome.vase;
      } else if (_pois[_mineIdx].properties.ico ==
          GlobalConstants.pointLibrary) {
        actionText = "Read";
        actionIcon = RPGAwesome.scroll_unfurled;
      } else if (_pois[_mineIdx].properties.ico ==
          GlobalConstants.pointTrader) {
        actionText = "Trade";
        actionIcon = RPGAwesome.gold_bar;
      }
    }

    final bool inRange =
        meters <= digDistance && timeFromLastMine > _user.details.mining;

    if (inRange) {
      // In range — action button (Read / Mine / Fight …)
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: GlobalConstants.appBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(width: 1, color: Colors.white),
        ),
        onPressed: () {
          if (_pois[_mineIdx].properties.ico == GlobalConstants.pointBattle ||
              _pois[_mineIdx].properties.ico ==
                  GlobalConstants.pointBattleground) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RockPaperScissorsPage(
                  mineId: _pois[_mineIdx].id,
                  rndMap: (math.Random.secure().nextInt(2) + 1),
                ),
              ),
            );
          } else {
            _goMine(_mineIdx);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(actionIcon, color: const Color(0xffe90e25)),
            const SizedBox(width: 4),
            Text(
              actionText,
              style: const TextStyle(
                color: Color(0xffe90e25),
                fontSize: 16,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      // Out of range — distance indicator (no button)
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: GlobalConstants.appFg.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.near_me_outlined,
                color: GlobalConstants.appFg.withValues(alpha: 0.6), size: 16),
            const SizedBox(width: 6),
            Text(
              info,
              style: TextStyle(
                color: GlobalConstants.appFg.withValues(alpha: 0.8),
                fontSize: 14,
                fontFamily: 'Open Sans',
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Small icon pill button used in the POI sheet tool row.
  Widget _sheetIconBtn(IconData icon, String label, VoidCallback onTap) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: kGold.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kGold, size: 20),
        ),
      ),
    );
  }

  void _closePopup() {
    selectPoint(-1, 0, _userLocation, "");
    setState(() {
      _infoWindowVisible = false;
      _textFieldController.text = "";
      _images.clear();
    });
  }

  Widget _myCustomPopup(BuildContext context) {
    final isCreator = _mineUid == _user.details.id;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xf2050505),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: kGold.withValues(alpha: 0.25), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── drag handle (swipe down to dismiss) ──────────────
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragEnd: (details) {
                    if ((details.primaryVelocity ?? 0) > 200) _closePopup();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // ── header: title + photo count + close ──────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: popupTitle()),
                    if (_thumbnails.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 2, right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: kGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: kGold.withValues(alpha: 0.4), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_library_outlined,
                                color: kGold, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              '${_thumbnails.length}',
                              style: TextStyle(
                                  color: kGold,
                                  fontSize: 12,
                                  fontFamily: 'Open Sans',
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: _closePopup,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ── comment / name field — creator only ───────────────
                if (isCreator) ...[
                  TextField(
                    controller: _textFieldController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Add a note…",
                      hintStyle: const TextStyle(color: Colors.white38),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: kGold.withValues(alpha: 0.4)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: kGold),
                      ),
                      errorText:
                          _commentIsEmpty ? "Note can't be empty" : null,
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── tool row ──────────────────────────────────────────
                if (_isOnline)
                  Row(
                    children: [
                      _sheetIconBtn(Icons.camera_alt, "Camera", _takePhoto),
                      const SizedBox(width: 8),
                      _sheetIconBtn(Icons.photo, "Gallery", _loadFromGallery),
                      const SizedBox(width: 8),
                      _sheetIconBtn(Icons.delete_outline, "Clear images",
                          _clearFromGallery),
                      const Spacer(),
                      if (_mineIdx >= 0 && _mineIdx < _pois.length)
                        _sheetIconBtn(
                          Icons.directions_walk,
                          "Navigate",
                          () => launchMapApp(
                            _pois[_mineIdx].geometry.coordinates[1],
                            _pois[_mineIdx].geometry.coordinates[0],
                          ),
                        ),
                    ],
                  )
                else
                  Text("Offline",
                      style: TextStyle(
                          color: Colors.white38, fontFamily: 'Open Sans')),

                // ── photo gallery ─────────────────────────────────────
                const SizedBox(height: 10),
                SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _loadedImages(),
                  ),
                ),

                const SizedBox(height: 14),

                // ── action + save side by side ────────────────────────
                Row(
                  children: [
                    // Left: action button (in range) or distance (out of range)
                    Expanded(child: _actionWidget(context)),
                    const SizedBox(width: 8),
                    // Right: save / upload — always visible
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0x22e6a04e),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: kGold, width: 1),
                        ),
                        onPressed: () {
                          if (isCreator && _textFieldController.text.isEmpty) {
                            setState(() => _commentIsEmpty = true);
                            return;
                          }
                          setState(() {
                            _commentIsEmpty = false;
                            _infoWindowVisible = false;
                          });
                          _savePin();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isCreator
                                  ? Icons.check
                                  : Icons.cloud_upload_outlined,
                              color: kGold,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isCreator ? "Save" : "Upload Photos",
                              style: TextStyle(
                                color: kGold,
                                fontSize: 16,
                                fontFamily: 'Cormorant SC',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget betterPoint(BuildContext context, int idx, Mine mine, int icoVar) {
    var highlight = Color(0xaa212121);
    if (icoVar == 1) {
      highlight = Color(0xaa471c00);
    } else if (icoVar == 2) {
      highlight = Color(0xaa132900);
    } else if (icoVar == 3) {
      highlight = Color(0xaa62000a);
    } else if (icoVar == 4) {
      highlight = Color(0xaa003b4f);
    } else if (icoVar == 5) {
      highlight = Color(0xaa420021);
    } else if (icoVar == 6) {
      highlight = Color(0xaa762f15);
    } else if (icoVar == 7) {
      highlight = Color(0xaa5c085c);
    } else if (icoVar == 8) {
      highlight = Color(0xaa322600);
    } else if (icoVar == 9) {
      highlight = Color(0xaa4a0000); // deep crimson — battle arena
    }

    return GestureDetector(
      onTap: () {
        _onClickMarker(idx, mine);
        _onAddPinButtonPressed();
      },
      child: Container(
        //alignment: Alignment.bottomCenter,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: highlight, shape: BoxShape.circle),
        child: Image.asset(
          "assets/images/markers/${icoVar.toString()}.png",
          width: 100,
          height: 133,
        ),
      ),
    );
  }

  // The marker generation function
  Marker _createMarker(context, int idx, Mine mine) {
    var icoVar = int.parse(mine.properties.ico);
    final now =
        DateTime.parse(DateTime.now().toUtc().toIso8601String()).toLocal();
    if (mine.lastVisited != "") {
      icoVar = now.difference(DateTime.parse(mine.lastVisited)).inSeconds < 3600
          ? 0
          : int.parse(mine.properties.ico);
    }

    return Marker(
      point: LatLng(mine.geometry.coordinates[1], mine.geometry.coordinates[0]),
      child: Builder(
          builder: (BuildContext context) =>
              betterPoint(context, idx, mine, icoVar)),
    );
  }

  Widget betterPlayer(BuildContext context, int idx, Mine mine, int icoVar) {
    var highlight = Color(0xaa212121);
    if (icoVar == 1) {
      highlight = Color(0xaa6b3511);
    } else if (icoVar == 2) {
      highlight = Color(0xaa224700);
    } else if (icoVar == 3) {
      highlight = Color(0xaa680e17);
    } else if (icoVar == 4) {
      highlight = Color(0xaa16556b);
    } else if (icoVar == 5) {
      highlight = Color(0xaa761c49);
    } else if (icoVar == 6) {
      highlight = Color(0xaa762f15);
    } else if (icoVar == 7) {
      highlight = Color(0xaa5c085c);
    } else if (icoVar == 8) {
      highlight = Color(0xaa574200);
    }

    return GestureDetector(
      onTap: () {},
      child: Container(
        //alignment: Alignment.bottomCenter,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: highlight, shape: BoxShape.circle),
        child: Image.asset(
          "assets/images/markers/${icoVar.toString()}.png",
          width: 100,
          height: 133,
        ),
      ),
    );
  }

  // The marker generation function
  Marker _createPlayer(context, int idx, Mine mine) {
    var icoVar = int.parse(mine.properties.ico);
    final now =
        DateTime.parse(DateTime.now().toUtc().toIso8601String()).toLocal();
    if (mine.lastVisited != "") {
      icoVar = now.difference(DateTime.parse(mine.lastVisited)).inSeconds < 3600
          ? 0
          : int.parse(mine.properties.ico);
    }

    return Marker(
      point: LatLng(mine.geometry.coordinates[1], mine.geometry.coordinates[0]),
      child: Builder(
          builder: (BuildContext context) =>
              betterPlayer(context, idx, mine, icoVar)),
    );
  }

  ///
  Widget build(BuildContext context) {
    // Populate _user from provider so mining cooldown + notification badge are current
    _user = ref.watch(userProvider).valueOrNull ?? User.blank();

    // Apply music setting for the current user (covers initial load + rebuilds)
    _applyMusicSetting(_user);

    // React to future user changes (e.g. settings saved from another screen)
    ref.listen<AsyncValue<User>>(userProvider, (_, next) {
      next.whenData(_applyMusicSetting);
    });

    // GPS position updates → update local position + trigger radar refresh
    ref.listen<AsyncValue<LtLn>>(locationProvider, (_, next) {
      next.whenData(_updateUserLocation);
    });

    // Battle outcome from RockPaperScissorsPage → trigger _goMine on win
    ref.listen<VisitEvent>(visitEventProvider, (_, event) {
      _updateVisitEvent(event);
    });

    final mapWidget = FlutterMap(
      options: MapOptions(
        initialCenter: _centerOfMap(),
        initialZoom: _mapZoom,
        maxZoom: 18.0,
        onMapEvent: (MapEvent event) {
          if (event is MapEventMove || event is MapEventFlingAnimation) {
            // Distinguish who moved the camera:
            //   isUserDrag    — finger pan/fling → load POIs at new viewport centre
            //   _recenterBtnPressed — GPS recenter → load POIs at user position
            //   neither       — goToRemoteLocation postFrameCallback → skip reload
            //                   (_loadPois was already called at the remote location)
            final isUserDrag = event is MapEventMove &&
                event.source != MapEventSource.mapController;
            final wasGpsRecenter = _recenterBtnPressed;

            _debouncer.run(
              () {
                if (!mounted) return;
                if (wasGpsRecenter) {
                  setState(() {
                    _showRecenterBtn = false;
                    _recenterBtnPressed = false;
                    _displayWindowCenter = event.camera.center;
                    _mapZoom = event.camera.zoom;
                  });
                } else {
                  setState(() {
                    _showRecenterBtn = true;
                    _displayWindowCenter = event.camera.center;
                    _mapZoom = event.camera.zoom;
                  });
                }
                if (isUserDrag || wasGpsRecenter) {
                  _loadPois(LtLn(event.camera.center.latitude,
                      event.camera.center.longitude));
                }
              },
            );
          }
        },
      ),
      children: [
        TileLayer(
          key: ValueKey(_effectiveTileUrl),
          urlTemplate: _effectiveTileUrl,
          userAgentPackageName: 'com.apsoni.geocraft',
        ),
        MarkerLayer(
          markers: markers,
          rotate: false,
        ),
        MarkerLayer(
          markers: List<Marker>.of(
            _players.asMap().entries.map(
                  (entry) => _createPlayer(context, entry.key, entry.value),
                ),
          ),
          rotate: false,
        ),
        MarkerLayer(
          markers: List<Marker>.of(
            _pois.asMap().entries.map(
                  (entry) => _createMarker(context, entry.key, entry.value),
                ),
          ),
          rotate: false,
        ),
      ],
      mapController: mapController,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: appBar,
      body: Stack(
        children: <Widget>[
          mapWidget,
          ConstrainedBox(
            // height: 0,
            constraints: BoxConstraints(maxHeight: 80),
            child: CustomAppBar(
              _customAppBarTextColor,
              _customAppBarIconColor,
              _scaffoldKey,
              systemHeaderBrightness: _systemHeaderBrightness,
              hasNotification:
                  GlobalConstants.menuHasNotification(_user.details),
            ),
          ),
          if (_infoWindowVisible == true) _myCustomPopup(context),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 32.0,
                  ),
                  mapButton(
                      'map-type',
                      _onMapTypeButtonPressed,
                      _mapStyleState == 1
                          ? Icons.brightness_3   // night → tap to go day
                          : Icons.brightness_7), // day  → tap to go night
                  SizedBox(
                    height: 16.0,
                  ),
                  mapButton(
                    'add-point',
                    _onAddPinButtonPressed,
                    (_mineId > 0) ? Icons.remove_red_eye : Icons.add_location,
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  _showRecenterBtn
                      ? mapButton('centering', _moveCameraToUserLocation,
                          Icons.my_location)
                      : SizedBox(height: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }

  void _loadBitmapDescriptor() async {
    // await _createMarkerImageFromAsset(context, 0);
    // await _createMarkerImageFromAsset(context, 1);
    // await _createMarkerImageFromAsset(context, 2);
    // await _createMarkerImageFromAsset(context, 3);
    // await _createMarkerImageFromAsset(context, 4);
    // await _createMarkerImageFromAsset(context, 5);
    // await _createMarkerImageFromAsset(context, 6);
    // await _createMarkerImageFromAsset(context, 7);
    // await _createMarkerImageFromAsset(context, 8);
  }

  /// Returns the asset path for the poi placeholder image matching [ico].
  /// Returns a photo tile for the POI type illustration.
  /// Filename: assets/images/pois/{ico}_{variant}.png
  /// Variant is seeded by mineId (stable per point, no flicker).
  /// Falls back to _01 if the chosen variant doesn't exist yet.
  Widget _poiAssetTile(String ico, int mineId) {
    final variant = (math.Random(mineId).nextInt(2) + 1)
        .toString()
        .padLeft(2, '0');
    final path = 'assets/images/pois/${ico}_$variant.png';
    final fallback = 'assets/images/pois/${ico}_01.png';
    return _photoTile(
      Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset(fallback, fit: BoxFit.cover),
      ),
    );
  }

/// Rounded image tile used in the POI photo strip.
  Widget _photoTile(Widget imageChild) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 140,
        height: 140,
        child: imageChild,
      ),
    );
  }

  List<Widget> _loadedImages() {
    List<Widget> list = [];
    list.add(const SizedBox(width: 4));

    // Locally picked / captured images (pending upload)
    for (var file in _images) {
      list.add(_photoTile(
        Image.file(File(file.path), fit: BoxFit.cover),
      ));
      list.add(const SizedBox(width: 8));
    }

    // Server thumbnails uploaded by any player
    for (var thumb in _thumbnails) {
      list.add(_photoTile(
        Image.network(
          "https://${GlobalConstants.apiHostUrl}$thumb",
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : Container(
                  color: const Color(0xff111111),
                  child: Center(child: kCompassLoader()),
                ),
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xff111111),
            child: const Icon(Icons.broken_image_outlined,
                color: Colors.white24, size: 32),
          ),
        ),
      ));
      list.add(const SizedBox(width: 8));
    }

    // No player photos yet — show the POI type illustration as a placeholder tile
    if (_images.isEmpty && _thumbnails.isEmpty && isInPoisList(_mineIdx)) {
      list.add(_poiAssetTile(
        _pois[_mineIdx].properties.ico,
        _mineId,
      ));
      list.add(const SizedBox(width: 8));
    }

    return list;
  }

  Future _takePhoto() async {
    //ignore: omit_local_variable_types
    final ImagePicker picker = ImagePicker();
    try {
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
      if (pickedFile != null) {
        setState(() {
          _images.add(File(pickedFile.path));
        });
      }
    } on Exception catch (err) {
      print(err);
    }
  }

  void _loadFromGallery() async {
    //ignore: omit_local_variable_types
    final ImagePicker picker = ImagePicker();
    try {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
      if (pickedFile != null) {
        setState(() {
          _images.add(File(pickedFile.path));
        });
      }
    } on Exception catch (err) {
      print(err);
    }
  }

  void _clearFromGallery() async {
    setState(() {
      _images.clear();
    });
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Notice',
        description: 'Images no longer are to be uploaded',
        buttonText: "Okay",
        images: [],
        callback: () {},
      ),
    );
  }

  void _updateUserLocation(LtLn location) async {
    setState(() {
      _userLocation = location;
    });
    if (!_showRecenterBtn) {
      _moveCameraToUserLocation();
    }
  }

  void _updateVisitEvent(VisitEvent event) async {
    if (!isInPoisList(_mineIdx)) {
      return;
    }
    if (_pois[_mineIdx].id == event.mineId) {
      print('Battle for point ${event.mineId} is ${event.outcome}');
      if (event.outcome == 1) {
        _goMine(_mineIdx);
      }
    }
  }

  /// When ready to send
  /// This should work also in offline mode with no internet
  void _savePin() async {
    var pin = PinLocation(
      mineId: _mineId,
      lat: _userLocation.latitude,
      lng: _userLocation.longitude,
      desc: _textFieldController.text,
    );

    if (_isOnline) {
      // When going back online
      if (_pinsToBeAdded.length > 0) {
        // Take all memorized points
        for (var p in _pinsToBeAdded) {
          // and save them in the cloud
          // _mineId is also populated on Upload
          _modifyPin(p);
        }
        _pinsToBeAdded.clear();
      }

      // Save the current pin also
      if (_mineUid == _user.details.id) {
        _modifyPin(pin);
      }

      // Only upload pictures if the mine has a DB id
      if (_mineId > 0 && _images.length > 0) {
        for (var image in _images) {
          try {
            await _apiProvider.uploadLandmarkPicture(
                "/landmark/$_mineId", image);
          } on AppError catch (err) {
            err.show(context);
          } catch (err) {
            debugPrint('uploadLandmarkPicture unexpected error: $err');
          }
        }
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: AppLocalizations.of(context)!.translate('congrats'),
            description: "${_images.length} pictures uploaded.",
            buttonText: "Okay",
            images: [],
            callback: () {},
          ),
        );
      }

      return;
    }

    _images.clear();
    _thumbnails.clear();

    _pinsToBeAdded.add(pin);
    _textFieldController.text = "";
  }

  /// Save the modifications in the cloud
  void _modifyPin(PinLocation pin) async {
    _mineId = pin.mineId;
    dynamic response;
    try {
      response = await _apiProvider.save(pin.mineId, '/mine', {
        "mine_id": pin.mineId,
        "lat": pin.lat,
        "lng": pin.lng,
        "desc": pin.desc
      });
    } on AppError catch (_) {
      return;
    } catch (err) {
      debugPrint('_modifyPin unexpected error: $err');
      return;
    }

    _textFieldController.text = "";
    if (response is Map && response.containsKey("message")) {
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
    }

    if (response is Map && response.containsKey("mine_id")) {
      //populate the _mineId also
      _mineId = int.tryParse(response["mine_id"].toString()) ?? 0;
    }

    return;
  }

  void _moveCameraToUserLocation() {
    setState(() {
      _recenterBtnPressed = true;
    });
    mapController.move(
      LatLng(_userLocation.latitude, _userLocation.longitude),
      _mapZoom,
    );
  }

  void launchMapApp(double lat, double lng) async {
    var url = Uri.parse("waze://?ll=${lat.toString()},${lng.toString()}");
    bool launched = false;
    if (await canLaunchUrl(url)) {
      launched = await launchUrl(url);
      if (launched == true) {
        return;
      }
    }
    var fallbackUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${lat.toString()},${lng.toString()}");
    if (Platform.isAndroid) {
      url = Uri.parse(
          "geo:${lat.toString()},${lng.toString()}?q=${lat.toString()},${lng.toString()}");
      fallbackUrl = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=${lat.toString()},${lng.toString()}");
    } else if (Platform.isIOS) {
      url = Uri.parse("maps://?ll=${lat.toString()},${lng.toString()}");
      fallbackUrl = Uri.parse(
          "http://maps.apple.com/?ll=${lat.toString()},${lng.toString()}");
    }
    try {
      launched = await launchUrl(url);
      if (!launched) {
        await launchUrl(fallbackUrl);
      }
    } on Exception catch (_) {
      await launchUrl(fallbackUrl);
    }
  }
}
