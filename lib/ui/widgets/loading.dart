import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:web/ui/theme/theme.dart';

class FullPageLoadingLogo extends StatelessWidget {
  final Color backgroundColor;

  const FullPageLoadingLogo({Key key, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Decoration decoration = backgroundColor != null
        ? BoxDecoration(color: backgroundColor)
        : myBackgroundDecoration;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: decoration,
        child: StaticLoadingLogo(),
      ),
    );
  }
}

class StaticLoadingLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      color: myThemeData.primaryColorDark,
      size: 50.0,
    );
  }
}
