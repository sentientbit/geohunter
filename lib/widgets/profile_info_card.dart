///
import 'package:flutter/material.dart';
import 'package:geohunter/widgets/two_line_item.dart';

///
import '../shared/constants.dart';

///
class ProfileInfoCard extends StatelessWidget {
  ///
  String firstText = "";
  String secondText = "";
  bool hasImage = false;
  String imagePath = "";
  bool hasIcon = false;
  Icon iconResource = Icon(Icons.ac_unit);

  ///
  ProfileInfoCard({
    Key? key,
    required this.firstText,
    required this.secondText,
    required this.hasImage,
    required this.imagePath,
    required this.hasIcon,
    required this.iconResource,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Color(0xaa000000),
        child: Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: hasImage
              ? Image.asset(
                  imagePath,
                  color: GlobalConstants.appBg,
                  width: 25,
                  height: 25,
                )
              : TwoLineItem(
                  firstText: firstText,
                  secondText: secondText,
                  hasIcon: hasIcon,
                  iconResource: iconResource,
                ),
        ),
      ),
    );
  }
}
