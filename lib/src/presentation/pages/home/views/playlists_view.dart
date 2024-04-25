import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meloplay/src/bloc/playlists/playlists_cubit.dart';
import 'package:meloplay/src/core/extensions/string_extensions.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/core/constants/assets.dart';
import 'package:meloplay/src/core/router/app_router.dart';

class PlaylistsView extends StatefulWidget {
  const PlaylistsView({super.key});

  @override
  State<PlaylistsView> createState() => _PlaylistsViewState();
}

class _PlaylistsViewState extends State<PlaylistsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<PlaylistModel> playlists = [];

  @override
  void initState() {
    super.initState();
    context.read<PlaylistsCubit>().queryPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final cards = [
      const SizedBox(width: 16),
      PlaylistCard(
        image: Assets.heart,
        label: 'Favorites',
        icon: Icons.favorite_border_outlined,
        color: Colors.red,
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.favoritesRoute,
          );
        },
      ),
      const SizedBox(width: 16),
      PlaylistCard(
        image: Assets.earphones,
        label: 'Recents',
        icon: Icons.history_outlined,
        color: const Color(0xFFF321D0),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.recentsRoute,
          );
        },
      ),
      const SizedBox(width: 16),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [...cards],
          ),
          const SizedBox(height: 20),

          // add playlist
          ListTile(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AddPlaylistDialog(
                  playlists: playlists,
                ),
              );
            },
            leading: const Icon(Icons.add),
            title: const Text('Add playlist'),
          ),

          // show playlists
          BlocListener<PlaylistsCubit, PlaylistsState>(
            listener: (context, state) {
              if (state is PlaylistsLoaded) {
                playlists = state.playlists;
              }
              if (state is PlaylistsSongsLoaded) {
                context.read<PlaylistsCubit>().queryPlaylists();
              }
            },
            child: BlocBuilder<PlaylistsCubit, PlaylistsState>(
              buildWhen: (previous, current) => current is PlaylistsLoaded,
              builder: (context, state) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: playlists.length,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.playlistDetailsRoute,
                          arguments: playlist,
                        );
                      },
                      onLongPress: () {
                        // delete playlist
                        showDialog(
                          context: context,
                          builder: (context) => _buildDeletePlaylistDialog(
                            playlist,
                            context,
                          ),
                        );
                      },
                      leading: const Icon(Icons.music_note),
                      title: Text(playlist.playlist),
                      subtitle: Text(
                        '${playlist.numOfSongs} ${'song'.pluralize(playlist.numOfSongs)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  AlertDialog _buildDeletePlaylistDialog(
    PlaylistModel playlist,
    BuildContext context,
  ) {
    return AlertDialog(
      title: const Text('Delete playlist'),
      content: Text('Are you sure you want to delete "${playlist.playlist}"?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            context.read<PlaylistsCubit>().deletePlaylist(playlist.id);
            Navigator.of(context).pop();
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

class PlaylistCard extends StatelessWidget {
  final String image;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const PlaylistCard({
    super.key,
    required this.image,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.grey.withOpacity(0.2),
          child: Column(
            children: [
              Image.asset(
                image,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 4),
                  Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class AddPlaylistDialog extends StatefulWidget {
  const AddPlaylistDialog({super.key, required this.playlists});

  final List<PlaylistModel> playlists;

  @override
  State<AddPlaylistDialog> createState() => _AddPlaylistDialogState();
}

class _AddPlaylistDialogState extends State<AddPlaylistDialog> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add playlist'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Playlist name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Step 1: Gather playlist information
            String playlistName = _controller.text.trim();
            if (playlistName.isEmpty) {
              // return, show an error message if the name is empty
              Fluttertoast.showToast(msg: 'Playlist name cannot be empty');
              return;
            }

            // Step 2: Add playlist
            context.read<PlaylistsCubit>().createPlaylist(playlistName);

            // Step 3: Close dialog
            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
