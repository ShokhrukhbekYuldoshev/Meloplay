import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:meloplay/src/bloc/playlists/playlists_cubit.dart';
import 'package:meloplay/src/core/constants/assets.dart';
import 'package:meloplay/src/core/extensions/string_extensions.dart';
import 'package:meloplay/src/core/router/app_router.dart';
import 'package:meloplay/src/data/models/playlist_model.dart';

class PlaylistsView extends StatefulWidget {
  const PlaylistsView({super.key});

  @override
  State<PlaylistsView> createState() => _PlaylistsViewState();
}

class _PlaylistsViewState extends State<PlaylistsView>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  List<Playlist> playlists = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPlaylists();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _loadPlaylists();
    }
  }

  void _loadPlaylists() {
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
        gradientColors: [Colors.red.shade900, Colors.red.shade700],
        onTap: () {
          Navigator.of(context).pushNamed(AppRouter.favoritesRoute);
        },
      ),
      const SizedBox(width: 16),
      PlaylistCard(
        image: Assets.earphones,
        label: 'Recents',
        icon: Icons.history_outlined,
        color: Colors.orange,
        gradientColors: [Colors.orange.shade900, Colors.orange.shade700],
        onTap: () {
          Navigator.of(context).pushNamed(AppRouter.recentsRoute);
        },
      ),
      const SizedBox(width: 16),
    ];

    return RefreshIndicator(
      onRefresh: () async {
        _loadPlaylists();
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            /// Featured Playlists Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Featured',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: cards),
            const SizedBox(height: 24),

            /// My Playlists Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Playlists',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _showAddPlaylistDialog();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            /// Playlists List
            BlocConsumer<PlaylistsCubit, PlaylistsState>(
              listener: (context, state) {
                if (state is PlaylistsLoaded) {
                  setState(() {
                    playlists = state.playlists;
                  });
                }
                if (state is PlaylistsError) {
                  Fluttertoast.showToast(
                    msg: state.message,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
                if (state is PlaylistDeleted) {
                  Fluttertoast.showToast(
                    msg: 'Playlist deleted successfully',
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                  _loadPlaylists(); // Reload after delete
                }
                if (state is PlaylistUpdated) {
                  // Refresh when songs are added/removed from any playlist
                  _loadPlaylists();
                }
              },
              builder: (context, state) {
                if (state is PlaylistsLoading && playlists.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (playlists.isEmpty && state is! PlaylistsLoading) {
                  return _buildEmptyPlaylists(context);
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: playlists.length,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return _buildPlaylistTile(playlist);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaylists(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.playlist_play_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No playlists yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first playlist',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistTile(Playlist playlist) {
    return Dismissible(
      key: Key(playlist.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
              context: context,
              builder: (context) =>
                  _buildDeletePlaylistDialog(playlist, context),
            ) ??
            false;
      },
      onDismissed: (direction) {
        playlists.removeWhere((p) => p.id == playlist.id);
        context.read<PlaylistsCubit>().deletePlaylist(playlist.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 0,
        color: Colors.white.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: () async {
            // Navigate to playlist details and wait for result
            final result = await Navigator.of(
              context,
            ).pushNamed(AppRouter.playlistDetailsRoute, arguments: playlist);

            // Refresh if changes were made (songs added/removed)
            if (result == true) {
              _loadPlaylists();
            }
          },
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
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
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            playlist.playlist,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${playlist.numOfSongs} ${'song'.pluralize(playlist.numOfSongs)}',
          ),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddPlaylistDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddPlaylistDialog(),
    );

    if (result == true) {
      _loadPlaylists(); // Refresh after creating new playlist
    }
  }

  AlertDialog _buildDeletePlaylistDialog(
    Playlist playlist,
    BuildContext context,
  ) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete playlist'),
      content: Text('Are you sure you want to delete "${playlist.playlist}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Delete'),
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
  final List<Color>? gradientColors;

  const PlaylistCard({
    super.key,
    required this.image,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Background image with overlay
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.3),
                    BlendMode.darken,
                  ),
                  child: Image.asset(
                    image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient overlay
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                // Content
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddPlaylistDialog extends StatefulWidget {
  const AddPlaylistDialog({super.key});

  @override
  State<AddPlaylistDialog> createState() => _AddPlaylistDialogState();
}

class _AddPlaylistDialogState extends State<AddPlaylistDialog> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCreating = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            Icons.playlist_add,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Create Playlist'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          enabled: !_isCreating,
          decoration: InputDecoration(
            hintText: 'Enter playlist name',
            prefixIcon: const Icon(Icons.playlist_play),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Playlist name cannot be empty';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isCreating = true);
                    final playlistName = _controller.text.trim();
                    await context.read<PlaylistsCubit>().createPlaylist(
                      playlistName,
                    );
                    setState(() => _isCreating = false);

                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                      Fluttertoast.showToast(
                        msg: 'Playlist "$playlistName" created',
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isCreating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
