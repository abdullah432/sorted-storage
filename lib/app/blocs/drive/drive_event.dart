import 'package:web/app/models/user.dart' as usr;

abstract class DriveEvent {
  const DriveEvent();
}

class InitialDriveEvent extends DriveEvent{
  final usr.User user;
  InitialDriveEvent({this.user});
}