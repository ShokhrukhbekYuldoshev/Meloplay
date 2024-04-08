import 'package:on_audio_query/on_audio_query.dart';

class SearchResultModel {
  final List<SongModel> songs;
  final List<ArtistModel> artists;
  final List<AlbumModel> albums;
  final List<GenreModel> genres;

  SearchResultModel({
    required this.songs,
    required this.artists,
    required this.albums,
    required this.genres,
  });
}
