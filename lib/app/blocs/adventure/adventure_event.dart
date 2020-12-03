

import 'package:googleapis/drive/v3.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/ui/widgets/timeline_card.dart';

abstract class AdventureEvent {
  const AdventureEvent();
}

class AdventureNewDriveEvent extends AdventureEvent {
  final DriveApi driveApi;

  AdventureNewDriveEvent(this.driveApi);
}

class AdventureNewTimelineDataEvent extends AdventureEvent {
  final TimelineData cloudCopy;

  AdventureNewTimelineDataEvent(this.cloudCopy);
}

class AdventureInitializeEvent extends AdventureEvent {
  final DriveApi driveApi;

  AdventureInitializeEvent(this.driveApi);
}

class AdventureSaveEvent extends AdventureEvent{}

class AdventureCancelEvent extends AdventureEvent{}
class AdventureCreateSubAdventureEvent extends AdventureEvent{}


class AdventureCommentEvent extends AdventureEvent{
  final TimelineData event;
  final String folderID;
  final AdventureComment comment;
  AdventureCommentEvent(this.event, this.comment, this.folderID);
}

class AdventureDeleteSubAdventureEvent extends AdventureEvent{
  final int index;

  AdventureDeleteSubAdventureEvent(this.index);
}


class AdventureEditTitleEvent extends AdventureEvent{
  final String folderID;
  final String title;

  AdventureEditTitleEvent(this.folderID, this.title);
}


class AdventureEditDescriptionEvent extends AdventureEvent{
  final String folderID;
  final String description;

  AdventureEditDescriptionEvent(this.folderID, this.description);
}

class AdventureGetViewEvent extends AdventureEvent{
  final String folderID;

  AdventureGetViewEvent(this.folderID);
}



class AdventureAddMediaEvent extends AdventureEvent{
  final String folderID;

  AdventureAddMediaEvent(this.folderID);
}

class AdventureRemoveImageEvent extends AdventureEvent{
  final String folderID;
  final String imageKey;

  AdventureRemoveImageEvent(this.folderID, this.imageKey);
}

class AdventureEditEvent extends AdventureEvent{}

class AdventureUpdatedEvent extends AdventureEvent{}