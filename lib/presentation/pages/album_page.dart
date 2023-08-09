import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloplay/data/models/player_page_arguments.dart';
import 'package:meloplay/data/repositories/song_repository.dart';
import 'package:meloplay/presentation/components/song_list_tile.dart';
import 'package:meloplay/presentation/utils/theme/themes.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AlbumPage extends StatefulWidget {
  final AlbumModel album;

  const AlbumPage({Key? key, required this.album}) : super(key: key);

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  late List<SongModel> _songs;
  late final SongRepository songRepository;

  @override
  void initState() {
    super.initState();
    songRepository = context.read<SongRepository>();
    _songs = [];
    _getSongs();
  }

  Future<void> _getSongs() async {
    final OnAudioQuery audioQuery = OnAudioQuery();

    final List<SongModel> songs = await audioQuery.queryAudiosFrom(
      AudiosFromType.ALBUM_ID,
      widget.album.id,
    );

    // remove songs less than 10 seconds long (10,000 milliseconds)
    songs.removeWhere((song) => (song.duration ?? 0) < 10000);

    // await songRepository.addSongsToQueue(songs);
    setState(() {
      _songs = songs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 16,
          24,
          16,
        ),
        decoration: BoxDecoration(
          gradient: Themes.getTheme().linearGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // back button
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                ),
              ],
            ),
            // album artwork
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: QueryArtworkWidget(
                  id: widget.album.id,
                  type: ArtworkType.ALBUM,
                  artworkQuality: FilterQuality.high,
                  nullArtworkWidget: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.music_note_outlined,
                      size: 100,
                    ),
                  ),
                  artworkBorder: BorderRadius.circular(10),
                  artworkWidth: double.infinity,
                  artworkHeight: double.infinity,
                  artworkFit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // album name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.album.album,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // artist name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.album.artist ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // songs
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _songs.length,
                itemBuilder: (context, index) {
                  final SongModel song = _songs[index];
                  final args = PlayerPageArguments(
                    songs: _songs,
                    initialIndex: index,
                  );
                  return SongListTile(
                    song: song,
                    args: args,
                    showAlbumArt: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
