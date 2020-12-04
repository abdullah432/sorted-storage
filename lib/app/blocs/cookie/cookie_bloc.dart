
import 'package:bloc/bloc.dart';
import 'package:web/app/blocs/cookie/cookie_event.dart';
import 'package:web/app/blocs/sharing/sharing_event.dart';
import 'package:web/app/services/dialog_service.dart';

class CookieBloc extends Bloc<CookieEvent, bool> {
  bool accepted = false;
  bool showing = false;

  CookieBloc() : super(false);

  @override
  Stream<bool> mapEventToState(CookieEvent event) async* {
    if (event is CookieShowEvent){
      if (accepted) {
        return;
      }
      if (showing == false) {
        showing = true;
        Future.delayed(Duration.zero, ()  {
          DialogService.cookieDialog(event.context);
        });
      }
    }
    if (event is CookieAcceptEvent){
      accepted = true;
    }
  }

}