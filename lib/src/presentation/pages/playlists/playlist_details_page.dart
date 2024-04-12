import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloplay/src/bloc/playlists/playlists_cubit.dart';
import 'package:meloplay/src/bloc/home/home_bloc.dart';
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
  List<SongModel> _songs = [];

  @override
  void initState() {
    super.initState();
    context.read<PlaylistsCubit>().queryPlaylistSongs(widget.playlist.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // current song, play/pause button, song progress bar, song queue button
      bottomNavigationBar: const PlayerBottomAppBar(),
      extendBody: true,
      appBar: AppBar(
        title: Text(widget.playlist.playlist),
        backgroundColor: Themes.getTheme().primaryColor,
      ),
      body: Ink(
        decoration: BoxDecoration(
          gradient: Themes.getTheme().linearGradient,
        ),
        child: BlocListener<PlaylistsCubit, PlaylistsState>(
          listener: (context, state) {
            if (state is PlaylistsSongsLoaded) {
              setState(() {
                _songs = state.songs;
              });
            }
          },
          child: _songs.isEmpty
              ? const Center(
                  child: Text('No songs added to this playlist'),
                )
              : ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (context, index) {
                    final song = _songs[index];
                    return SongListTile(
                      song: song,
                      songs: _songs,
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            AppRouter.addSongToPlaylistRoute,
            arguments: {
              'playlist': widget.playlist,
              'songs': _songs,
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddSongToPlaylist extends StatefulWidget {
  const AddSongToPlaylist({
    super.key,
    required this.playlist,
    required this.songs,
  });

  final PlaylistModel playlist;
  final List<SongModel> songs;

  @override
  State<AddSongToPlaylist> createState() => _AddSongToPlaylistState();
}

class _AddSongToPlaylistState extends State<AddSongToPlaylist> {
  final List<SongModel> _songs = [];

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(GetSongsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add songs to playlist'),
        backgroundColor: Themes.getTheme().primaryColor,
      ),
      body: Ink(
        decoration: BoxDecoration(
          gradient: Themes.getTheme().linearGradient,
        ),
        child: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is SongsLoaded) {
              setState(() {
                _songs.addAll(state.songs);
              });
            }
          },
          child: ListView.builder(
            itemCount: _songs.length,
            itemBuilder: (context, index) {
              final song = _songs[index];
              return CheckboxListTile(
                title: Text(song.title),
                subtitle: Text(song.artist ?? 'Unknown'),
                value: widget.songs.map((e) => e.data).contains(song.data),
                onChanged: (value) {
                  if (value!) {
                    widget.songs.add(song);
                    context.read<PlaylistsCubit>().addToPlaylist(
                          widget.playlist.id,
                          song,
                        );
                  } else {
                    // TODO: Remove song from playlist
                    // widget.songs.remove(song);
                    // context.read<PlaylistsCubit>().removeFromPlaylist(
                    //       widget.playlist.id,
                    //       song.id,
                    //     );
                  }
                  setState(() {});
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
