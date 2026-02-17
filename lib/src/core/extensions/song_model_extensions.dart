import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

extension SongModelToMediaItem on SongModel {
  MediaItem toMediaItem() => MediaItem(
    id: id.toString(),
    title: title,
    artist: artist ?? 'Unknown Artist',
    album: album ?? 'Unknown Album',
    genre: genre ?? 'Unknown Genre',
    duration: Duration(milliseconds: duration ?? 0),
    artUri: Uri.parse('content://media/external/audio/albumart/$albumId'),
    extras: {'uri': uri ?? ''},
  );
}
