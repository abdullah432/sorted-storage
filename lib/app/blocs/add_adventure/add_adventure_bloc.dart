
import 'package:bloc/bloc.dart';
import 'package:web/app/blocs/add_adventure/add_adventure_event.dart';
import 'package:web/app/blocs/cookie/cookie_event.dart';
import 'package:web/app/blocs/sharing/sharing_event.dart';
import 'package:web/app/services/dialog_service.dart';

class AddAdventureBloc extends Bloc<AddAdventureEvent, bool> {
  AddAdventureBloc() : super(false);

  @override
  Stream<bool> mapEventToState(AddAdventureEvent event) async* {
    if (event is AddAdventureNewEvent){
      yield true;
    }
    if (event is AddAdventureDoneEvent){
      yield false;
    }
  }
}