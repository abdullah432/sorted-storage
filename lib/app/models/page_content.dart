class PageContent {
  String title;
  String text;
  String imageUri;
  String callToActionButtonText;
  String callToActionButtonRoute;
  Function callToActionCallback;

  PageContent(
      {this.title,
      this.text,
      this.imageUri,
      this.callToActionButtonText,
      this.callToActionButtonRoute,
      this.callToActionCallback});
}
