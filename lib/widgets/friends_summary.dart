import 'package:flutter/material.dart';
import 'package:geohunter/fonts/rpg_awesome_icons.dart';

//import 'package:logger/logger.dart';

///
import '../models/friends.dart';
import '../screens/friendship/paldetail.dart';
import '../shared/constants.dart';
import '../text_style.dart';

///
class FriendsSummary extends StatelessWidget {
  //final Logger log = Logger(
  //    printer: PrettyPrinter(
  //        colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  final Friend friend;

  ///
  bool hasRaven = false;

  ///
  final bool horizontal;

  ///
  FriendsSummary(this.friend, this.hasRaven, {this.horizontal = true});

  ///
  FriendsSummary.vertical(this.friend) : horizontal = false;

  @override
  Widget build(BuildContext context) {
    final planetCard = Container(
      child: Container(
        margin: EdgeInsets.fromLTRB(
            horizontal ? 56.0 : 16.0, horizontal ? 16.0 : 42.0, 16.0, 16.0),
        constraints: BoxConstraints.expand(),
        child: Column(
          crossAxisAlignment:
              horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              friend.username,
              style: Style.titleTextStyle,
              softWrap: true,
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: horizontal ? 1 : 0,
                  child: Container(
                    child:
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Icon(
                        Icons.school,
                        size: 16,
                        color: Colors.white,
                      ),
                      Text('  Experience: ${friend.xp}',
                          style: Style.averageTextStyle),
                    ]),
                  ),
                ),
                Container(
                  child: (hasRaven == true)
                      ? Icon(RPGAwesome.raven, color: Colors.red, size: 30.0)
                      : Icon(Icons.keyboard_arrow_right,
                          color: Colors.white, size: 30.0),
                  width: 32.0,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.trending_up,
                  size: 16,
                  color: Colors.white,
                ),
                Text(
                  '  Level ${expToLevel(friend.xp)}',
                  style: Style.averageTextStyle,
                ),
              ],
            )
          ],
        ),
      ),
      height: horizontal ? 124.0 : 154.0,
      margin:
          horizontal ? EdgeInsets.only(left: 46.0) : EdgeInsets.only(top: 72.0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(19, 21, 20, 0.8),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 33.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PalDetailPage(friend: friend),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 24.0,
        ),
        child: Stack(
          children: <Widget>[
            planetCard,
            Container(
              margin: EdgeInsets.symmetric(vertical: 16.0),
              alignment: horizontal
                  ? FractionalOffset.centerLeft
                  : FractionalOffset.center,
              child: Hero(
                tag: "planet-hero-${friend.id}",
                child: Container(
                  height: 92,
                  width: 92,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://${GlobalConstants.apiHostUrl}${friend.thumbnail}'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
