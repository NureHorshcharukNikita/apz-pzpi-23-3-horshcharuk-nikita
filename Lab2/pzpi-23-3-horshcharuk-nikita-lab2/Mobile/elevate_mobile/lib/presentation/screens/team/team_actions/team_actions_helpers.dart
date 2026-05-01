String compactActionLevelLabel(String raw) {
  final t = raw.trim();
  final m = RegExp(r'^level\s+(\d+)\s*$', caseSensitive: false).firstMatch(t);
  if (m != null) return m.group(1)!;
  return t;
}
