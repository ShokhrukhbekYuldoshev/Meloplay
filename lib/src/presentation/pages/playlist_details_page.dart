import 'package:flutter/material.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistDetailsPage extends StatefulWidget {
  final PlaylistModel playlist;
  const PlaylistDetailsPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailsPage> createState() => _PlaylistDetailsPageState();
}

class _PlaylistDetailsPageState extends State<PlaylistDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.playlist),
        backgroundColor: Themes.getTheme().primaryColor,
      ),
      body: Container(),
    );
  }
}
