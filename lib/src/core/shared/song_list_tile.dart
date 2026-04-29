import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lottie/lottie.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/core/constants/assets.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/core/extensions/int_extensions.dart';
import 'package:meloplay/src/core/helpers/helpers.dart';
import 'package:meloplay/src/core/helpers/show_player_sheet.dart';
import 'package:meloplay/src/core/services/music_player.dart';
import 'package:meloplay/src/core/shared/add_to_playlist_dialog.dart';
import 'package:meloplay/src/features/player/bloc/player/player_bloc.dart';

class SongListTile extends StatefulWidget {
  final SongModel song;
  final List<SongModel> songs;
  final bool showAlbumArt;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectionChanged;

  // For queue
  final bool isQueueMode;
  final VoidCallback? removeFromQueue;

  const SongListTile({
    super.key,
    required this.song,
    required this.songs,
    this.showAlbumArt = true,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
    this.isQueueMode = false,
    this.removeFromQueue,
  });

  @override
  State<SongListTile> createState() => _SongListTileState();
}

class _SongListTileState extends State<SongListTile> {
  final player = sl<MusicPlayer>();

  @override
  Widget build(BuildContext context) {
    if (widget.isSelectionMode) {
      return _buildSelectionTile();
    }

    return StreamBuilder<SequenceState?>(
      key: ValueKey(widget.song.id),
      stream: player.sequenceState,
      builder: (context, snapshot) {
        MediaItem? currentMediaItem;
        if (snapshot.hasData) {
          var sequence = snapshot.data;
          currentMediaItem = sequence!.currentSource?.tag as MediaItem?;
        }

        return _buildNormalTile(currentMediaItem);
      },
    );
  }

  Widget _buildNormalTile(MediaItem? currentMediaItem) {
    final isPlaying = currentMediaItem?.id == widget.song.id.toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isPlaying
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.03),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: () async {
          MediaItem mediaItem = player.getMediaItemFromSong(widget.song);

          if (currentMediaItem?.id == mediaItem.id) {
            if (context.mounted) {
              showPlayerSheet(context);
            }
          } else {
            context.read<PlayerBloc>().add(
              PlayerLoadPlaylist(mediaItem: mediaItem, playlist: widget.songs),
            );
          }
        },
        leading: widget.showAlbumArt ? _buildLeading(currentMediaItem) : null,
        title: _buildTitle(currentMediaItem, context),
        subtitle: _buildSubtitle(),
        trailing: _buildTrailing(context, isPlaying),
        dense: true,
      ),
    );
  }

  Widget _buildSelectionTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: widget.isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.03),
        border: widget.isSelected
            ? Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: CheckboxListTile(
        value: widget.isSelected,
        onChanged: widget.onSelectionChanged,
        secondary: widget.showAlbumArt ? _buildSelectionArtwork() : null,
        title: Text(
          widget.song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          widget.song.artist ?? 'Unknown',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        activeColor: Theme.of(context).colorScheme.primary,
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  Widget _buildSelectionArtwork() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: QueryArtworkWidget(
        keepOldArtwork: true,
        id: widget.song.albumId ?? 0,
        type: ArtworkType.ALBUM,
        size: 100,
        nullArtworkWidget: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          child: Icon(
            Icons.music_note,
            size: 20,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget? _buildLeading(MediaItem? currentMediaItem) {
    final isPlaying = currentMediaItem?.id == widget.song.id.toString();

    return Stack(
      children: [
        QueryArtworkWidget(
          keepOldArtwork: true,
          id: widget.song.albumId ?? 0,
          type: ArtworkType.ALBUM,
          size: 100,

          nullArtworkWidget: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.grey.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.music_note,
              size: 20,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
        if (isPlaying)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.black.withValues(alpha: 0.5),
              ),
              child: Center(
                child: StreamBuilder<bool>(
                  stream: player.playing,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isPlaying
                          ? ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.primary,
                                BlendMode.srcIn,
                              ),
                              child: Lottie.asset(
                                Assets.playingAnimation,
                                animate: true,
                                height: 28,
                                width: 28,
                              ),
                            )
                          : Icon(
                              Icons.play_arrow,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(MediaItem? currentMediaItem, BuildContext context) {
    final isPlaying = currentMediaItem?.id == widget.song.id.toString();

    return Text(
      widget.song.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
        color: isPlaying ? Theme.of(context).colorScheme.primary : null,
        fontSize: 14,
      ),
    );
  }

  Widget _buildSubtitle() {
    final artist = widget.song.artist ?? 'Unknown';

    // duration
    final duration = widget.song.duration ?? 0;
    var subtitle = '$artist • ${duration.toHms()}';
    return Text(
      subtitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, bool isPlaying) {
    // If in queue mode, show reorder and remove button
    if (widget.isQueueMode) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            color: Theme.of(context).colorScheme.primary,
            onPressed: widget.removeFromQueue,
          ),
          const SizedBox(width: 8),
          Icon(Icons.drag_handle, color: Theme.of(context).colorScheme.primary),
        ],
      );
    }

    // Original popup menu for normal mode
    if (widget.isSelectionMode) {
      return Checkbox(
        value: widget.isSelected,
        onChanged: widget.onSelectionChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      );
    }
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'play_next':
            _addToQueueNext();
            break;
          case 'add_to_queue':
            _addToQueue();
            break;
          case 'add_to_playlist':
            _showAddToPlaylistDialog();
            break;
          case 'delete':
            _showDeleteConfirmationDialog();
            break;
          case 'share':
            shareSong(context, widget.song.data, widget.song.title);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'play_next',
          child: Row(
            children: [
              Icon(Icons.playlist_play, size: 20),
              SizedBox(width: 12),
              Text('Play next'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'add_to_queue',
          child: Row(
            children: [
              Icon(Icons.queue_music, size: 20),
              SizedBox(width: 12),
              Text('Add to queue'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'add_to_playlist',
          child: Row(
            children: [
              Icon(Icons.playlist_add, size: 20),
              SizedBox(width: 12),
              Text('Add to playlist'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share, size: 20),
              SizedBox(width: 12),
              Text('Share'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _addToQueue() {
    final player = sl<MusicPlayer>();
    player.addToQueue(widget.song);
  }

  void _addToQueueNext() {
    final player = sl<MusicPlayer>();
    player.addToQueueNext(widget.song);
  }

  void _showAddToPlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AddToPlaylistDialog(song: widget.song),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete Song'),
          content: Text(
            'Are you sure you want to delete "${widget.song.title}"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // TODO : implement delete song
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
