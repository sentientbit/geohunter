import 'dart:math';

///
import 'dart:ui';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';

///
import '../../app_localizations.dart';
import '../../models/dailyreward.dart';
import '../../models/quest.dart';
import '../../providers/api_provider.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';
import '../../widgets/network_status_message.dart';

///
class QuestLinePage extends StatefulWidget {
  ///
  final String name = 'questline';

  ///
  QuestLinePage({
    Key? key,
  }) : super(key: key);

  @override
  _QuestLinePageState createState() => _QuestLinePageState();
}

class _QuestLinePageState extends State<QuestLinePage> {
  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  final _apiProvider = ApiProvider();

  /// Make sure back button is pressed twice
  bool ifPop = false;

  bool _isLoading = true;

  ///
  bool horizontal = false;

  final _pastRewards = [];

  DailyReward _nextReward = DailyReward.blank();

  ///
  int _elapsedSeconds = 0;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getPastRewards();
    BackButtonInterceptor.add(myInterceptor,
        name: widget.name, context: context);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
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
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(GlobalConstants.backButtonPage);
      }
    }
    return true;
  }

  Widget countDownTimer(CurrentRemainingTime time) {
    var hours = int.tryParse(time.hours.toString()) ?? 0;
    // ignore: omit_local_variable_types
    String hoursString = (hours > 0) ? "${hours.toString()}:" : "00:";
    var minutes = int.tryParse(time.min.toString()) ?? 0;
    // ignore: omit_local_variable_types
    String minutesString =
        (minutes > 0) ? "${minutes.toString().padLeft(2, '0')}:" : "00:";
    var seconds = int.tryParse(time.sec.toString()) ?? 0;
    // ignore: omit_local_variable_types
    String secondsString =
        (seconds > 0) ? "${seconds.toString().padLeft(2, '0')}" : "00";
    return Text(
      "$hoursString$minutesString$secondsString",
      style: TextStyle(
        fontSize: 32,
        color: GlobalConstants.appFg,
      ),
    );
  }

  Widget _makeNextReward(BuildContext context) {
    if (_nextReward == null) {
      return SizedBox(width: 1);
    }

    var blueprintImg = Image(
      image:
          AssetImage('assets/images/blueprints/${_nextReward.blueprint.img}'),
      height: 76.0,
      width: 76.0,
    );

    var materialImg = Image(
      image: AssetImage('assets/images/materials/${_nextReward.material.img}'),
      height: 76.0,
      width: 76.0,
    );

    var itemImg = Image(
      image: AssetImage('assets/images/items/${_nextReward.item.img}'),
      height: 76.0,
      width: 76.0,
    );

    var rn = new Random();
    var hintnr = rn.nextInt(4);
    //ignore: omit_local_variable_types
    String hint = 'Better materials will be needed to forge better weapons.';
    if (hintnr == 1) {
      hint = 'Visit Daily and claim one of the rewards.';
    } else if (hintnr == 2) {
      hint = 'Don\'t wait too long (48h), or the calendar will reset to day 1.';
    } else if (hintnr == 3) {
      hint = 'After the last day all players revert back to day 1.';
    }

    return Card(
      color: Color.fromRGBO(19, 21, 20, 0.7),
      elevation: 8.0,
      margin: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 6.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          //color: Color.fromRGBO(19, 21, 20, 0.7),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 33.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Image(
                          image: AssetImage('assets/images/calendar_day.png'),
                          height: 76.0,
                          width: 76.0,
                        ),
                      ),
                      Positioned(
                        right: 10.0,
                        bottom: 10.0,
                        child: Text(
                          _nextReward.day.toString(),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(width: 1),
                ),
                Expanded(
                  flex: 11,
                  child: Text(
                    hint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        blueprintImg,
                        Text(
                          _nextReward.blueprint.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(width: 1),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        materialImg,
                        Text(
                          _nextReward.material.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(width: 1),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        itemImg,
                        Text(
                          _nextReward.item.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            CountdownTimer(
              endTime: DateTime.now().millisecondsSinceEpoch +
                  (86400 - _elapsedSeconds) * 1000,
              widgetBuilder:
                  (BuildContext context, CurrentRemainingTime? time) {
                if (time != null) {
                  return countDownTimer(time);
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 10),
                            backgroundColor: GlobalConstants.appBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            side: BorderSide(width: 1, color: Colors.white),
                          ),
                          onPressed: () {
                            _dailyReward(
                              _nextReward.day,
                              _nextReward.blueprint.id,
                              0,
                              0,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.check, color: Color(0xffe6a04e)),
                              Text(
                                " Claim",
                                style: TextStyle(
                                  color: Color(0xffe6a04e),
                                  fontSize: 16,
                                  fontFamily: 'Cormorant SC',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(width: 1),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 10),
                            backgroundColor: GlobalConstants.appBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            side: BorderSide(width: 1, color: Colors.white),
                          ),
                          onPressed: () {
                            _dailyReward(
                              _nextReward.day,
                              0,
                              _nextReward.material.id,
                              0,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.check, color: Color(0xffe6a04e)),
                              Text(
                                " Claim",
                                style: TextStyle(
                                  color: Color(0xffe6a04e),
                                  fontSize: 16,
                                  fontFamily: 'Cormorant SC',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(width: 1),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 10),
                            backgroundColor: GlobalConstants.appBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            side: BorderSide(width: 1, color: Colors.white),
                          ),
                          onPressed: () {
                            _dailyReward(
                              _nextReward.day,
                              0,
                              0,
                              _nextReward.item.id,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.check, color: Color(0xffe6a04e)),
                              Text(
                                " Claim",
                                style: TextStyle(
                                  color: Color(0xffe6a04e),
                                  fontSize: 16,
                                  fontFamily: 'Cormorant SC',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _makeCard(BuildContext context, int index) {
    if (_pastRewards.isEmpty) {
      return SizedBox(width: 1);
    }
    return Card(
      color: Color.fromRGBO(19, 21, 20, 0.7),
      elevation: 8.0,
      margin: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 6.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          //color: Color.fromRGBO(19, 21, 20, 0.7),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 33.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: _makeListTile(context, index),
      ),
    );
  }

  Widget _makeListTile(BuildContext context, int index) {
    var netImg = Image(
      image: AssetImage('assets/images/calendar_day.png'),
      height: 76.0,
      width: 76.0,
    );

    var rewardImg = netImg;

    //ignore: omit_local_variable_types
    String grabed = 'Grabed';
    if (_pastRewards[index].blueprintId > 0) {
      grabed = _pastRewards[index].blueprint.name;
      rewardImg = Image(
        image: AssetImage(
            'assets/images/blueprints/${_pastRewards[index].blueprint.img}'),
        height: 76.0,
        width: 76.0,
      );
    } else if (_pastRewards[index].materialId > 0) {
      grabed = _pastRewards[index].material.name;
      rewardImg = Image(
        image: AssetImage(
            'assets/images/materials/${_pastRewards[index].material.img}'),
        height: 76.0,
        width: 76.0,
      );
    } else if (_pastRewards[index].itemId > 0) {
      grabed = _pastRewards[index].item.name;
      rewardImg = Image(
        image:
            AssetImage('assets/images/items/${_pastRewards[index].item.img}'),
        height: 76.0,
        width: 76.0,
      );
    }

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
              child: Text(
                _pastRewards[index].day.toString(),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      title: Text(
        'Reward',
        style: TextStyle(
          color: Color(0xffe6a04e),
          fontFamily: "Cormorant SC",
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10.0),
          Text(grabed, style: Style.averageTextStyle),
          SizedBox(height: 10.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Icon(
                Icons.av_timer,
                size: 14,
                color: Colors.white,
              ),
              Container(width: 7.0),
              Text(
                  DateFormat('dd-MM-yyyy HH:mm')
                      .format(
                          DateTime.parse(_pastRewards[index].date).toLocal())
                      .toString(),
                  style: Style.smallTextStyle),
            ],
          ),
        ],
      ),
      trailing: rewardImg,
      onTap: () {},
    );
  }

  Widget build(BuildContext context) {
    // final deviceSize = MediaQuery.of(context).size;

    /// Application top Bar
    final topBar = AppBar(
      leading: IconButton(
        color: GlobalConstants.appFg,
        icon: Icon(
          Icons.menu,
          // size: 32,
        ),
        onPressed: () => _scaffoldKey != null
            ? _scaffoldKey.currentState?.openDrawer()
            : Navigator.of(context).pop(),
      ),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text(
        "Quests",
        style: Style.topBar,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      //resizeToAvoidBottomPadding: false,
      appBar: topBar,
      //extendBodyBehindAppBar: true,
      body: OfflineBuilder(
        connectivityBuilder: (
          context,
          connectivity,
          child,
        ) {
          if (connectivity == ConnectivityResult.none) {
            return Stack(children: <Widget>[
              child,
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                    color: Colors.black.withOpacity(0),
                    // child: child,
                    child: NetworkStatusMessage()),
              )
            ]);
          } else {
            return child;
          }
        },
        child: LoadingOverlay(
          isLoading: _isLoading,
          opacity: 0.5,
          color: Colors.black,
          progressIndicator: CircularProgressIndicator(
            backgroundColor: Colors.black,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xffe6a04e)),
          ),
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/temple_stairs.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: CustomScrollView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: false,
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Next Reward',
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
                                            color: Color.fromARGB(255, 0, 0, 0))
                                      ],
                                    ),
                                  ),
                                ),
                                _makeNextReward(context),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Past Daily Rewards',
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
                                            color: Color.fromARGB(255, 0, 0, 0))
                                      ],
                                    ),
                                  ),
                                ),
                                for (var i = 0;
                                    i <
                                        ((_pastRewards.length > 5)
                                            ? 5
                                            : _pastRewards.length);
                                    i++)
                                  _makeCard(context, i),
                              ],
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
      key: _scaffoldKey,
      drawer: DrawerPage(),
    );
  }

  void _getPastRewards() async {
    final response = await _apiProvider.get('/dailyrewards');

    var past = [];
    var secs = 0;
    if (response.containsKey("success")) {
      if (response["success"] == true) {
        if (response.containsKey("past_rewards")) {
          for (dynamic elem in response["past_rewards"]) {
            final r = DailyReward.fromJson(elem);
            past.add(r);
          }
        }
        if (response.containsKey("next_reward")) {
          print(response["seconds_elapsed"]);
          setState(() {
            secs = int.tryParse(response["seconds_elapsed"].toString()) ?? 0;
            _nextReward = DailyReward.fromJson(response["next_reward"]);
          });
        }
      }
    }

    setState(() {
      _isLoading = false;
      _elapsedSeconds = secs;
      _pastRewards.clear();
      _pastRewards.addAll(past.toList());
    });
  }

  ///
  Future _dailyReward(
      int day, int blueprintId, int materialId, int itemId) async {
    // print(' --- _dailyReward ---');
    // print(blueprintId);
    // print(materialId);
    // print(itemId);
    dynamic response;
    try {
      response = await _apiProvider.post(
        '/dailyrewards',
        {
          "day": day.toString(),
          "blueprint_id": blueprintId,
          "material_id": materialId,
          "item_id": itemId
        },
      );
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description: 'Daily reward failed ${err.response?.data['message']}',
          buttonText: "Okay",
          images: [],
          callback: () {},
        ),
      );
      return;
    }

    // ignore: omit_local_variable_types
    List<Image> imagesArr = [];

    if (response.containsKey("success")) {
      if (response["success"] == true) {
        if (response["blueprints"].isNotEmpty) {
          for (dynamic value in response["blueprints"]) {
            if (value != null) {
              if (value.containsKey("img") && value["img"] != "") {
                imagesArr.add(
                    Image.asset("assets/images/blueprints/${value['img']}"));
              }
            }
          }
        }
        if (response["materials"].isNotEmpty) {
          for (dynamic value in response["materials"]) {
            if (value != null) {
              if (value.containsKey("img") && value["img"] != "") {
                imagesArr.add(
                    Image.asset("assets/images/materials/${value['img']}"));
              }
            }
          }
        }
        if (response["items"].isNotEmpty) {
          for (dynamic value in response["items"]) {
            if (value != null) {
              if (value.containsKey("img") && value["img"] != "") {
                imagesArr
                    .add(Image.asset("assets/images/items/${value['img']}"));
              }
            }
          }
        }

        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: AppLocalizations.of(context)!.translate('congrats'),
            description: "You grabed a daily reward!",
            buttonText: "Okay",
            images: imagesArr,
            callback: () async {
              _getPastRewards();
              setState(() {
                _isLoading = false;
                _elapsedSeconds = 0;
              });
            },
          ),
        );
      }
    }
    return;
  }
}
