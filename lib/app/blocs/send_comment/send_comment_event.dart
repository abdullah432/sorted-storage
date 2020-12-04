

abstract class SendCommentEvent {
  const SendCommentEvent();
}

class SendCommentNewEvent extends SendCommentEvent{}

class SendCommentDoneEvent extends SendCommentEvent{}

