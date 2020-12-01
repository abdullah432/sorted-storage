import 'package:flutter/material.dart';

class NavBarLogo extends StatelessWidget {
  final bool showText;
  const NavBarLogo({Key key, this.showText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (this.showText) {
    children.add(Image.asset(
      "assets/images/logo.png",
    ));
  } else {
      children.add(Image.asset(
        "assets/images/logo_no_text.png",
      ));
    }

    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          child: Row(
            children: children,
          ),
        ),
      ),
    );
  }
}
