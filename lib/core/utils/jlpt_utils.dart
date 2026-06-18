int? getJlptRank(String level) {
  final clean = level.trim().toUpperCase();
  if (clean.contains('N5')) return 5;
  if (clean.contains('N4')) return 4;
  if (clean.contains('N3')) return 3;
  if (clean.contains('N2')) return 2;
  if (clean.contains('N1')) return 1;
  return null;
}

bool shouldShowJlpt(String level, String userJlptLevel) {
  if (userJlptLevel == 'none') return true;
  final userRank = getJlptRank(userJlptLevel);
  final itemRank = getJlptRank(level);
  if (userRank == null) return true;
  if (itemRank == null) return true;
  return itemRank <= userRank;
}
