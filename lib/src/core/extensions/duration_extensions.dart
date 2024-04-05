extension DurationExtension on Duration {
  /// Milliseconds to hours, minutes and seconds extension
  String toHms() {
    final String hours = inHours.toString().padLeft(2, '0');
    final String minutes = (inMinutes % 60).toString().padLeft(2, '0');
    final String seconds = (inSeconds % 60).toString().padLeft(2, '0');
    if (hours == '00') {
      return '$minutes:$seconds';
    } else {
      return '$hours:$minutes:$seconds';
    }
  }
}
