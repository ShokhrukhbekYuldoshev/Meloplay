// favorites_repository.dart
import 'package:hive_flutter/adapters.dart';
import 'package:meloplay/src/data/services/hive_box.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FavoritesRepository {
  final box = Hive.box('myBox');
  Future<List<SongModel>> fetchFavorites() async {
    List<String> favoriteSongsIds = box.get(
      HiveBox.favoriteSongsKey,
      defaultValue: List<String>.empty(),
    );

    OnAudioQuery audioQuery = sl<OnAudioQuery>();
    List<SongModel> songs = await audioQuery.querySongs(
      uriType: UriType.EXTERNAL,
    );

    return songs
        .where((song) => favoriteSongsIds.contains(song.id.toString()))
        .toList();
  }
}
