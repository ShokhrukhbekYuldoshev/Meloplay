import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:meloplay/bloc/home/home_bloc.dart';
import 'package:meloplay/data/repositories/song_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/data/models/player_page_arguments.dart';
import 'package:meloplay/presentation/components/song_list_tile.dart';

class SongsView extends StatefulWidget {
  const SongsView({super.key});

  @override
  State<SongsView> createState() => _SongsViewState();
}

class _SongsViewState extends State<SongsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final audioQuery = OnAudioQuery();
  final songs = <SongModel>[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(GetSongsEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) async {
        if (state is SongsLoaded) {
          setState(() {
            songs.clear();
            songs.addAll(state.songs);
            isLoading = false;
          });

          await context.read<SongRepository>().addSongsToPlaylist(songs);
        }
      },
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : AnimationLimiter(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  final args = PlayerPageArguments(
                    songs: songs,
                    initialIndex: index,
                  );
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: FlipAnimation(
                      child: SongListTile(
                        song: song,
                        args: args,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
