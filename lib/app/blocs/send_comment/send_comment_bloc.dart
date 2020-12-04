
import 'package:bloc/bloc.dart';
import 'package:web/app/blocs/send_comment/send_comment_event.dart';

class SendCommentBloc extends Bloc<SendCommentEvent, bool> {
  SendCommentBloc() : super(false);

  @override
  Stream<bool> mapEventToState(SendCommentEvent event) async* {
    if (event is SendCommentNewEvent){
      yield true;
    }
    if (event is SendCommentDoneEvent){
      yield false;
    }
  }
}