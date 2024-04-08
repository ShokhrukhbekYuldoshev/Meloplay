extension ListExtension<T> on List<T> {
  void swap(int first, int second) {
    if (first < length && second < length) {
      var temp = this[first];
      this[first] = this[second];
      this[second] = temp;
    }
  }
}
