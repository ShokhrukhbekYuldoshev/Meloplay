extension StringExtension on String {
  /// Capitalize the first letter
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';

  // A function that pluralizes a word based on the provided count. Returns the pluralized form of the word.
  String pluralize(int count) => count == 1 ? this : '${this}s';
}
