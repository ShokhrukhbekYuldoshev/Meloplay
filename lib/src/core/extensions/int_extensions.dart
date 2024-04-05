extension IntExtension on int {
  /// Milliseconds to hours, minutes and seconds extension
  String toHms() {
    final Duration duration = Duration(milliseconds: this);
    final String hours = duration.inHours.toString().padLeft(2, '0');
    final String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    if (hours == '00') {
      return '$minutes:$seconds';
    } else {
      return '$hours:$minutes:$seconds';
    }
  }
}
