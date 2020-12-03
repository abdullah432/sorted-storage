

import 'package:web/app/services/storage_service.dart';
import 'package:web/ui/widgets/timeline_card.dart';

abstract class EventEvent {
  const EventEvent();
}

class SaveEventEvent extends EventEvent{}

class CancelEventEvent extends EventEvent{}


class CommentEventEvent extends EventEvent{
  final TimelineEvent event;
  final String folderID;
  final EventComment comment;
  CommentEventEvent(this.event, this.comment, this.folderID);
}

class DeleteSubEventEvent extends EventEvent{
  final int index;

  DeleteSubEventEvent(this.index);
}

class EventCreateSubEventEvent extends EventEvent{}

class EditTitleEvent extends EventEvent{
  final String folderID;
  final String title;

  EditTitleEvent(this.folderID, this.title);
}

class GetViewEvent extends EventEvent{
  final String folderID;

  GetViewEvent(this.folderID);
}

class EditDescriptionEvent extends EventEvent{
  final String folderID;
  final String description;

  EditDescriptionEvent(this.folderID, this.description);
}


class AddMediaEvent extends EventEvent{
  final String folderID;

  AddMediaEvent(this.folderID);
}

class RemoveImageEvent extends EventEvent{
  final String folderID;
  final String imageKey;

  RemoveImageEvent(this.folderID, this.imageKey);
}

class EditEventEvent extends EventEvent{}

class UpdatedEventEvent extends EventEvent{}