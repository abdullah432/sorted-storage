
import 'package:bloc/bloc.dart';
import 'package:web/app/blocs/update_adventure/update_advanture_state.dart';
import 'package:web/app/blocs/update_adventure/update_adventure_event.dart';

class UpdateAdventureBloc extends Bloc<UpdateAdventureEvent, UpdateAdventureState> {
  UpdateAdventureBloc() : super(UpdateAdventureDoneState());

  @override
  Stream<UpdateAdventureState> mapEventToState(UpdateAdventureEvent event) async* {
    if (event is UpdateAdventureSaveEvent){
      yield UpdateAdventureSaveState();
    }
    if (event is UpdateAdventureDeleteEvent){
      yield UpdateAdventureDeleteState();
    }
    if (event is UpdateAdventureDoneEvent){
      yield UpdateAdventureDoneState();
    }
  }
}