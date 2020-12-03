import 'package:web/app/models/user.dart' as usr;
import 'package:web/ui/widgets/timeline_card.dart';

abstract class TimelineEvent {
  const TimelineEvent();
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
