import 'package:web/ui/widgets/timeline_card.dart';

abstract class AdventureState {
  const AdventureState();
}

class AdventureNewState extends AdventureState{
  final TimelineData data;
  final List<List<String>> uploadingImages;

  AdventureNewState(this.data, this.uploadingImages);
}
class AdventureUploadingState extends AdventureState{
  final List<List<String>> uploadingImages;

  AdventureUploadingState(this.uploadingImages);
}