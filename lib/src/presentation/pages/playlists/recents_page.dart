import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import 'package:meloplay/src/bloc/recents/recents_bloc.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/data/repositories/player_repository.dart';
import 'package:meloplay/src/presentation/widgets/player_bottom_app_bar.dart';
import 'package:meloplay/src/presentation/widgets/song_list_tile.dart';

class RecentsPage extends StatefulWidget {
  const RecentsPage({super.key});

  @override
  State<RecentsPage> createState() => _RecentsPageState();
}

class _RecentsPageState extends State<RecentsPage> {
  final player = sl<MusicPlayer>();

  @override
  void initState() {
    super.initState();
    // Dispatch the FetchRecents event
    context.read<RecentsBloc>().add(FetchRecents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // current song, play/pause button, song progress bar, song queue button
      bottomNavigationBar: const PlayerBottomAppBar(),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Themes.getTheme().primaryColor,
        elevation: 0,
        title: const Text('Recents'),
      ),
      body: Ink(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: Themes.getTheme().linearGradient,
        ),
        child: StreamBuilder<SequenceState?>(
          stream: player.sequenceState,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              context.read<RecentsBloc>().add(FetchRecents());
            }

            return BlocBuilder<RecentsBloc, RecentsState>(
              buildWhen: (_, current) => current is RecentsLoaded,
              builder: (context, state) {
                if (state is RecentsLoaded) {
                  return _buildBody(state);
                } else {
                  return const SizedBox();
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(RecentsLoaded state) {
    if (state.songs.isEmpty) {
      return const Center(
        child: Text('No songs found'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: state.songs.length,
      itemBuilder: (context, index) {
        return SongListTile(
          song: state.songs[index],
          songs: state.songs,
        );
      },
    );
  }
}
