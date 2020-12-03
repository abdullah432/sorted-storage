abstract class ImagesEvent {
  const ImagesEvent();
}

class GetImagesEvent extends ImagesEvent{
  final String imageURL;

  GetImagesEvent(this.imageURL);

}