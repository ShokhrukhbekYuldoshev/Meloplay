extension StringExtension on String {
  /// Capitalize the first letter and make the rest of the string lowercase. Returns the capitalized string.
  String capitalize() => length > 0
      ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}'
      : this;

  // A function that pluralizes a word based on the provided count. Returns the pluralized form of the word.
  String pluralize(int count) => count == 1 ? this : '${this}s';
}
