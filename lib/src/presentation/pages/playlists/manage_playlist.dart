// Simplified AddSongsToPlaylist without complex state management
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/bloc/playlists/playlists_cubit.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/data/models/playlist_model.dart';
import 'package:meloplay/src/presentation/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';

class ManagePlaylist extends StatefulWidget {
  const ManagePlaylist({super.key, required this.playlist});

  final Playlist playlist;

  @override
  State<ManagePlaylist> createState() => _ManagePlaylistState();
}

class _ManagePlaylistState extends State<ManagePlaylist> {
  final Set<int> _selectedSongIds = {};
  final Set<int> _existingSongIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingSongs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingSongs() async {
    setState(() => _isLoading = true);

    // Load existing songs from cubit
    final cubit = context.read<PlaylistsCubit>();
    await cubit.queryPlaylistSongs(widget.playlist.id);

    final state = cubit.state;
    if (state is PlaylistsSongsLoaded) {
      _existingSongIds.clear();
      _selectedSongIds.clear();

      for (var song in state.songs) {
        _existingSongIds.add(song.id);
        _selectedSongIds.add(song.id);
      }
    }

    setState(() => _isLoading = false);
  }

  List<SongModel> _filterSongs(List<SongModel> songs) {
    if (_searchQuery.isEmpty) return songs;

    return songs.where((song) {
      final title = song.title.toLowerCase();
      final artist = (song.artist ?? 'Unknown').toLowerCase();
      final query = _searchQuery.toLowerCase();

      return title.contains(query) || artist.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage: ${widget.playlist.playlist}'),
        backgroundColor: Themes.getTheme().primaryColor,
        actions: [
          TextButton.icon(
            onPressed: _isAllSelected ? _deselectAll : _selectAll,
            icon: Icon(_isAllSelected ? Icons.deselect : Icons.select_all),
            label: Text(_isAllSelected ? 'Deselect All' : 'Select All'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: Themes.getTheme().gradient),
        child: Column(
          children: [
            _buildSearchBar(),
            if (_selectedSongIds.isNotEmpty) _buildSelectedCountBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        if (state.isLoading && state.songs.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state.songs.isEmpty) {
                          return _buildEmptyState();
                        }

                        final filteredSongs = _filterSongs(state.songs);

                        if (filteredSongs.isEmpty) {
                          return _buildNoResultsState();
                        }

                        return ListView.builder(
                          itemCount: filteredSongs.length,
                          padding: const EdgeInsets.only(bottom: 100),
                          itemBuilder: (context, index) {
                            final song = filteredSongs[index];
                            return SongListTile(
                              song: song,
                              isSelected: _selectedSongIds.contains(song.id),
                              key: ValueKey(song.id),
                              isSelectionMode: true,
                              onSelectionChanged: (selected) {
                                setState(() {
                                  if (selected == true) {
                                    _selectedSongIds.add(song.id);
                                  } else {
                                    _selectedSongIds.remove(song.id);
                                  }
                                });
                              },
                              songs: filteredSongs,
                              showAlbumArt: true,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  bool get _isAllSelected {
    final songs = context.read<HomeBloc>().state.songs;
    final filteredSongs = _filterSongs(songs);
    if (filteredSongs.isEmpty) return false;
    return filteredSongs.every((song) => _selectedSongIds.contains(song.id));
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search songs...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSelectedCountBar() {
    final toAdd = _selectedSongIds
        .where((id) => !_existingSongIds.contains(id))
        .length;
    final toRemove = _existingSongIds
        .where((id) => !_selectedSongIds.contains(id))
        .length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline),
          const SizedBox(width: 12),
          Text('Will add: $toAdd • Will remove: $toRemove'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => const Center(child: Text('No songs found'));

  Widget _buildNoResultsState() =>
      Center(child: Text('No results for "$_searchQuery"'));

  Widget _buildBottomBar() {
    final toAdd = _selectedSongIds
        .where((id) => !_existingSongIds.contains(id))
        .length;
    final toRemove = _existingSongIds
        .where((id) => !_selectedSongIds.contains(id))
        .length;
    final hasChanges = toAdd > 0 || toRemove > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Themes.getTheme().primaryColor,
        boxShadow: [BoxShadow(blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: hasChanges ? () => _applyChanges(toAdd, toRemove) : null,
          icon: const Icon(Icons.check),
          label: Text(
            hasChanges ? 'Apply Changes (+$toAdd / -$toRemove)' : 'No Changes',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: hasChanges ? Colors.green : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }

  void _selectAll() {
    final songs = _filterSongs(context.read<HomeBloc>().state.songs);
    setState(() {
      for (var song in songs) {
        _selectedSongIds.add(song.id);
      }
    });
  }

  void _deselectAll() {
    setState(() => _selectedSongIds.clear());
  }

  Future<void> _applyChanges(int toAdd, int toRemove) async {
    final songs = context.read<HomeBloc>().state.songs;
    final cubit = context.read<PlaylistsCubit>();

    // Add songs
    for (var song in songs) {
      if (_selectedSongIds.contains(song.id) &&
          !_existingSongIds.contains(song.id)) {
        await cubit.addToPlaylist(widget.playlist.id, song);
      }
    }

    // Remove songs
    for (var song in songs) {
      if (!_selectedSongIds.contains(song.id) &&
          _existingSongIds.contains(song.id)) {
        await cubit.removeFromPlaylist(widget.playlist.id, song.id);
      }
    }

    if (mounted) {
      Navigator.of(context).pop(true);
      Fluttertoast.showToast(msg: 'Playlist updated!');
    }
  }
}
