///
import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geohunter/fonts/rpg_awesome_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
//import 'package:user_location/user_location.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:logger/logger.dart';

///
import '../app_localizations.dart';
import '../models/location.dart';
import '../models/mine.dart';
import '../models/user.dart';
import '../providers/api_provider.dart';
import '../providers/stream_location.dart';
import '../providers/stream_mines.dart';
import '../shared/constants.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/drawer.dart';

///
GetIt getIt = GetIt.instance;

final _debouncer2 = Debouncer(milliseconds: 500);

///
class PoiMap extends StatefulWidget {
  /// Widget name
  final String name = "poi-map";

  ///
  bool goToRemoteLocation = false;

  ///
  double latitude = 51.5;

  ///
  double longitude = 0.0;

  ///
  PoiMap({Key key, this.goToRemoteLocation, this.latitude, this.longitude})
      : super(key: key);

  @override
  _PoiMapState createState() => _PoiMapState();
}

class _PoiMapState extends State<PoiMap>
    with SingleTickerProviderStateMixin<PoiMap> {
  final Logger log = Logger(
      printer: PrettyPrinter(
          colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  String _mapStyle = '';
  String _mapStyleAubergine = '';

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
  LatLng _displayWindowCenter;

  /// final _storage = FlutterSecureStorage();
  /// await _storage.write(key: 'key', value: 'value');
  /// var secureStorage = await _storage.readAll();
  final List<PinLocation> _pinsToBeAdded = [];

  /// map style type is 0 for day 1 for night 2 for automatic gps
  int _mapStyleState = 2;

  /// Make sure back button is pressed twice
  bool ifPop = false;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _textFieldController = TextEditingController();

  ///
  bool _isOnline = true;
  bool _commentIsEmpty = false;
  bool _infoWindowVisible = false;
  bool _recenterBtnPressed = false;
  bool _showRecenterBtn = false;

  Timer timer;
  Color _customAppBarTextColor = Colors.black;
  Color _customAppBarIconColor = Colors.black;
  Brightness _systemHeaderBrightness = Brightness.light;
  final _pois = [];
  final _players = [];

  final _apiProvider = ApiProvider();
  //int _screenRebuilded = 1;
  final List<File> _images = [];
  final List<String> _thumbnails = [];
  final _storage = FlutterSecureStorage();

  Mine _mine;
  int _mineIdx = -1;
  int _mineId = 0;
  String _mineUid;

  /// Curent loggedin user
  User _user;

  String mapType = "outdoors-v11";

  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Future _loadPois(LtLn location) async {
    print("--- Loading pois ---");
    if (location.latitude == 51.5 && location.longitude == 0) {
      return;
    }

    var url = '';
    if (_displayWindowCenter != null) {
      var d = 39136000 *
          math.cos(degToRadian(location.longitude)) /
          math.pow(2, _mapZoom);
      if (d > 10000000) {
        d = 10000000;
        /* cap to 10km */
      }

      final neLat = _displayWindowCenter.latitude +
          radianToDeg(d / earthRadius); /* max lat */
      final swLat = _displayWindowCenter.latitude -
          radianToDeg(d / earthRadius); /* min lat */

      final neLng = _displayWindowCenter.longitude +
          radianToDeg(math.asin(d / earthRadius) /
              math.cos(
                  degToRadian(_displayWindowCenter.latitude))); /* max lng */
      final swLng = _displayWindowCenter.longitude -
          radianToDeg(math.asin(d / earthRadius) /
              math.cos(
                  degToRadian(_displayWindowCenter.latitude))); /* min lng */
      // await _storage.write(key: 'swLng', value: swLng.toString());
      // await _storage.write(key: 'swLat', value: swLat.toString());
      // await _storage.write(key: 'neLng', value: neLng.toString());
      // await _storage.write(key: 'neLat', value: neLat.toString());
      // await _storage.write(key: 'mapZoom', value: _mapZoom.toString());

      url =
          '/radar?cntr_lng=${location.longitude.toString()}&cntr_lat=${location.latitude.toString()}&zoom=$_mapZoom&sw_lng=${swLng.toString()}&sw_lat=${swLat.toString()}&ne_lng=${neLng.toString()}&ne_lat=${neLat.toString()}';
    } else {
      url =
          '/radar?cntr_lng=${location.longitude.toString()}&cntr_lat=${location.latitude.toString()}&zoom=$_mapZoom';
    }

    final features = [];
    final players = [];
    dynamic response;
    if (_isOnline) {
      try {
        response = await _apiProvider.get(url);
      } on DioError catch (err) {
        if (err.type == DioErrorType.connectTimeout) {
          return;
        } else if (err.response == null) {
          return;
        } else if (err.response.statusCode == 401) {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/login');
          return;
        }
        return;
      }

      if (response.containsKey("success")) {
        if (response["success"] == true) {
          //add the mines to the map
          if (response.containsKey("geojson")) {
            if (response["geojson"]["features"] != null) {
              for (dynamic elem in response["geojson"]["features"]) {
                final mine = Mine(elem, 1, location: _userLocation);
                features.add(mine);
              }
            }
          }
          // add the players to the map
          if (response.containsKey("players")) {
            if (response["players"]["features"] != null) {
              for (dynamic elem in response["players"]["features"]) {
                final mine = Mine(elem, 2, location: _userLocation);
                players.add(mine);
              }
            }
          }
        }
      }

      var _locationMarker = Marker(
        height: 20.0,
        width: 20.0,
        point: LatLng(_userLocation.latitude, _userLocation.longitude),
        builder: (context) {
          return Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue[300].withOpacity(0.7),
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
        },
      );

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

  final _minesStreamBus = getIt.get<StreamMines>();
  StreamSubscription<List<Mine>> _minesStreamSubscription;
  final _locationStreamBus = getIt.get<StreamLocation>();
  StreamSubscription<LtLn> _locationStreamSubscription;

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

    _getCurrentUser();
    _minesStreamSubscription = _minesStreamBus.stream$.listen(_loadMines);
    _locationStreamSubscription =
        _locationStreamBus.stream$.listen(_updateUserLocation);

    timer = Timer.periodic(
      Duration(minutes: 30),
      (t) => dayAndNight(_userLocation),
    );

    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyle = string;
    });
    rootBundle.loadString('assets/map_style_aubergine.json').then((string) {
      _mapStyleAubergine = string;
    });

    dayAndNight(_userLocation);

    BackButtonInterceptor.add(myInterceptor,
        name: widget.name, context: context);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    timer?.cancel();
    _pois.clear();
    _minesStreamSubscription.cancel();
    _locationStreamSubscription?.cancel();
    //if (mapController != null) { mapController.removeListener(_onMapChanged); }
    super.dispose();
  }

  // ignore: avoid_positional_boolean_parameters
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (stopDefaultButtonEvent) return false;
    if (ifPop) {
      return false;
    } else {
      setState(() => ifPop = true);
      if (_scaffoldKey != null) {
        //_scaffoldKey.currentState.openDrawer();
        Navigator.of(context).pop();
      }
    }
    return true;
  }

  Future _getCurrentUser() async {
    final tmp = await _apiProvider.getStoredUser();
    setState(() {
      _user = tmp;
    });
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

    //datenow = DateTime.parse("2020-05-30 13:18:04Z"); print('--- dayAndNight ---'); print(datenow);

    final astroResult =
        SunCalc.getTimes(datenow, location.latitude, location.longitude);

    var isDayTime =
        SunCalc.isDaytime(datenow, astroResult.sunrise, astroResult.sunset);

    if (_mapStyleState == 0 /* day */) {
      setState(() => {
            _customAppBarTextColor = Colors.black,
            _customAppBarIconColor = Colors.black,
            _systemHeaderBrightness = Brightness.light,
            mapType = 'outdoors-v11',
          });
    } else if (_mapStyleState == 1 /* night */) {
      setState(() => {
            _customAppBarTextColor = Colors.white,
            _customAppBarIconColor = Colors.white,
            _systemHeaderBrightness = Brightness.dark,
            mapType = 'dark-v10',
          });
    } else if (_mapStyleState == 2 /* auto */) {
      if (isDayTime == true) {
        /// Day
        setState(() => {
              _customAppBarTextColor = Colors.black,
              _customAppBarIconColor = Colors.black,
              _systemHeaderBrightness = Brightness.light,
              mapType = 'outdoors-v11',
            });
      } else {
        /// Night
        setState(() => {
              _customAppBarTextColor = Colors.white,
              _customAppBarIconColor = Colors.white,
              _systemHeaderBrightness = Brightness.dark,
              mapType = 'dark-v10',
            });
      }
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

  Widget mapButton(String tag, Function function, IconData icon) {
    return FloatingActionButton(
      heroTag: tag,
      onPressed: function,
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
      if (_mapStyleState >= 3) {
        _mapStyleState = 0;
      }
      dayAndNight(_userLocation);
    });
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
    if (widget.goToRemoteLocation == true) {
      _showRecenterBtn = true;
      _loadPois(LtLn(widget.latitude, widget.longitude));
      widget.goToRemoteLocation = false;
      _mapZoom = 16;
      return LatLng(widget.latitude, widget.longitude);
    }

    return LatLng(_userLocation.latitude, _userLocation.longitude);
  }

  ///
  Future _goMine(int _mineIdx) async {
    dynamic response;
    var mineId = _pois[_mineIdx].id;
    var mineComment = _pois[_mineIdx]?.properties?.comment;
    if (mineId < 1) {
      return;
    }
    try {
      response = await _apiProvider.get(
        '/mine?mine_id=$mineId',
      );

      if (response.containsKey("success")) {
        //ignore: omit_local_variable_types
        List<Image> imagesArr = [];

        if (response["items"].isNotEmpty) {
          for (dynamic value in response["items"]) {
            if (value.containsKey("img") && value["img"] != "") {
              //mine.addItem(value);
              imagesArr.add(Image.asset("assets/images/items/${value['img']}"));
              //} else { log.d(value);
            }
          }
        }

        for (dynamic value in response["materials"]) {
          if (value.containsKey("img") && value["img"] != "") {
            //mine.addMaterial(value);
            imagesArr
                .add(Image.asset("assets/images/materials/${value['img']}"));
            //} else { log.d(value);
          }
        }

        for (dynamic value in response["blueprints"]) {
          if (value.containsKey("img") && value["img"] != "") {
            imagesArr
                .add(Image.asset("assets/images/blueprints/${value['img']}"));
            //} else { log.d(value);
          }
        }

        // Show this mine as already mined
        _pois[_mineIdx].properties.ico = "0";
        _pois[_mineIdx].lastVisited =
            DateTime.parse(DateTime.now().toUtc().toIso8601String())
                .toLocal()
                .toString();
        selectPoint(-1, 0, _userLocation, "");
        setState(() {
          _infoWindowVisible = false;
          _textFieldController.text = "";
          _images.clear();
        });

        Timer(
          Duration(seconds: 1),
          () {
            //ignore: omit_local_variable_types
            String mining =
                AppLocalizations.of(context).translate('you_found_point');
            showDialog(
              context: context,
              builder: (context) => CustomDialog(
                title: AppLocalizations.of(context).translate('congrats'),
                description: "$mining $mineId, $mineComment",
                buttonText: "Okay",
                images: imagesArr,
              ),
            );
          },
        );
      }
    } on DioError catch (err) {
      //log.e(err);
      Timer(
        Duration(seconds: 1),
        () {
          showDialog(
            context: context,
            builder: (context) => CustomDialog(
              title: 'Error',
              description: '${err.response?.data}',
              buttonText: "Okay",
            ),
          );
        },
      );
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
        actionIcon = RPGAwesome.bowie_knife;
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

    if (meters <= digDistance && timeFromLastMine > _user.details.miningSpeed) {
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
              _goMine(_mineIdx);
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
        borderRadius: BorderRadius.circular(2),
      ),
      //elevation: 0,
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
    if (mine.lastVisited != "" && mine.lastVisited != null) {
      icoVar = now.difference(DateTime.parse(mine.lastVisited)).inSeconds < 3600
          ? 0
          : int.parse(mine.properties.ico);
    }

    return Marker(
      point: LatLng(mine.geometry.coordinates[1], mine.geometry.coordinates[0]),
      builder: (context) => betterPoint(context, idx, mine, icoVar),
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
    if (mine.lastVisited != "" && mine.lastVisited != null) {
      icoVar = now.difference(DateTime.parse(mine.lastVisited)).inSeconds < 3600
          ? 0
          : int.parse(mine.properties.ico);
    }

    return Marker(
      point: LatLng(mine.geometry.coordinates[1], mine.geometry.coordinates[0]),
      builder: (context) => betterPlayer(context, idx, mine, icoVar),
    );
  }

  ///
  Widget build(BuildContext context) {
    // Determining the screen width & height
    //var szHeight = MediaQuery.of(context).size.height;
    //var szWidth = MediaQuery.of(context).size.width;

    _createMap() {
      return TileLayerOptions(
        urlTemplate: "https://api.mapbox.com/styles/v1/"
            "{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
        additionalOptions: {
          'accessToken': GlobalConstants.mapboxToken,
          'id': "mapbox/$mapType",
        },
      );
    }

    final mapWidget = FlutterMap(
      options: MapOptions(
        center: _centerOfMap(),
        zoom: _mapZoom,
        maxZoom: 18.0,
        plugins: [
          //user_location
          //UserLocationPlugin(),
        ],
        onPositionChanged: (mapPosition, boolValue) => {
          _debouncer2.run(
            () => {
              if (_recenterBtnPressed)
                {
                  setState(() {
                    _showRecenterBtn = false;
                    _recenterBtnPressed = false;
                    _displayWindowCenter = mapPosition.center;
                    _mapZoom = mapPosition.zoom;
                  })
                }
              else
                {
                  setState(() {
                    _showRecenterBtn = true;
                    _displayWindowCenter = mapPosition.center;
                    _mapZoom = mapPosition.zoom;
                  })
                },
              _loadPois(_userLocation)
            },
          )
        },
      ),
      layers: [
        _createMap(),
        //user_location
        //userLocationOptions,
        MarkerLayerOptions(markers: markers),
        MarkerLayerOptions(
          markers: List<Marker>.of(
            _players.asMap().entries.map(
                  (entry) => _createPlayer(context, entry.key, entry.value),
                ),
          ),
        ),
        MarkerLayerOptions(
          markers: List<Marker>.of(
            _pois.asMap().entries.map(
                  (entry) => _createMarker(context, entry.key, entry.value),
                ),
          ),
        ),
      ],
      mapController: mapController,
    );

    //user_location
    // userLocationOptions = UserLocationOptions(
    //   context: context,
    //   mapController: mapController,
    //   markers: markers,
    //   updateMapLocationOnPositionChange: false,
    //   showMoveToCurrentLocationFloatingActionButton: false,
    //   zoomToCurrentLocationOnLoad: true,
    // );

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
                _customAppBarTextColor, _customAppBarIconColor, _scaffoldKey,
                systemHeaderBrightness: _systemHeaderBrightness),
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
                              : Icons.timelapse)),
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
          await picker.getImage(source: ImageSource.camera, imageQuality: 100);
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
          await picker.getImage(source: ImageSource.gallery, imageQuality: 100);
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
      ),
    );
  }

  void _loadMines(List<Mine> mines) async {
    print(' --- _loadMines from Stream --- ');
    if (mines != null) {
      setState(() {
        _pois.clear();
        _pois.addAll(mines.toList());
      });
    }
  }

  void _updateUserLocation(LtLn location) async {
    setState(() {
      _userLocation = location;
    });
    if (!_showRecenterBtn) {
      _moveCameraToUserLocation();
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
          } on DioError catch (err) {
            if (err?.response != null) {
              showDialog(
                context: context,
                builder: (context) => CustomDialog(
                  title: 'Error',
                  description: err.response.data['message'],
                  buttonText: "Okay",
                ),
              );
            }
          }
        }
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: AppLocalizations.of(context).translate('congrats'),
            description: "${_images.length} pictures uploaded.",
            buttonText: "Okay",
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
    } on DioError catch (err) {
      // if (err?.response != null) {
      //   showDialog(
      //     context: context,
      //     builder: (context) => CustomDialog(
      //       title: 'Error',
      //       description: err.response.data['message'],
      //       buttonText: "Okay",
      //     ),
      //   );
      // }
      return;
    }

    _textFieldController.text = "";
    if (response.containsKey("message")) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: AppLocalizations.of(context).translate('congrats'),
          description: response["message"],
          buttonText: "Okay",
        ),
      );
    }

    if (response.containsKey("mine_id")) {
      //populate the _mineId also
      _mineId = int.tryParse(response["mine_id"].toString()) ?? 0;
    }

    return;
  }

  void _moveCameraToUserLocation() {
    setState(() {
      _recenterBtnPressed = true;
    });
    if (mapController != null) {
      mapController.move(
        LatLng(_userLocation.latitude, _userLocation.longitude),
        _mapZoom,
      );
    }
  }

  void _moveCameraToLocation(double latitude, double longitude) {
    setState(() {
      _recenterBtnPressed = false;
    });
    if (mapController != null) {
      mapController.move(
        LatLng(latitude, longitude),
        _mapZoom,
      );
    }
  }

  void launchMapApp(double lat, double lng) async {
    var url = "waze://?ll=${lat.toString()},${lng.toString()}";
    // ignore: omit_local_variable_types
    bool launched = false;
    if (await canLaunch(url)) {
      launched = await launch(url, forceSafariVC: false, forceWebView: false);
      if (launched == true) {
        return;
      }
    }
    var fallbackUrl =
        "https://www.google.com/maps/search/?api=1&query=${lat.toString()},${lng.toString()}";
    if (Platform.isAndroid) {
      url =
          "geo:${lat.toString()},${lng.toString()}?q=${lat.toString()},${lng.toString()}";
      fallbackUrl =
          "https://www.google.com/maps/search/?api=1&query=${lat.toString()},${lng.toString()}";
    } else if (Platform.isIOS) {
      url = "maps://?ll=${lat.toString()},${lng.toString()}";
      fallbackUrl =
          "http://maps.apple.com/?ll=${lat.toString()},${lng.toString()}";
    }
    //TODO:UWP,bingmaps:https://bing.com/maps/default.aspx?cp=47.677797~-122.122013
    try {
      launched = await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } on Exception catch (e) {
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }
}
