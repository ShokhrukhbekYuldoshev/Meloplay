import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/core/extensions/string_extensions.dart';
import 'package:meloplay/src/core/helpers/helpers.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/presentation/widgets/player_bottom_app_bar.dart';
import 'package:meloplay/src/presentation/widgets/song_list_tile.dart';

class ArtistPage extends StatefulWidget {
  final ArtistModel artist;

  const ArtistPage({super.key, required this.artist});

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
    final OnAudioQuery audioQuery = sl<OnAudioQuery>();

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
                collapseMode: CollapseMode.parallax,
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isLarge = constraints.maxHeight > 100;
                    bool isLong = widget.artist.artist.length > 20;

                    if (isLarge) {
                      return Text(
                        widget.artist.artist,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      );
                    } else if (!isLong) {
                      return Text(
                        widget.artist.artist,
                        style: TextStyle(
                          color: calculateTextColor(
                            Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      );
                    } else {
                      return Marquee(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        text: widget.artist.artist,
                        style: TextStyle(
                          color: calculateTextColor(
                            Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        blankSpace: 100,
                        pauseAfterRound: const Duration(seconds: 1),
                      );
                    }
                  },
                ),
                background: QueryArtworkWidget(
                  artworkBlendMode: BlendMode.darken,
                  artworkColor: Colors.black.withOpacity(0.5),
                  id: widget.artist.id,
                  type: ArtworkType.ARTIST,
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
                      Icons.person_outlined,
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
                    songs: _songs,
                  );
                },
                childCount: _songs.length,
              ),
            ),

            // margin for bottom app bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}
