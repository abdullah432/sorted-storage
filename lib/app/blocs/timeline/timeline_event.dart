import 'package:googleapis/drive/v3.dart';

abstract class TimelineEvent {
  const TimelineEvent();
}

class TimelineInitilizeEvent extends TimelineEvent {
  final DriveApi driveApi;

  TimelineInitilizeEvent(this.driveApi);
}


class TimelineGetAdventuresFromFolderEvent extends TimelineEvent {
  final String folderId;

  TimelineGetAdventuresFromFolderEvent({this.folderId});
}

class TimelineDeleteAdventureEvent extends TimelineEvent {
  final String folderId;

  TimelineDeleteAdventureEvent({this.folderId});
}

class TimelineUpdatedEvent extends TimelineEvent {}

class TimelineCreateAdventureEvent extends TimelineEvent {
  final String parentId;
  final int timestamp;
  final bool mainEvent;

  TimelineCreateAdventureEvent({this.parentId, this.timestamp, this.mainEvent});
}
