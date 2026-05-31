///
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
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
    with SingleTickerProviderStateMixin {
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

  /// map style type is 0 for day 1 for night 2 for automatic gps
  int _mapStyleState = 2;

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

    for (var img in _pois[idx].properties.thumbnails) {
      _thumbnails.add(img);
    }

    return;
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

    _goToRemoteLocation = widget.goToRemoteLocation;
    _remoteLat = widget.latitude;
    _remoteLng = widget.longitude;

    // GPS + visit-event streams are wired via ref.listen() in build().

    timer = Timer.periodic(
      Duration(minutes: 30),
      (t) => dayAndNight(_userLocation),
    );

    dayAndNight(_userLocation);

  }

  @override
  void dispose() {
    timer?.cancel();
    _pois.clear();
    //if (mapController != null) { mapController.removeListener(_onMapChanged); }
    super.dispose();
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

  // Change map theme based on daylight
  void dayAndNight(LtLn location) async {
    var datenow = DateTime.now();

    //datenow = DateTime.parse("2020-05-30 13:18:04Z"); print('--- log. dayAndNight ---'); print(datenow);

    final astroResult =
        SunCalc.getTimes(datenow, location.latitude, location.longitude);

    var isDayTime =
        SunCalc.isDaytime(datenow, astroResult.sunrise, astroResult.sunset);

    if (_mapStyleState == 0 /* day */) {
      setState(() {
        _customAppBarTextColor = Colors.black;
        _customAppBarIconColor = Colors.black;
        _systemHeaderBrightness = Brightness.light;
        mapType = 'outdoors';
      });
    } else if (_mapStyleState == 1 /* night */) {
      setState(() {
        _customAppBarTextColor = Colors.white;
        _customAppBarIconColor = Colors.white;
        _systemHeaderBrightness = Brightness.dark;
        mapType = 'dark';
      });
    } else if (_mapStyleState == 2 /* auto */) {
      if (isDayTime == true) {
        /// Day
        setState(() {
          _customAppBarTextColor = Colors.black;
          _customAppBarIconColor = Colors.black;
          _systemHeaderBrightness = Brightness.light;
          mapType = 'outdoors';
        });
      } else {
        /// Night
        setState(() {
          _customAppBarTextColor = Colors.white;
          _customAppBarIconColor = Colors.white;
          _systemHeaderBrightness = Brightness.dark;
          mapType = 'dark';
        });
      }
    } else if (_mapStyleState == 3 /* terrain */) {
      /// Night
      setState(() {
        _customAppBarTextColor = Colors.white;
        _customAppBarIconColor = Colors.white;
        _systemHeaderBrightness = Brightness.dark;
        mapType = 'terrain';
      });
    }
  }

  Widget popupTitle() {
    var dots = ".";
    dots = dots * _pinsToBeAdded.length;
    if (_mineId > 0) {
      return Row(
        children: <Widget>[
          Text(
            "Point $_mineId ",
            style: TextStyle(
              color: GlobalConstants.appFg,
              fontFamily: 'Cormorant SC',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            " - User $_mineUid",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      );
    }
    return Text(
      "Add New Point $dots",
      style: TextStyle(
        color: GlobalConstants.appFg,
        fontFamily: 'Cormorant SC',
        fontWeight: FontWeight.bold,
      ),
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
      _mapStyleState++;
      if (_mapStyleState >= 4) {
        _mapStyleState = 0;
      }
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
      _loadPois(LtLn(_remoteLat, _remoteLng));
      _goToRemoteLocation = false;
      _mapZoom = 16;
      return LatLng(_remoteLat, _remoteLng);
    }

    return LatLng(_userLocation.latitude, _userLocation.longitude);
  }

  ///
  Future _goMine(int idx) async {
    final mineId = _pois[idx].id;
    final mineComment = _pois[idx]?.properties?.comment ?? '';
    if (mineId < 1) return;

    try {
      final result =
          await ref.read(mineRepositoryProvider).getMine(mineId);

      //ignore: omit_local_variable_types
      final List<Image> imagesArr = [];

      for (final item in result.items) {
        if (item.img.isNotEmpty) {
          imagesArr.add(Image.asset('assets/images/items/${item.img}'));
        }
      }
      for (final mat in result.materials) {
        if (mat.img.isNotEmpty) {
          imagesArr.add(Image.asset('assets/images/materials/${mat.img}'));
        }
      }
      for (final bp in result.blueprints) {
        // Blueprint.blank() has img == 'nothing.png'; skip it
        if (bp.img.isNotEmpty && bp.img != 'nothing.png') {
          imagesArr.add(Image.asset('assets/images/blueprints/${bp.img}'));
        }
      }

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

      // Refresh user coins/xp in drawer
      ref.invalidate(userProvider);

      Timer(Duration(seconds: 1), () {
        if (!mounted) return;
        final mining =
            AppLocalizations.of(context)!.translate('you_found_point');
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: AppLocalizations.of(context)!.translate('congrats'),
            description: '$mining $mineId, $mineComment',
            buttonText: 'Okay',
            images: imagesArr,
            callback: () {},
          ),
        );
      });
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

      final lastVisited = (timeFromLastMine > 3600)
          ? '${(timeFromLastMine / 3600).toStringAsFixed(1)}h'
          : ((timeFromLastMine > 60)
              ? '${(timeFromLastMine / 60).toStringAsFixed(1)}m'
              : '${timeFromLastMine}s');
      info = "$showDistanceIn ";
      if (timeFromLastMine < 65535) {
        info += " $lastVisited";
      } else {
        info += "";
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
          GlobalConstants.pointBattle) {
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

    if (meters <= digDistance && timeFromLastMine > _user.details.mining) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.only(left: 3, right: 3, top: 10, bottom: 10),
              backgroundColor: GlobalConstants.appBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              side: BorderSide(width: 1, color: Colors.white),
            ),
            onPressed: () {
              if (_pois[_mineIdx].properties.ico == GlobalConstants.pointMine) {
                _goMine(_mineIdx);
              } else if (_pois[_mineIdx].properties.ico ==
                  GlobalConstants.pointWood) {
                _goMine(_mineIdx);
              } else if (_pois[_mineIdx].properties.ico ==
                  GlobalConstants.pointBattle) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RockPaperScissorsPage(
                      mineId: _pois[_mineIdx].id,
                      rndMap: (math.Random.secure().nextInt(2) + 1),
                    ),
                  ),
                );
              } else if (_pois[_mineIdx].properties.ico ==
                  GlobalConstants.pointBoy) {
                _goMine(_mineIdx);
              } else if (_pois[_mineIdx].properties.ico ==
                  GlobalConstants.pointGirl) {
                _goMine(_mineIdx);
              } else if (_pois[_mineIdx].properties.ico ==
                  GlobalConstants.pointRuins) {
                _goMine(_mineIdx);
              } else if (_pois[_mineIdx].properties.ico ==
                  GlobalConstants.pointLibrary) {
                _goMine(_mineIdx);
              } else if (_pois[_mineIdx].properties.ico ==
                  GlobalConstants.pointTrader) {
                _goMine(_mineIdx);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(actionIcon, color: Color(0xffe90e25)),
                Text(
                  actionText,
                  style: TextStyle(
                    color: Color(0xffe90e25),
                    fontSize: 16,
                    fontFamily: 'Cormorant SC',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            info,
            style: TextStyle(color: GlobalConstants.appFg),
          )
        ],
      );
    }
  }

  Widget _myCustomPopup(BuildContext context) {
    return Dialog(
      backgroundColor: GlobalConstants.appBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GlobalConstants.padding),
      ),
      //elevation: 0.0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                popupTitle(),
                Column(
                  children: <Widget>[
                    TextField(
                      controller: _textFieldController,
                      style: TextStyle(color: GlobalConstants.appFg),
                      decoration: InputDecoration(
                          hintText: "Comment",
                          hintStyle: TextStyle(color: Colors.grey),
                          errorText: _commentIsEmpty == true
                              ? 'Comment can\'t be empty'
                              : null),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _isOnline
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: <Widget>[
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.only(
                                        left: 2, right: 2, top: 10, bottom: 10),
                                    backgroundColor: GlobalConstants.appBg,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    side: BorderSide(
                                        width: 1, color: Colors.white),
                                  ),
                                  onPressed: _takePhoto,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.camera_alt,
                                        color: Color(0xffe6a04e),
                                      ),
                                      Text(
                                        " Cam",
                                        style: TextStyle(
                                            color: Color(0xffe6a04e),
                                            fontSize: 16,
                                            fontFamily: 'Cormorant SC',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.only(
                                        left: 2, right: 2, top: 10, bottom: 10),
                                    backgroundColor: GlobalConstants.appBg,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    side: BorderSide(
                                        width: 1, color: Colors.white),
                                  ),
                                  onPressed: _loadFromGallery,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.photo,
                                        color: Color(0xffe6a04e),
                                      ),
                                      Text(
                                        " Pic",
                                        style: TextStyle(
                                            color: Color(0xffe6a04e),
                                            fontSize: 16,
                                            fontFamily: 'Cormorant SC',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.only(
                                        left: 2, right: 2, top: 10, bottom: 10),
                                    backgroundColor: GlobalConstants.appBg,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    side: BorderSide(
                                        width: 1, color: Colors.white),
                                  ),
                                  onPressed: () => launchMapApp(
                                      _pois[_mineIdx].geometry.coordinates[1],
                                      _pois[_mineIdx].geometry.coordinates[0]),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.directions_walk,
                                          color: Color(0xffe6a04e)),
                                      Text(
                                        " Go",
                                        style: TextStyle(
                                            color: Color(0xffe6a04e),
                                            fontSize: 16,
                                            fontFamily: 'Cormorant SC',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.only(
                                        left: 2, right: 2, top: 10, bottom: 10),
                                    backgroundColor: GlobalConstants.appBg,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    side: BorderSide(
                                        width: 1, color: Colors.white),
                                  ),
                                  onPressed: _clearFromGallery,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.delete,
                                        color: Color(0xffe6a04e),
                                      ),
                                      Text(
                                        " Clear",
                                        style: TextStyle(
                                            color: Color(0xffe6a04e),
                                            fontSize: 16,
                                            fontFamily: 'Cormorant SC',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Text(
                            "Offline",
                            style: TextStyle(color: GlobalConstants.appFg),
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 200,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _loadedImages(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.only(
                              left: 2, right: 2, top: 10, bottom: 10),
                          backgroundColor: GlobalConstants.appBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          side: BorderSide(width: 1, color: Colors.white),
                        ),
                        onPressed: () {
                          selectPoint(-1, 0, _userLocation, "");
                          setState(() {
                            _infoWindowVisible = false;
                            _textFieldController.text = "";
                            _images.clear();
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.close,
                              color: Color(0xffe6a04e),
                            ),
                            Text(
                              "Cancel",
                              style: TextStyle(
                                  color: Color(0xffe6a04e),
                                  fontSize: 16,
                                  fontFamily: 'Cormorant SC',
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: _actionWidget(context),
                    ),
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.only(
                              left: 2, right: 2, top: 10, bottom: 10),
                          backgroundColor: GlobalConstants.appBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          side: BorderSide(width: 1, color: Colors.white),
                        ),
                        onPressed: () {
                          if (_textFieldController.text == "") {
                            setState(() {
                              _commentIsEmpty = true;
                            });
                            return;
                          } else {
                            setState(() {
                              _commentIsEmpty = false;
                              _infoWindowVisible = false;
                            });
                            _savePin();
                            return;
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.check,
                              color: Color(0xffe6a04e),
                            ),
                            Text(
                              "Save",
                              style: TextStyle(
                                  color: Color(0xffe6a04e),
                                  fontSize: 16,
                                  fontFamily: 'Cormorant SC',
                                  fontWeight: FontWeight.bold),
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
            _debouncer.run(
              () {
                if (!mounted) return;
                if (_recenterBtnPressed) {
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
                _loadPois(_userLocation);
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
                      (_mapStyleState == 0)
                          ? Icons.brightness_7
                          : ((_mapStyleState == 1)
                              ? Icons.brightness_3
                              : ((_mapStyleState == 2)
                                  ? Icons.timelapse
                                  : Icons.layers_outlined))),
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

  List<Widget> _loadedImages() {
    //print('_loadedImages');
    //print(_images.length);
    //print(_thumbnails.length);
    //ignore: omit_local_variable_types
    List<Widget> list = [];
    list.add(SizedBox(width: 10));
    if (_images.length > 0) {
      for (var file in _images) {
        list.add(
          Image.file(
            File(file.path),
            scale: 7,
          ),
        );
        list.add(SizedBox(width: 10));
      }
    }

    if (_thumbnails.length > 0) {
      for (var thumb in _thumbnails) {
        list.add(
          Image.network("https://${GlobalConstants.apiHostUrl}$thumb"),
          //NetworkImage("https://${GlobalConstants.apiHostUrl}$thumb"),
        );
        list.add(SizedBox(width: 10));
      }
    }

    if (_images.length == 0 && _thumbnails.length == 0) {
      list.add(Image.asset(
        'assets/images/magnifying_glass.png',
        height: 200,
      ));
      list.add(SizedBox(width: 10));
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
