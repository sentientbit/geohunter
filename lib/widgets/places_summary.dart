///
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

///
import '../models/mine.dart';
import '../text_style.dart';

///
class PlanetSummary extends StatelessWidget {
  ///
  final Mine mine;

  ///
  final bool horizontal;

  ///
  PlanetSummary(this.mine, {this.horizontal = true});

  ///
  PlanetSummary.vertical(this.mine) : horizontal = false;

  @override
  Widget build(BuildContext context) {
    final planetThumbnail = Container(
      margin: EdgeInsets.symmetric(vertical: 16.0),
      alignment:
          horizontal ? FractionalOffset.centerLeft : FractionalOffset.center,
      child: Hero(
        tag: "places-hero-${mine.id}",
        child: Image(
          image: AssetImage('assets/images/markers/${mine.properties.ico}.png'),
          height: 100.0,
          width: 92.0,
        ),
      ),
    );

    // Widget _planetValue({String value, String image}) {
    //   return Container(
    //     child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
    //       Image.asset(image, height: 12.0),
    //       Container(width: 7.0),
    //       Text(value, style: Style.smallTextStyle),
    //     ]),
    //   );
    // }

    final planetCardContent = Container(
      margin: EdgeInsets.fromLTRB(
          horizontal ? 46.0 : 6.0, horizontal ? 16.0 : 42.0, 6.0, 1.0),
      constraints: BoxConstraints.expand(),
      child: Column(
        crossAxisAlignment:
            horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            mine.properties.comment,
            style: Style.titleTextStyle,
            softWrap: true,
          ),
          Container(height: 8.0),
          Text(
              '${mine.geometry.coordinates[0]} ${mine.geometry.coordinates[1]}',
              style: Style.commonTextStyle),
          Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              height: 2.0,
              width: 18.0,
              color: Color(0xffe6a04e)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: horizontal ? 1 : 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.av_timer,
                      size: 14,
                      color: Colors.white,
                    ),
                    Container(width: 7.0),
                    Text(
                        DateFormat('dd-MM-yyyy HH:mm')
                            .format(DateTime.parse(mine.lastVisited).toLocal())
                            .toString(),
                        style: Style.smallTextStyle),
                  ],
                ),
              ),
              Container(
                width: horizontal ? 8.0 : 32.0,
              ),
              Expanded(
                flex: horizontal ? 1 : 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.beenhere,
                      size: 14,
                      color: Colors.white,
                    ),
                    Container(width: 7.0),
                    Text(mine.id.toString(), style: Style.smallTextStyle),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );

    final planetCard = Container(
      child: planetCardContent,
      height: horizontal ? 144.0 : 154.0,
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

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 14.0,
      ),
      child: Stack(
        children: <Widget>[
          planetCard,
          planetThumbnail,
        ],
      ),
    );
  }
}
