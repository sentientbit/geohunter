///
import 'package:flutter/material.dart';

///
import '../models/quest.dart';
import '../shared/constants.dart';

///
class QuestCard extends StatelessWidget {
  ///
  final Quest quest;

  ///
  final bool horizontal;

  ///
  QuestCard(this.quest, {this.horizontal = true});

  ///
  QuestCard.vertical(this.quest) : horizontal = false;

  @override
  Widget build(BuildContext context) {
    final planetThumbnail = Container(
      margin:
          EdgeInsets.only(left: 60.0, top: 22), // Change Image margin from left
      alignment:
          horizontal ? FractionalOffset.centerLeft : FractionalOffset.center,
      child: Image(
        image: NetworkImage(
            'https://${GlobalConstants.apiHostUrl}${quest.thumbnail}'),
        height: 76.0,
        width: 76.0,
      ),
    );

    Widget _planetValue({String? value}) {
      return Container(
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text('Is completed: ', style: TextStyle(color: Colors.black)),
          Container(width: 8.0),
          value == "1"
              ? Icon(
                  Icons.done,
                  color: Colors.green,
                )
              : Icon(
                  Icons.error,
                  color: Colors.red,
                )
        ]),
      );
    }

    final planetCardContent = Container(
      margin: EdgeInsets.fromLTRB(146.0, 20.0, 56.0, 16.0),
      constraints: BoxConstraints.expand(),
      child: Column(
        crossAxisAlignment:
            horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            quest.title,
            style: TextStyle(color: Colors.black),
            softWrap: true,
          ),
          Container(height: 10.0),
          Text(quest.quest,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(color: Colors.black)),
          Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              height: 2.0,
              width: 18.0,
              color: Colors.black),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: horizontal ? 1 : 0,
                child: _planetValue(value: quest.status.isCompleted),
              ),
              Container(
                width: horizontal ? 8.0 : 32.0,
              ),
            ],
          ),
        ],
      ),
    );

    final planetCard = Container(
      child: planetCardContent,
      height: 124.0,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/scroll.png'), fit: BoxFit.fill),
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
        horizontal: 10.0,
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
