// this is the state the user is expected to see
class NavigationState {
  final NavigationItem selectedItem;
  const NavigationState(this.selectedItem);
}
// helpful navigation pages, you can change
// them to support your pages
enum NavigationItem {
  home_page,
  login_page,
  media_page,
  documents_page,
  policy_page,
  terms_page,
  error_page
}