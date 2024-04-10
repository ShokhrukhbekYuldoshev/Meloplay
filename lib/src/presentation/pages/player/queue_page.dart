import 'package:flutter/material.dart';

import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/data/repositories/player_repository.dart';
import 'package:meloplay/src/presentation/widgets/song_list_tile.dart';

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Themes.getTheme().primaryColor,
        elevation: 0,
        title: const Text('Queue'),
      ),
      body: Ink(
        decoration: BoxDecoration(
          gradient: Themes.getTheme().linearGradient,
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final playlist = sl<JustAudioPlayer>().playlist;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: playlist.length,
      itemBuilder: (context, index) {
        return SongListTile(
          song: playlist[index],
          songs: playlist,
          key: ValueKey(playlist[index].id),
        );
      },
    );
  }
}
