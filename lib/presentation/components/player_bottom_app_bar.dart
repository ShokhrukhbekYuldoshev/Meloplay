import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meloplay/bloc/theme/theme_bloc.dart';
import 'package:meloplay/data/repositories/song_repository.dart';
import 'package:meloplay/presentation/utils/app_router.dart';
import 'package:meloplay/presentation/utils/theme/themes.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerBottomAppBar extends StatefulWidget {
  const PlayerBottomAppBar({
    super.key,
  });

  @override
  State<PlayerBottomAppBar> createState() => _PlayerBottomAppBarState();
}

class _PlayerBottomAppBarState extends State<PlayerBottomAppBar> {
  late final SongRepository songRepository;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    songRepository = context.read<SongRepository>();
    songRepository.playing.listen((playing) {
      setState(() {
        isPlaying = playing;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isPlaying
        ? BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return GestureDetector(
                onTap: () async {
                  Navigator.pushNamed(
                    context,
                    AppRouter.playerRoute,
                    arguments: await songRepository.mediaItem.first,
                  );
                },
                child: BottomAppBar(
                  color: Themes.getTheme().primaryColor,
                  child: StreamBuilder<MediaItem?>(
                      stream: songRepository.mediaItem,
                      builder: (context, snapshot) {
                        final mediaItem = snapshot.data;
                        return Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: Row(
                                children: [
                                  mediaItem == null
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : QueryArtworkWidget(
                                          id: int.parse(mediaItem.id),
                                          type: ArtworkType.AUDIO,
                                          artworkQuality: FilterQuality.high,
                                          quality: 100,
                                          artworkBorder:
                                              BorderRadius.circular(10),
                                          nullArtworkWidget: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.music_note_outlined,
                                            ),
                                          ),
                                        ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mediaItem?.title ?? 'Unknown',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          mediaItem?.artist ?? 'Unknown',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Themes.getTheme()
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // play/pause button
                            StreamBuilder<bool>(
                              stream: songRepository.playing,
                              builder: (context, snapshot) {
                                final playing = snapshot.data ?? false;
                                return IconButton(
                                  onPressed: () {
                                    if (playing) {
                                      songRepository.pause();
                                    } else {
                                      songRepository.play();
                                    }
                                  },
                                  icon: playing
                                      ? const Icon(Icons.pause_rounded)
                                      : const Icon(Icons.play_arrow_rounded),
                                );
                              },
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.queue_music_outlined),
                            ),
                            const SizedBox(width: 16),
                          ],
                        );
                      }),
                ),
              );
            },
          )
        : const SizedBox.shrink();
  }
}
