enum AppScreen {
  notifications(0),
  home(1),
  profile(2),
  settings(3),
  myItems(4),
  barcode(5),
  addItem(6),
  community(7),
  analytics(8),
  history(9),
  shoppingList(10);

  const AppScreen(this.value);
  final int value;

  //FOR bottom navigation bar
  bool get showsBottomBar {
    return this == notifications ||
        this == home ||
        this == profile ||
        this == settings ||
        this == community ||
        this == analytics ||
        this == history ||
        this == shoppingList;
  }

  int get bottomBarIndex {
    if (value >= 7 && value <= 10) {
      return AppScreen.home.value;
    }
    return value;
  }
}
