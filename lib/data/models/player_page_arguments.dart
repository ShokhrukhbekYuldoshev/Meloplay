import 'package:on_audio_query/on_audio_query.dart';

class PlayerPageArguments {
  final List<SongModel> songs;
  final int initialIndex;

  const PlayerPageArguments({
    required this.songs,
    required this.initialIndex,
  });
}
