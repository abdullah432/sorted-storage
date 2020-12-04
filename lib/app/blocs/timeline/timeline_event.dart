import 'package:googleapis/drive/v3.dart';

abstract class TimelineEvent {
  const TimelineEvent();
}

class TimelineInitializeEvent extends TimelineEvent {
  final DriveApi driveApi;

  TimelineInitializeEvent(this.driveApi);
}


class TimelineGetAllEvent extends TimelineEvent{}


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
