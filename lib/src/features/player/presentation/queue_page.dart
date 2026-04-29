import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/core/shared/player_bottom_app_bar.dart';
import 'package:meloplay/src/core/theme/theme_colors.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/core/services/music_player.dart';
import 'package:meloplay/src/core/shared/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  final MusicPlayer _player = sl<MusicPlayer>();
  int? _currentPlayingIndex;
  List<SongModel> _playlist = [];

  @override
  void initState() {
    super.initState();
    _playlist = _player.playlist;

    // Listen to current index changes
    _player.currentIndex.listen((index) {
      if (mounted) {
        setState(() {
          _currentPlayingIndex = index;
        });
      }
    });

    // Listen to playlist changes
    _player.queueStream.listen((playlist) {
      if (mounted) {
        setState(() {
          _playlist = playlist;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const PlayerBottomAppBar(),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Themes.getTheme().primaryColor,
        elevation: 0,
        title: const Text('Play Queue'),
        centerTitle: false,
        actions: [
          if (_playlist.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _showClearQueueDialog,
              tooltip: 'Clear queue',
            ),
        ],
      ),
      body: Ink(
        decoration: BoxDecoration(gradient: Themes.getTheme().gradient),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_playlist.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Up next section header
        if (_playlist.length > 1 && _currentPlayingIndex != null)
          _buildUpNextHeader(),

        // Reorderable playlist using SongListTile
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            physics: const BouncingScrollPhysics(),
            onReorder: _onReorder,
            itemCount: _playlist.length,
            itemBuilder: (context, index) {
              final song = _playlist[index];

              return Container(
                key: ValueKey(song.id),

                child: SongListTile(
                  song: song,
                  songs: _playlist,
                  showAlbumArt: true,
                  isQueueMode: true,
                  removeFromQueue: () => _removeFromQueue(index, song.title),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpNextHeader() {
    final upcomingCount = _playlist.length - (_currentPlayingIndex ?? 0) - 1;

    if (upcomingCount <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ThemeColors.surfaceColor(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'UP NEXT ($upcomingCount)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: ThemeColors.iconColor(context),
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
            Icons.queue_music_outlined,
            size: 80,
            color: ThemeColors.iconColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Queue is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: ThemeColors.textColor(context).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add songs to the queue',
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.textColor(context).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    _player.moveInQueue(oldIndex, newIndex);
  }

  void _removeFromQueue(int index, String songTitle) {
    _player.removeFromQueue(index);
    Fluttertoast.showToast(
      msg: 'Removed: $songTitle',
      backgroundColor: Colors.grey.shade800,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showClearQueueDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Queue'),
        content: const Text(
          'This will remove all songs from the queue and stop playback.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _player.clearQueue();
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Queue cleared',
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
