import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/data/models/search_result.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SearchRepository {
  final _audioQuery = sl<OnAudioQuery>();

  Future<SearchResultModel> search(String query) async {
    final List<dynamic> songs = await _audioQuery.queryWithFilters(
      query,
      WithFiltersType.AUDIOS,
    );

    final List<dynamic> albums = await _audioQuery.queryWithFilters(
      query,
      WithFiltersType.ALBUMS,
    );

    final List<dynamic> artists = await _audioQuery.queryWithFilters(
      query,
      WithFiltersType.ARTISTS,
    );

    final List<dynamic> genres = await _audioQuery.queryWithFilters(
      query,
      WithFiltersType.GENRES,
    );

    return SearchResultModel(
      songs: songs.map((e) => SongModel(e)).toList(),
      albums: albums.map((e) => AlbumModel(e)).toList(),
      artists: artists.map((e) => ArtistModel(e)).toList(),
      genres: genres.map((e) => GenreModel(e)).toList(),
    );
  }
}
