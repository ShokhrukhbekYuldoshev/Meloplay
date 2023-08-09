import 'package:flutter/material.dart';
import 'package:meloplay/data/models/player_page_arguments.dart';
import 'package:meloplay/presentation/components/song_list_tile.dart';
import 'package:meloplay/presentation/utils/theme/themes.dart';
import 'package:on_audio_query/on_audio_query.dart';

class ArtistPage extends StatefulWidget {
  final ArtistModel artist;

  const ArtistPage({Key? key, required this.artist}) : super(key: key);

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  late List<SongModel> _songs;

  @override
  void initState() {
    super.initState();
    _songs = [];
    _getSongs();
  }

  Future<void> _getSongs() async {
    final OnAudioQuery audioQuery = OnAudioQuery();

    final List<SongModel> songs = await audioQuery.queryAudiosFrom(
      AudiosFromType.ARTIST_ID,
      widget.artist.id,
    );

    // remove songs less than 10 seconds long (10,000 milliseconds)
    songs.removeWhere((song) => (song.duration ?? 0) < 10000);

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
            // artist image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: QueryArtworkWidget(
                  id: widget.artist.id,
                  type: ArtworkType.ARTIST,
                  artworkQuality: FilterQuality.high,
                  artworkWidth: double.infinity,
                  nullArtworkWidget: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 100,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // artist name
            Text(
              widget.artist.artist,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
                    showArtist: false,
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
