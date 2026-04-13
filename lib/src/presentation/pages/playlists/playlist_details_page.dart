import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meloplay/src/bloc/player/player_bloc.dart';
import 'package:meloplay/src/core/extensions/song_model_extensions.dart';
import 'package:meloplay/src/data/models/playlist_model.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/bloc/playlists/playlists_cubit.dart';
import 'package:meloplay/src/core/router/app_router.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/presentation/widgets/player_bottom_app_bar.dart';
import 'package:meloplay/src/presentation/widgets/song_list_tile.dart';

class PlaylistDetailsPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailsPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailsPage> createState() => _PlaylistDetailsPageState();
}

class _PlaylistDetailsPageState extends State<PlaylistDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Reset the cubit state when entering this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlaylistsCubit>().queryPlaylistSongs(widget.playlist.id);
      }
    });
  }

  var songs = <SongModel>[];
  var playlistName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const PlayerBottomAppBar(),
      extendBody: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(gradient: Themes.getTheme().gradient),
        child: BlocListener<PlaylistsCubit, PlaylistsState>(
          listener: (context, state) {
            if (state is PlaylistsSongsLoaded) {
              songs = state.songs;
            }
          },
          child: BlocBuilder<PlaylistsCubit, PlaylistsState>(
            builder: (context, state) {
              // Handle loading state
              if (state is PlaylistsLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading playlist...'),
                    ],
                  ),
                );
              }

              // Handle error state
              if (state is PlaylistsError) {
                return _buildErrorState(state.message);
              }

              // Handle loaded state

              if (songs.isEmpty) {
                return _buildEmptyState();
              }

              return Column(
                children: [
                  _buildHeader(songs),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<PlaylistsCubit>().queryPlaylistSongs(
                          widget.playlist.id,
                        );
                      },
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: songs.length,
                        padding: const EdgeInsets.only(bottom: 20),
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return SongListTile(
                            song: song,
                            songs: songs,
                            showAlbumArt: true,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddSongs,
        icon: const Icon(Icons.add),
        label: const Text('Add songs'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        playlistName.isNotEmpty ? playlistName : widget.playlist.playlist,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Themes.getTheme().primaryColor,
      centerTitle: false,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () => _playAllSongs(),
          tooltip: 'Play all',
        ),
        IconButton(
          icon: const Icon(Icons.shuffle),
          onPressed: () => _shufflePlaylist(),
          tooltip: 'Shuffle',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'rename':
                _showRenameDialog();
                break;
              case 'delete':
                _showDeletePlaylistDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 12),
                  Text('Rename'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Delete playlist', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(List<SongModel> songs) {
    // Calculate total duration
    final totalDuration = songs.fold<Duration>(
      Duration.zero,
      (sum, song) => sum + Duration(milliseconds: song.duration ?? 0),
    );

    final minutes = totalDuration.inMinutes;
    final hours = totalDuration.inHours;

    String durationText = '';
    if (hours > 0) {
      durationText = '$hours hr ${minutes.remainder(60)} min';
    } else {
      durationText = '$minutes min';
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Playlist icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.playlist_play,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${songs.length} ${songs.length == 1 ? 'song' : 'songs'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  durationText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // Play button
          ElevatedButton.icon(
            onPressed: () => _playAllSongs(),
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Play'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_play_outlined,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No songs in this playlist',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add songs',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<PlaylistsCubit>().queryPlaylistSongs(
                widget.playlist.id,
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddSongs() {
    Navigator.of(context)
        .pushNamed(
          AppRouter.managePlaylistRoute,
          arguments: {'playlist': widget.playlist},
        )
        .then((result) {
          if (result == true && mounted) {
            // Refresh playlist songs
            context.read<PlaylistsCubit>().queryPlaylistSongs(
              widget.playlist.id,
            );
            // Return true to parent
            Navigator.of(context).pop(true);
          }
        });
  }

  void _playAllSongs() {
    final state = context.read<PlaylistsCubit>().state;
    if (state is PlaylistsSongsLoaded && state.songs.isNotEmpty) {
      context.read<PlayerBloc>().add(PlayerSetShuffle(false));
      context.read<PlayerBloc>().add(
        PlayerLoadPlaylist(
          mediaItem: state.songs.first.toMediaItem(),
          playlist: state.songs,
        ),
      );
    }
  }

  void _shufflePlaylist() {
    final state = context.read<PlaylistsCubit>().state;
    if (state is PlaylistsSongsLoaded && state.songs.isNotEmpty) {
      final randomIndex = Random().nextInt(state.songs.length);

      context.read<PlayerBloc>().add(PlayerSetShuffle(true));
      context.read<PlayerBloc>().add(
        PlayerLoadPlaylist(
          mediaItem: state.songs[randomIndex].toMediaItem(),
          playlist: state.songs,
        ),
      );
    }
  }

  void _showRenameDialog() {
    final controller = TextEditingController(
      text: playlistName.isNotEmpty ? playlistName : widget.playlist.playlist,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rename playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != widget.playlist.playlist) {
                context.read<PlaylistsCubit>().renamePlaylist(
                  widget.playlist.id,
                  newName,
                );

                // Update playlist name
                setState(() {
                  playlistName = newName;
                });

                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: 'Playlist renamed to "$newName"',
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                );
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeletePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete playlist'),
        content: Text('Delete "${widget.playlist.playlist}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PlaylistsCubit>().deletePlaylist(widget.playlist.id);
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous page
              Fluttertoast.showToast(
                msg: 'Playlist deleted',
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
