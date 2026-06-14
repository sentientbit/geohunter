///
import 'package:flutter/material.dart';

///
import '../shared/app_theme.dart';
import '../shared/constants.dart';

///
class ItemsGrid extends StatelessWidget {
  ///
  final List<Image> images;

  ///
  ItemsGrid({
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GridView(
        // if you want IOS bouncing effect, otherwise remove this line
        physics: BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        children: images.map(
          (img) {
            return Card(
              child: img,
              color: Color.fromRGBO(19, 21, 20, 0.9),
            );
          },
        ).toList(),
      ),
    );
  }
}

///
class CustomDialog extends StatelessWidget {
  ///
  final String title;

  ///
  final String description;

  ///
  final String buttonText;

  ///
  final List<Image> images;

  ///
  final VoidCallback callback;

  ///
  CustomDialog({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.images,
    required this.callback,
  });

  ///
  dynamic dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 0,
            ),
            child: Container(
              padding: EdgeInsets.only(
                top: GlobalConstants.avatarRadius + GlobalConstants.padding,
                bottom: GlobalConstants.padding,
                left: GlobalConstants.padding,
                right: GlobalConstants.padding,
              ),
              margin: EdgeInsets.only(top: GlobalConstants.avatarRadius),
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(GlobalConstants.padding),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // To make the card compact
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  if (images.isNotEmpty) ...[
                    SizedBox(height: 24.0),
                    SizedBox(
                      width: 200.0,
                      height: 200.0,
                      child: ItemsGrid(images: images),
                    ),
                  ],
                  SizedBox(height: 24.0),
                  kStoneButton(
                    onTap: () {
                      Navigator.of(context).pop();
                      callback();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.check, color: kGold),
                        const SizedBox(width: 6),
                        Text(
                          buttonText,
                          style: const TextStyle(
                            color: kGold,
                            fontSize: 16,
                            fontFamily: 'Cormorant SC',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: GlobalConstants.padding,
          right: GlobalConstants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: GlobalConstants.avatarRadius,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GlobalConstants.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}
