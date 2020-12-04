import 'package:flutter/cupertino.dart';

abstract class CookieEvent {
  const CookieEvent();
}

class CookieShowEvent extends CookieEvent{
  final BuildContext context;

  CookieShowEvent(this.context);
}


class CookieAcceptEvent extends CookieEvent{}