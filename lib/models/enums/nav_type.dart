enum NavType {
  navigationDrawer('抽屉导航栏', 'navigationDrawer'),
  bottomNavigationBar('底部导航栏', 'bottomNavigationBar');

  const NavType(this.label, this.type);
  final String label;
  final String type;
}
