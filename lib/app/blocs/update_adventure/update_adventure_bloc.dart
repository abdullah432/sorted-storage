
import 'package:bloc/bloc.dart';
import 'package:web/app/blocs/update_adventure/update_adventure_event.dart';

class UpdateAdventureBloc extends Bloc<UpdateAdventureEvent, bool> {
  UpdateAdventureBloc() : super(false);

  @override
  Stream<bool> mapEventToState(UpdateAdventureEvent event) async* {
    if (event is UpdateAdventureSaveEvent){
      yield true;
    }
    if (event is UpdateAdventureDoneEvent){
      yield false;
    }
  }
}