class PageContent {
  String title;
  String text;
  String imageUri;
  String callToActionButtonText;
  Function callToActionCallback;

  PageContent(
      {this.title,
      this.text,
      this.imageUri,
      this.callToActionButtonText,
      this.callToActionCallback});
}
