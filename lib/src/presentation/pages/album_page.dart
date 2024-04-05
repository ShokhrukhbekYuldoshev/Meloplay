import 'package:flutter/material.dart';
import 'package:meloplay/src/core/extensions/string_extensions.dart';
import 'package:meloplay/src/core/helpers/helpers.dart';
import 'package:meloplay/src/presentation/widgets/player_bottom_app_bar.dart';
import 'package:meloplay/src/presentation/widgets/song_list_tile.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AlbumPage extends StatefulWidget {
  final AlbumModel album;

  const AlbumPage({super.key, required this.album});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  late List<SongModel> _songs;

  @override
  void initState() {
    super.initState();
    _songs = [];
    _getSongs();
  }

  Future<void> _getSongs() async {
    final OnAudioQuery audioQuery = sl<OnAudioQuery>();

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
      // current song, play/pause button, song progress bar, song queue button
      bottomNavigationBar: const PlayerBottomAppBar(),
      extendBody: true,
      body: Ink(
          decoration: BoxDecoration(
            gradient: Themes.getTheme().linearGradient,
          ),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Themes.getTheme().primaryColor,
                expandedHeight: 400,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isDark = constraints.maxHeight > 100;
                      return Text(
                        widget.album.album,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : calculateTextColor(
                                  Theme.of(context).scaffoldBackgroundColor,
                                ),
                        ),
                      );
                    },
                  ),
                  background: QueryArtworkWidget(
                    artworkBlendMode: BlendMode.darken,
                    artworkColor: Colors.black.withOpacity(0.5),
                    id: widget.album.id,
                    type: ArtworkType.ALBUM,
                    size: 10000,
                    artworkWidth: double.infinity,
                    artworkBorder: BorderRadius.circular(0),
                    nullArtworkWidget: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: const Icon(
                        Icons.music_note_outlined,
                        size: 100,
                      ),
                    ),
                  ),
                ),
              ),

              // number of songs
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text(
                    '${_songs.length} ${'song'.pluralize(_songs.length)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),

              // song list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return SongListTile(
                      song: _songs[index],
                      showAlbumArt: false,
                      songs: _songs,
                    );
                  },
                  childCount: _songs.length,
                ),
              ),

              // margin for bottom app bar
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          )
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     // back button
          //     Row(
          //       children: [
          //         IconButton(
          //           onPressed: () {
          //             Navigator.of(context).pop();
          //           },
          //           icon: const Icon(Icons.arrow_back_ios),
          //         ),
          //       ],
          //     ),
          //     // album artwork
          //     Expanded(
          //       child: QueryArtworkWidget(
          //         id: widget.album.id,
          //         type: ArtworkType.ALBUM,
          //         size: 10000,
          //         artworkWidth: double.infinity,
          //         artworkBorder: BorderRadius.circular(50),
          //         nullArtworkWidget: Container(
          //           width: double.infinity,
          //           decoration: BoxDecoration(
          //             color: Colors.grey.withOpacity(0.1),
          //             borderRadius: BorderRadius.circular(50),
          //           ),
          //           child: const Icon(
          //             Icons.music_note_outlined,
          //             size: 100,
          //           ),
          //         ),
          //       ),
          //     ),
          //     const SizedBox(height: 16),
          //     // album name
          //     Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 16),
          //       child: Text(
          //         widget.album.album,
          //         style: const TextStyle(
          //           fontSize: 24,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ),
          //     // artist name
          //     Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 16),
          //       child: Text(
          //         widget.album.artist ?? 'Unknown',
          //         style: const TextStyle(
          //           fontSize: 18,
          //           color: Colors.grey,
          //         ),
          //       ),
          //     ),
          //     const SizedBox(height: 16),
          //     // songs
          //     Expanded(
          //       child: ListView.builder(
          //         padding: EdgeInsets.zero,
          //         itemCount: _songs.length,
          //         itemBuilder: (context, index) {
          //           final SongModel song = _songs[index];

          //           return SongListTile(
          //             song: song,
          //             songs: _songs,
          //             showAlbumArt: false,
          //           );
          //         },
          //       ),
          //     ),
          //   ],
          // ),
          ),
    );
  }
}
