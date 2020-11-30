import 'dart:async';

class WaterService {
  static waitUntilThen(bool test(), Function callback()){
    _waitUntil(() => test(),
        Duration(milliseconds: 100)).then((value) => callback());
  }

  static Future _waitUntil(bool test(), [Duration pollInterval = Duration.zero]) {
    var completer = new Completer();
    check() {
      if (test()) {
        completer.complete();
      } else {
        new Timer(pollInterval, check);
      }
    }

    check();
    return completer.future;
  }
}
