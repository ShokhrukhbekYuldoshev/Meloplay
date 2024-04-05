import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/presentation/widgets/song_list_tile.dart';

class SongsView extends StatefulWidget {
  const SongsView({super.key});

  @override
  State<SongsView> createState() => _SongsViewState();
}

class _SongsViewState extends State<SongsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final audioQuery = sl<OnAudioQuery>();
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

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: FlipAnimation(
                      child: SongListTile(
                        song: song,
                        songs: songs,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
