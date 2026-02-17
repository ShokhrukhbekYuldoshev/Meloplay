import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/bloc/playlists/playlists_cubit.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AddSongsToPlaylist extends StatefulWidget {
  const AddSongsToPlaylist({super.key, required this.playlist});

  final PlaylistModel playlist;

  @override
  State<AddSongsToPlaylist> createState() => _AddSongToPlaylistState();
}

class _AddSongToPlaylistState extends State<AddSongsToPlaylist> {
  final Set<int> _selectedSongIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add songs to playlist'),
        backgroundColor: Themes.getTheme().primaryColor,
      ),
      body: Ink(
        decoration: BoxDecoration(gradient: Themes.getTheme().gradient),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final songs = state.songs;

            if (songs.isEmpty) {
              return const Center(child: Text("No songs found"));
            }

            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];

                return CheckboxListTile(
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    song.artist ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  value: _selectedSongIds.contains(song.id),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedSongIds.add(song.id);
                        context.read<PlaylistsCubit>().addToPlaylist(
                          widget.playlist.id,
                          song,
                        );
                      } else {
                        _selectedSongIds.remove(song.id);
                        context.read<PlaylistsCubit>().addToPlaylist(
                          widget.playlist.id,
                          song,
                        );
                      }
                    });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
