abstract class ShareEvent {
  const ShareEvent();
}

class InitialEvent extends ShareEvent{}
class StartSharingEvent extends ShareEvent{}
class StopSharingEvent extends ShareEvent{}