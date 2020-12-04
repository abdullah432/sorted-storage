

abstract class UpdateAdventureEvent {
  const UpdateAdventureEvent();
}

class UpdateAdventureSaveEvent extends UpdateAdventureEvent{}

class UpdateAdventureDoneEvent extends UpdateAdventureEvent{}

