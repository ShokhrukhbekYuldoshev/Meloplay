import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lottie/lottie.dart';
import 'package:meloplay/src/core/extensions/int_extensions.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:meloplay/src/bloc/player/player_bloc.dart';
import 'package:meloplay/src/core/constants/assets.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/core/helpers/helpers.dart';
import 'package:meloplay/src/core/helpers/show_player_sheet.dart';
import 'package:meloplay/src/data/services/music_player.dart';

class SongListTile extends StatefulWidget {
  final SongModel song;
  final List<SongModel> songs;
  final bool showAlbumArt;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectionChanged;

  const SongListTile({
    super.key,
    required this.song,
    required this.songs,
    this.showAlbumArt = true,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
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
        trailing: _buildTrailing(context),
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

  Widget _buildTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'play_next':
                _addToQueueNext();
                break;
              case 'add_to_queue':
                _addToQueueEnd();
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
            const PopupMenuDivider(),
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
        ),
      ],
    );
  }

  void _addToQueueNext() {
    // TODO: Implement add to queue next
    Fluttertoast.showToast(
      msg: 'Added to queue: ${widget.song.title}',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _addToQueueEnd() {
    // TODO: Implement add to queue end
    Fluttertoast.showToast(
      msg: 'Added to queue: ${widget.song.title}',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _showAddToPlaylistDialog() {
    // TODO: Implement add to playlist dialog
    Fluttertoast.showToast(
      msg: 'Add to playlist feature coming soon',
      backgroundColor: Colors.orange,
      textColor: Colors.white,
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
                Navigator.of(context).pop();
                await _deleteSong();
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

  Future<void> _deleteSong() async {
    final file = File(widget.song.data);

    if (!await file.exists()) {
      Fluttertoast.showToast(
        msg: 'File not found',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // Request permission for Android 13+
    if (Platform.isAndroid) {
      final androidInfo = await getAndroidVersion();
      if (androidInfo >= 33) {
        final status = await Permission.audio.request();
        if (!status.isGranted) {
          Fluttertoast.showToast(
            msg: 'Permission denied to delete audio files',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return;
        }
      } else if (androidInfo >= 30) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          Fluttertoast.showToast(
            msg: 'Storage permission required',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return;
        }
      } else {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          Fluttertoast.showToast(
            msg: 'Storage permission required',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return;
        }
      }
    }

    try {
      await file.delete();

      // Refresh the media store
      final onAudioQuery = OnAudioQuery();
      await onAudioQuery.scanMedia(widget.song.data);

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Deleted: ${widget.song.title}',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Trigger refresh in parent
        context.read<PlayerBloc>().add(const PlayerRefreshSongs());
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to delete song',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
