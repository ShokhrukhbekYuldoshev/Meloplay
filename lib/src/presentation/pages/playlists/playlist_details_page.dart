import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloplay/src/bloc/playlists/playlists_cubit.dart';
import 'package:meloplay/src/core/router/app_router.dart';
import 'package:meloplay/src/presentation/widgets/player_bottom_app_bar.dart';
import 'package:meloplay/src/presentation/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:meloplay/src/core/theme/themes.dart';

class PlaylistDetailsPage extends StatefulWidget {
  final PlaylistModel playlist;
  const PlaylistDetailsPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailsPage> createState() => _PlaylistDetailsPageState();
}

class _PlaylistDetailsPageState extends State<PlaylistDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<PlaylistsCubit>().queryPlaylistSongs(widget.playlist.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const PlayerBottomAppBar(),
      extendBody: true,
      appBar: AppBar(
        title: Text(widget.playlist.playlist),
        backgroundColor: Themes.getTheme().primaryColor,
      ),
      body: Ink(
        decoration: BoxDecoration(gradient: Themes.getTheme().gradient),
        child: BlocBuilder<PlaylistsCubit, PlaylistsState>(
          builder: (context, state) {
            if (state is PlaylistsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PlaylistsSongsLoaded) {
              if (state.songs.isEmpty) {
                return const Center(
                  child: Text('No songs added to this playlist'),
                );
              }

              return ListView.builder(
                itemCount: state.songs.length,
                itemBuilder: (context, index) {
                  final song = state.songs[index];
                  return SongListTile(song: song, songs: state.songs);
                },
              );
            }

            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            AppRouter.addSongsToPlaylistRoute,
            arguments: {'playlist': widget.playlist},
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
