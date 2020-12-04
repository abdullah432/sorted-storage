import 'package:googleapis/drive/v3.dart';

abstract class ImagesEvent {
  const ImagesEvent();
}

class ImagesGetEvent extends ImagesEvent{
  final String imageURL;

  ImagesGetEvent(this.imageURL);
}


class ImagesUpdateDriveEvent extends ImagesEvent{
  final DriveApi driveApi;

  ImagesUpdateDriveEvent(this.driveApi);
}

