// milliseconds to hours, minutes and seconds extension

extension IntExtension on int {
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

extension DurationExtension on Duration {
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

// capitalize extension
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
