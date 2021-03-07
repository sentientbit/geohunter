///
import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:mapbox_gl/mapbox_gl.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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

///
class Debouncer {
  ///
  final int milliseconds;

  ///
  VoidCallback action;
  Timer _timer;

  ///
  Debouncer({this.milliseconds});

  ///
  void run(VoidCallback action) {
    if (_timer != null) {
      _timer.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

final _debouncer = Debouncer(milliseconds: 500);

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
  ///
  String _mapStyle = '';
  String _mapStyleAubergine = '';

  MapController mapController = MapController();
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

  bool _infoWindowVisible = false;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _textFieldController = TextEditingController();
  bool _isOnline = true;
  bool _commentIsEmpty = false;
  bool _showAddPin = false;
  bool _recenterBtnPressed = false;
  bool _showRecenterBtn = false;

  Timer timer;
  Color _customAppBarTextColor = Colors.black;
  Color _customAppBarIconColor = Colors.black;
  Brightness _systemHeaderBrightness = Brightness.light;
  final _pois = [];

  final _apiProvider = ApiProvider();
  //int _screenRebuilded = 1;
  final List<File> _images = [];
  final List<String> _thumbnails = [];
  final _storage = FlutterSecureStorage();

  Mine _mine;
  int _mineIdx = 0;
  int _mineId = 0;
  String _mineUid;

  /// Curent loggedin user
  User _user;

  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Future _loadPois(LtLn location) async {
    //print("--- Loading pois ---");
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
      await _storage.write(key: 'swLng', value: swLng.toString());
      await _storage.write(key: 'swLat', value: swLat.toString());
      await _storage.write(key: 'neLng', value: neLng.toString());
      await _storage.write(key: 'neLat', value: neLat.toString());
      await _storage.write(key: 'mapZoom', value: _mapZoom.toString());

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
        if (err.type == DioErrorType.CONNECT_TIMEOUT) {
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
          if (response.containsKey("geojson")) {
            if (response["geojson"]["features"] != null) {
              for (dynamic elem in response["geojson"]["features"]) {
                final mine = Mine(elem, 1, location: _userLocation);
                features.add(mine);
              }
            }
          }
          if (response.containsKey("players")) {
            if (response["geojson"]["players"] != null) {
              for (dynamic elem in response["players"]["features"]) {
                final mine = Mine(elem, 2, location: _userLocation);
                players.add(mine);
              }
            }
          }
        }
      }

      setState(() {
        _pois.clear();
        _pois.addAll(features.toList());
        _pois.addAll(players.toList());
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

  String distanceInMeters(meters) {
    print(meters);
    final showDistanceIn = meters > 1000
        ? '${(meters / 1000).toStringAsFixed(2)}km'
        : '${meters.toStringAsFixed(2)}m';
    return showDistanceIn;
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
    print('selectPoint');
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
    //print('--- widget.latitude ---');
    //print(widget.latitude);
    //print('--- widget.longitude ---');
    //print(widget.longitude);

    if (widget.goToRemoteLocation) {
      _showRecenterBtn = true;
      _moveCameraToLocation(widget.latitude, widget.longitude);
      _loadPois(LtLn(widget.latitude, widget.longitude));
      widget.goToRemoteLocation = false;
    } else {
      _showRecenterBtn = false;
      await _loadPois(location);
    }

    var datenow = DateTime.now();
    //var datenow = DateTime.parse("2020-05-30 15:18:04Z");
    //print('--- dayAndNight ---'); print(datenow);

    final astroResult =
        SunCalc.getTimes(datenow, location.latitude, location.longitude);
    //print(_mapStyleState);
    if (_mapStyleState == 0 /* day */) {
      //mapController.setMapStyle
      setState(() => {
            _customAppBarTextColor = Colors.black,
            _customAppBarIconColor = Colors.black,
            _systemHeaderBrightness = Brightness.light,
          });
    } else if (_mapStyleState == 1 /* night */) {
      //mapController.setMapStyle
      setState(() => {
            _customAppBarTextColor = Colors.white,
            _customAppBarIconColor = Colors.white,
            _systemHeaderBrightness = Brightness.dark
          });
    } else if (_mapStyleState == 2 /* auto */) {
      if (SunCalc.isDaytime(datenow, astroResult.sunrise, astroResult.sunset)) {
        /// Day
        setState(() => {
              _customAppBarTextColor = Colors.black,
              _customAppBarIconColor = Colors.black,
              _systemHeaderBrightness = Brightness.light,
            });
      } else {
        /// Night
        setState(() => {
              _customAppBarTextColor = Colors.white,
              _customAppBarIconColor = Colors.white,
              _systemHeaderBrightness = Brightness.dark
            });
      }
    }
  }

  // LatLngBounds boundsFromLatLngList(LatLng latLng) {
  //   double x0, x1, y0, y1;
  //   if (x0 == null) {
  //     x0 = x1 = latLng.latitude;
  //     y0 = y1 = latLng.longitude;
  //   } else {
  //     if (latLng.latitude > x1) x1 = latLng.latitude;
  //     if (latLng.latitude < x0) x0 = latLng.latitude;
  //     if (latLng.longitude > y1) y1 = latLng.longitude;
  //     if (latLng.longitude < y0) y0 = latLng.longitude;
  //   }

  //   return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  // }

  Widget popupTitle() {
    var dots = ".";
    dots = dots * _pinsToBeAdded.length;
    if (_mineId > 0) {
      return Text(
        "Point $_mineId",
        style: TextStyle(
          color: GlobalConstants.appFg,
          fontFamily: 'Cormorant SC',
        ),
      );
    }
    return Text(
      "Add New Point $dots",
      style: TextStyle(
        color: GlobalConstants.appFg,
        fontFamily: 'Cormorant SC',
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
      _showAddPin = true;
    });
  }

  Widget _myCustomPopup() {
    return AlertDialog(
      backgroundColor: GlobalConstants.appBg,
      title: popupTitle(),
      content: SizedBox(
        //height: _images.length > 0 ? 300 : 100,
        child: SingleChildScrollView(
          child: Column(
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
                          RaisedButton(
                            shape: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onPressed: _takePhoto,
                            padding: EdgeInsets.all(10),
                            color: Colors.black,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.camera_alt,
                                    color: Color(0xffe6a04e)),
                                Text(
                                  " Camera",
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
                          RaisedButton(
                            shape: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onPressed: _loadFromGallery,
                            padding: EdgeInsets.all(10),
                            color: Colors.black,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.photo, color: Color(0xffe6a04e)),
                                Text(
                                  " Gallery",
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
                              padding: EdgeInsets.all(10),
                              backgroundColor: GlobalConstants.appBg,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              side: BorderSide(width: 1, color: Colors.white),
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
                                  " Directions",
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
                          RaisedButton(
                            shape: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onPressed: _clearFromGallery,
                            padding: EdgeInsets.all(10),
                            color: Colors.black,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.delete, color: Color(0xffe6a04e)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Distance ${distanceInMeters(_pois[_mineIdx].distanceToPoint)}",
                    style: TextStyle(color: GlobalConstants.appFg),
                  ),
                ],
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
        ),
      ),
      actions: <Widget>[
        Text(
          "User $_mineUid",
          style: TextStyle(color: Colors.grey.shade800),
        ),
        RaisedButton(
          shape: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: () {
            selectPoint(0, 0, _userLocation, "");
            setState(() {
              _showAddPin = false;
              _textFieldController.text = "";
              _images.clear();
            });
          },
          padding: EdgeInsets.all(10),
          color: Colors.black,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.close, color: Color(0xffe6a04e)),
                Text(
                  " Cancel",
                  style: TextStyle(
                      color: Color(0xffe6a04e),
                      fontSize: 18,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold),
                ),
              ]),
        ),
        RaisedButton(
          shape: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.circular(10),
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
                _showAddPin = false;
              });
              _savePin();
              return;
            }
          },
          padding: EdgeInsets.all(10),
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.check, color: Color(0xffe6a04e)),
              Text(
                " Save",
                style: TextStyle(
                    color: Color(0xffe6a04e),
                    fontSize: 18,
                    fontFamily: 'Cormorant SC',
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )
      ],
    );
  }

  ///
  Widget build(BuildContext context) {
    // Determining the screen width & height
    var szHeight = MediaQuery.of(context).size.height;
    var szWidth = MediaQuery.of(context).size.width;

    // The marker generation function
    Marker _createMarker(context, int idx, Mine mine) {
      var icoVar = int.parse(mine.properties.ico);
      final now =
          DateTime.parse(DateTime.now().toUtc().toIso8601String()).toLocal();
      if (mine.lastVisited != "" && mine.lastVisited != null) {
        icoVar =
            now.difference(DateTime.parse(mine.lastVisited)).inSeconds < 3600
                ? 0
                : int.parse(mine.properties.ico);
      }

      // return Marker(
      //   markerId: MarkerId(mine.id.toString()),
      //   position:
      //       LatLng(mine.geometry.coordinates[1], mine.geometry.coordinates[0]),
      //   onTap: () => {
      //     _onClickMarker(idx, mine),
      //   },
      //   infoWindow: _generatorInfoMarker(idx, mine.properties, mine.category,
      //       mine.distanceToPoint, mine.geometry),
      //   icon: _markerIcons.length > 1
      //       ? _markerIcons[icoVar]
      //       : BitmapDescriptor.defaultMarker,
      // );

      return Marker(
          point: LatLng(
              mine.geometry.coordinates[1], mine.geometry.coordinates[0]),
          builder: (BuildContext ctx) {
            return GestureDetector(
              onTap: () {
                _onClickMarker(idx, mine);
                _onAddPinButtonPressed();
              },
              child: Stack(
                children: <Widget>[
                  Opacity(
                    opacity: _infoWindowVisible ? 1.0 : 0.0,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      width: 279.0,
                      height: 256.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image:
                                AssetImage("assets/images/ic_info_window.png"),
                            fit: BoxFit.cover),
                      ),
                      child: Text('1234'),
                    ),
                  ),
                  Opacity(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        "assets/images/markers/${icoVar.toString()}.png",
                        width: 200,
                        height: 266,
                      ),
                    ),
                    opacity: _infoWindowVisible ? 0.0 : 1.0,
                  ),
                ],
              ),
            );
          });
    }

    final mapWidget = FlutterMap(
      options: MapOptions(
        center: widget.goToRemoteLocation
            ? LatLng(widget.latitude, widget.longitude)
            : LatLng(_userLocation.latitude, _userLocation.longitude),
        zoom: _mapZoom,
        onPositionChanged: (mapPosition, boolValue) => {
          _debouncer.run(() => {
                if (_recenterBtnPressed)
                  {
                    setState(() {
                      _showRecenterBtn = false;
                      _recenterBtnPressed = false;
                    })
                  }
                else
                  {
                    setState(() {
                      _showRecenterBtn = true;
                    })
                  },
                setState(() {
                  _displayWindowCenter = mapPosition.center;
                  _mapZoom = mapPosition.zoom;
                }),
                _loadPois(_userLocation)
              })
        },
      ),
      layers: [
        TileLayerOptions(
          // Free
          //urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          //subdomains: ['a', 'b', 'c'],
          // MapBox
          urlTemplate: "https://api.mapbox.com/styles/v1/"
              "{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
          additionalOptions: {
            'accessToken': GlobalConstants.mapboxToken,
            'id': 'mapbox/outdoors-v11',
          },
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
    // GoogleMap(
    //   onMapCreated: (controller) {
    //     mapController = controller;
    //     dayAndNight(_userLatitude, _userLongitude);
    //   },
    //   mapType: MapType.normal,
    //   markers: Set<Marker>.of(
    //     _pois.asMap().entries.map(
    //           (entry) => _createMarker(context, entry.key, entry.value),
    //         ),
    //   ),
    //   minMaxZoomPreference:
    //       MinMaxZoomPreference(9 /* far away */, 18 /* close up */),
    //   mapToolbarEnabled: true,
    //   compassEnabled: false,
    //   myLocationButtonEnabled: false,
    //   myLocationEnabled: true,
    //   rotateGesturesEnabled: true,
    //   scrollGesturesEnabled: true,
    //   tiltGesturesEnabled: true,
    //   onCameraMoveStarted: () => {
    //     if (_recenterBtnPressed)
    //       {
    //         setState(() {
    //           _showRecenterBtn = false;
    //           _recenterBtnPressed = false;
    //         })
    //       }
    //     else
    //       {
    //         setState(() {
    //           _showRecenterBtn = true;
    //         })
    //       }
    //   },
    //   onCameraMove: (object) => {
    //     _debouncer.run(() => {
    //           setState(() {
    //             _displayWindowCenter =
    //                 LtLn(object.target.latitude, object.target.longitude);
    //             _mapZoom = object.zoom;
    //           }),
    //           _loadPois(_userLatitude, _userLongitude)
    //         })
    //   },
    //   onTap: (latlng) => selectPoint(0, 0, latlng, ""),
    //   initialCameraPosition: CameraPosition(
    //     target: widget.goToRemoteLocation
    //         ? LatLng(widget.latitude, widget.longitude)
    //         : LatLng(_userLatitude, _userLongitude),
    //     tilt: 50.0,
    //     zoom: 14,
    //   ),
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
                  systemHeaderBrightness: _systemHeaderBrightness)),
          // Container(
          //   margin: EdgeInsets.only(top: 25),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: <Widget>[
          //       Text(
          //         "Lat: ${_userLocation.latitude} Lng: ${_userLocation.longitude}",
          //         style: TextStyle(
          //           color: GlobalConstants.appFg,
          //           fontFamily: 'Cormorant SC',
          //           fontSize: 20,
          //           shadows: <Shadow>[
          //             Shadow(
          //                 offset: Offset(1.0, 1.0),
          //                 blurRadius: 3.0,
          //                 color: Color.fromARGB(255, 0, 0, 0))
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          if (_showAddPin == true) _myCustomPopup(),
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
          CachedNetworkImage(
              imageUrl: "https://${GlobalConstants.apiHostUrl}$thumb"),
        );
        list.add(SizedBox(width: 10));
      }
    }
    print(" ${_pois[_mineIdx].properties.ico}");
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
    print(' --- _loadMines --- ');
    if (mines != null) {
      setState(() {
        _pois.clear();
        _pois.addAll(mines.toList());
      });
    }
  }

  void _updateUserLocation(LtLn location) async {
    print('---  _updateUserLocation map explore ---');
    print(location.latitude);
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
      latitude: _userLocation.latitude,
      longitude: _userLocation.longitude,
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

      //print('before _modifyPin');
      //print(_mineUid);
      //print(_user.details.id);

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
        "lat": pin.latitude,
        "lng": pin.longitude,
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

  // void _onMapChanged() {
  //   setState(() {
  //     _extractMapInfo();
  //   });
  // }

  // void onMapCreated(MapboxMapController controller) {
  //   mapController = controller;
  //   mapController.addListener(_onMapChanged);
  //   _extractMapInfo();
  //   dayAndNight(_userLocation);
  //   setState(() {});
  // }

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
        LatLng(_userLocation.latitude, _userLocation.longitude),
        _mapZoom,
      );
      // ignore: lines_longer_than_80_chars
      //mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(latitude, longitude),tilt: 50.0,bearing: 0.0,zoom: _mapZoom)));
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
