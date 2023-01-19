extension StringUtils on String {
  String uppercase() {
    if (length == 0) {
      return "";
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
