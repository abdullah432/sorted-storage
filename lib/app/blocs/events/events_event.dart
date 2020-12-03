import 'package:web/app/models/user.dart' as usr;
import 'package:web/ui/widgets/timeline_card.dart';

abstract class EventsEvent {
  const EventsEvent();
}

class EventsGetEventsFromFolderEvent extends EventsEvent {
  final String folderId;

  EventsGetEventsFromFolderEvent({this.folderId});
}

class EventsDeleteEventEvent extends EventsEvent {
  final String folderId;

  EventsDeleteEventEvent({this.folderId});
}

class EventsNewEventsEvent extends EventsEvent {}

class EventsCreateNewEventEvent extends EventsEvent {
  final String parentId;
  final int timestamp;
  final bool mainEvent;

  EventsCreateNewEventEvent({this.parentId, this.timestamp, this.mainEvent});
}

class EventsNewUserEvent extends EventsEvent {
  final usr.User user;

  EventsNewUserEvent(this.user);
}
