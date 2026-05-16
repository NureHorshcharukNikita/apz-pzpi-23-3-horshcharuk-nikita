dynamic jsonPick(Map<String, dynamic> map, String camelCase, String pascalCase) {
  if (map.containsKey(camelCase)) return map[camelCase];
  if (map.containsKey(pascalCase)) return map[pascalCase];
  return null;
}

int jsonParseInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return fallback;
}

int? jsonParseIntOpt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return null;
}
