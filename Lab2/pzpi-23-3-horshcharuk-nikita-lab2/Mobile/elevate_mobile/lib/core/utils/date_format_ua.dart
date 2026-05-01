String formatDateUa(DateTime dt) {
  final d = dt.toLocal();
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  final year = d.year.toString().padLeft(4, '0');
  return '$day.$month.$year';
}
