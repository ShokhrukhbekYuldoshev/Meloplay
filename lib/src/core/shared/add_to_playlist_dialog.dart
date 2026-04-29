// lib/src/core/shared/add_to_playlist_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meloplay/src/features/playlists/bloc/playlists/playlists_cubit.dart';
import 'package:meloplay/src/features/playlists/data/models/playlist_model.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AddToPlaylistDialog extends StatefulWidget {
  final SongModel song;

  const AddToPlaylistDialog({super.key, required this.song});

  @override
  State<AddToPlaylistDialog> createState() => _AddToPlaylistDialogState();
}

class _AddToPlaylistDialogState extends State<AddToPlaylistDialog> {
  bool _isCreatingNew = false;
  final TextEditingController _newPlaylistController = TextEditingController();
  List<Playlist> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  @override
  void dispose() {
    _newPlaylistController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaylists() async {
    final cubit = context.read<PlaylistsCubit>();
    await cubit.queryPlaylists();

    final state = cubit.state;
    if (state is PlaylistsLoaded) {
      setState(() {
        _playlists = state.playlists;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addToPlaylist(Playlist playlist) async {
    final cubit = context.read<PlaylistsCubit>();
    await cubit.addToPlaylist(playlist.id, widget.song);

    if (mounted) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Added to "${playlist.playlist}"',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _createAndAddToPlaylist() async {
    final playlistName = _newPlaylistController.text.trim();
    if (playlistName.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter a playlist name',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final cubit = context.read<PlaylistsCubit>();
    await cubit.createPlaylist(playlistName);

    // Wait for creation and reload
    await Future.delayed(const Duration(milliseconds: 100));
    await _loadPlaylists();

    // Find the newly created playlist
    final newPlaylist = _playlists.firstWhere(
      (p) => p.playlist == playlistName,
      orElse: () => _playlists.first,
    );

    await _addToPlaylist(newPlaylist);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.playlist_add,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add to Playlist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Toggle between existing and new playlist
            Row(
              children: [
                _buildToggleButton(
                  label: 'Existing',
                  icon: Icons.playlist_play,
                  isSelected: !_isCreatingNew,
                  onTap: () => setState(() => _isCreatingNew = false),
                ),
                const SizedBox(width: 12),
                _buildToggleButton(
                  label: 'New',
                  icon: Icons.add,
                  isSelected: _isCreatingNew,
                  onTap: () => setState(() => _isCreatingNew = true),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Content based on mode
            if (_isCreatingNew)
              _buildNewPlaylistForm()
            else
              _buildPlaylistList(),

            const SizedBox(height: 16),

            // Close button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_playlists.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.playlist_play_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            const Text('No playlists yet', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isCreatingNew = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create First Playlist'),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _playlists.length,
        itemBuilder: (context, index) {
          final playlist = _playlists[index];
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.playlist_play,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              playlist.playlist,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${playlist.numOfSongs} songs',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            onTap: () => _addToPlaylist(playlist),
          );
        },
      ),
    );
  }

  Widget _buildNewPlaylistForm() {
    return Column(
      children: [
        TextField(
          controller: _newPlaylistController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Playlist name',
            prefixIcon: const Icon(Icons.playlist_add),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onSubmitted: (_) => _createAndAddToPlaylist(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _createAndAddToPlaylist,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Create & Add'),
          ),
        ),
      ],
    );
  }
}
