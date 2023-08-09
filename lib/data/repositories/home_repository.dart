import 'package:on_audio_query/on_audio_query.dart';

class HomeRepository {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<List<SongModel>> getSongs() async {
    // get all songs
    var songs = await _audioQuery.querySongs();

    // remove songs less than 10 seconds long (10,000 milliseconds)
    songs.removeWhere((song) => (song.duration ?? 0) < 10000);

    return songs;
  }

  Future<List<ArtistModel>> getArtists() async {
    return await _audioQuery.queryArtists();
  }

  Future<List<AlbumModel>> getAlbums() async {
    return await _audioQuery.queryAlbums();
  }

  Future<List<GenreModel>> getGenres() async {
    return await _audioQuery.queryGenres();
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    return await _audioQuery.queryPlaylists();
  }
}
