import 'dart:math';

///
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';

///
import '../../app_localizations.dart';
import '../../models/app_error.dart';
import '../../models/dailyreward.dart';
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../providers/daily_rewards_provider.dart';
import '../../providers/user_provider.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';
import '../../widgets/network_status_message.dart';

///
class QuestLinePage extends ConsumerStatefulWidget {
  ///
  final String name = 'questline';

  ///
  QuestLinePage({
    Key? key,
  }) : super(key: key);

  @override
  _QuestLinePageState createState() => _QuestLinePageState();
}

class _QuestLinePageState extends ConsumerState<QuestLinePage> {
  final _apiProvider = ApiProvider();

  /// True only while a claim action is in flight.
  bool _isClaiming = false;

  ///
  bool horizontal = false;

  final _storage = FlutterSecureStorage();

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Refresh daily rewards and user profile every time this screen opens.
    // This ensures the badge and countdown reflect server state even when
    // the player claimed their reward on the web portal between app sessions.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(dailyRewardsProvider);
      ref.invalidate(userProvider);
    });
  }

  @override
  void dispose() {
    super.dispose();
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

  Widget _makeNextReward(BuildContext context, DailyReward nextReward,
      int secondsElapsed) {
    var blueprintImg = Image(
      image:
          AssetImage('assets/images/blueprints/${nextReward.blueprint.img}'),
      height: 76.0,
      width: 76.0,
    );

    var materialImg = Image(
      image: AssetImage('assets/images/materials/${nextReward.material.img}'),
      height: 76.0,
      width: 76.0,
    );

    var itemImg = Image(
      image: AssetImage('assets/images/items/${nextReward.item.img}'),
      height: 76.0,
      width: 76.0,
    );

    var rn = Random();
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
                          nextReward.day.toString(),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      blueprintImg,
                      Text(
                        nextReward.blueprint.name,
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
                Expanded(
                  flex: 1,
                  child: SizedBox(width: 1),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      materialImg,
                      Text(
                        nextReward.material.name,
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
                Expanded(
                  flex: 1,
                  child: SizedBox(width: 1),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      itemImg,
                      Text(
                        nextReward.item.name,
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
              ],
            ),
            CountdownTimer(
              endTime: DateTime.now().millisecondsSinceEpoch +
                  (GlobalConstants.dailyGiftFreq - secondsElapsed) * 1000,
              widgetBuilder: (context, time) {
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
                              nextReward.day,
                              nextReward.blueprint.id,
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
                              nextReward.day,
                              0,
                              nextReward.material.id,
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
                              nextReward.day,
                              0,
                              0,
                              nextReward.item.id,
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

  Widget _makeCard(BuildContext context, DailyReward reward) {
    return Card(
      color: Color.fromRGBO(19, 21, 20, 0.7),
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
        child: _makeListTile(context, reward),
      ),
    );
  }

  Widget _makeListTile(BuildContext context, DailyReward reward) {
    var netImg = Image(
      image: AssetImage('assets/images/calendar_day.png'),
      height: 76.0,
      width: 76.0,
    );

    var rewardImg = netImg;

    //ignore: omit_local_variable_types
    String grabed = 'Grabed';
    if (reward.blueprintId > 0) {
      grabed = reward.blueprint.name;
      rewardImg = Image(
        image: AssetImage(
            'assets/images/blueprints/${reward.blueprint.img}'),
        height: 76.0,
        width: 76.0,
      );
    } else if (reward.materialId > 0) {
      grabed = reward.material.name;
      rewardImg = Image(
        image: AssetImage(
            'assets/images/materials/${reward.material.img}'),
        height: 76.0,
        width: 76.0,
      );
    } else if (reward.itemId > 0) {
      grabed = reward.item.name;
      rewardImg = Image(
        image: AssetImage('assets/images/items/${reward.item.img}'),
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
                reward.day.toString(),
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
                      .format(DateTime.parse(reward.date).toLocal())
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
    final rewardsState = ref.watch(dailyRewardsProvider);
    final user = ref.watch(userProvider).valueOrNull ?? User.blank();

    final rewards = rewardsState.valueOrNull;
    final pastRewards = rewards?.pastRewards ?? [];
    final nextReward = rewards?.nextReward ?? DailyReward.blank();
    final secondsElapsed = rewards?.secondsElapsed ?? 0;

    final isLoading = rewardsState.isLoading || _isClaiming;

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
            AppLocalizations.of(context)!.translate('drawer_rewards'),
            style: Style.topBar,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ],
        ),
        body: OfflineBuilder(
          connectivityBuilder: (
            context,
            connectivity,
            child,
          ) {
            if (connectivity.isEmpty ||
                connectivity.contains(ConnectivityResult.none)) {
              return Stack(children: <Widget>[
                child,
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                      color: Colors.black.withValues(alpha: 0),
                      child: NetworkStatusMessage()),
                )
              ]);
            } else {
              return child;
            }
          },
          child: LoadingOverlay(
            isLoading: isLoading,
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
                                            color: Color.fromARGB(
                                                255, 0, 0, 0))
                                      ],
                                    ),
                                  ),
                                ),
                                _makeNextReward(
                                    context, nextReward, secondsElapsed),
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
                                            color: Color.fromARGB(
                                                255, 0, 0, 0))
                                      ],
                                    ),
                                  ),
                                ),
                                for (final reward in pastRewards.take(5))
                                  _makeCard(context, reward),
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
          ),
        ),
        key: _scaffoldKey,
        drawer: DrawerPage(),
      ),
    );
  }

  ///
  Future _dailyReward(
      int day, int blueprintId, int materialId, int itemId) async {
    setState(() => _isClaiming = true);
    try {
      final response = await _apiProvider.post(
        '/dailyrewards/$day/$blueprintId/$materialId/$itemId',
        {},
      );

      // Build the images list from returned blueprints/materials/items
      final List<Image> imagesArr = [];
      for (dynamic value in (response["blueprints"] ?? [])) {
        if (value?.containsKey("img") == true && value["img"] != "") {
          imagesArr.add(Image.asset("assets/images/blueprints/${value['img']}"));
        }
      }
      for (dynamic value in (response["materials"] ?? [])) {
        if (value?.containsKey("img") == true && value["img"] != "") {
          imagesArr.add(Image.asset("assets/images/materials/${value['img']}"));
        }
      }
      for (dynamic value in (response["items"] ?? [])) {
        if (value?.containsKey("img") == true && value["img"] != "") {
          imagesArr.add(Image.asset("assets/images/items/${value['img']}"));
        }
      }

      await _storage.delete(key: "dailyrewardsIds");

      // Refresh both feature data and user state
      ref.invalidate(dailyRewardsProvider);
      ref.invalidate(userProvider);

      if (!mounted) return;
      setState(() => _isClaiming = false);
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: AppLocalizations.of(context)!.translate('congrats'),
          description: "You grabed a daily reward!",
          buttonText: "Okay",
          images: imagesArr,
          callback: () {},
        ),
      );
    } on AppError catch (err) {
      if (!mounted) return;
      setState(() => _isClaiming = false);
      err.show(context, title: 'Daily Reward');
    } catch (err) {
      debugPrint('_dailyReward unexpected error: $err');
      if (mounted) setState(() => _isClaiming = false);
    }
  }
}
