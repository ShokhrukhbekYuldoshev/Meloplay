// recents_repository.dart
import 'package:hive_flutter/adapters.dart';
import 'package:meloplay/src/data/services/hive_box.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

class RecentsRepository {
  final box = Hive.box('myBox');

  Future<List<SongModel>> fetchRecents() async {
    List<String> recentSongsIds = box.get(
      HiveBox.recentlyPlayedSongsKey,
      defaultValue: List<String>.empty(),
    );

    OnAudioQuery audioQuery = sl<OnAudioQuery>();
    List<SongModel> songs = await audioQuery.querySongs(
      uriType: UriType.EXTERNAL,
    );

    // sort songs by recent songs ids
    songs.sort((a, b) => recentSongsIds
        .indexOf(a.id.toString())
        .compareTo(recentSongsIds.indexOf(b.id.toString())));

    return songs
        .where((song) => recentSongsIds.contains(song.id.toString()))
        .toList();
  }
}
