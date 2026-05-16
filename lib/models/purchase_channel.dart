class PurchaseChannel {
  final String appTitle;
  final void Function(String text) onPressed;

  const PurchaseChannel({
    required this.appTitle,
    required this.onPressed,
  });
}
