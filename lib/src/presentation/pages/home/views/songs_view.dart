import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/bloc/player/player_bloc.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/core/extensions/string_extensions.dart';
import 'package:meloplay/src/data/repositories/player_repository.dart';
import 'package:meloplay/src/data/services/hive_box.dart';
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

          Fluttertoast.showToast(
            msg: '${state.songs.length} songs found',
          );
        }
      },
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(GetSongsEvent());
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // number of songs
                          Text(
                            '${songs.length} songs',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          // sort button
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => const SortBottomSheet(),
                              );
                            },
                            icon: const Icon(Icons.sort),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(32),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.shuffle),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Shuffle',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // enable shuffle
                                  context.read<PlayerBloc>().add(
                                        PlayerSetShuffleModeEnabled(true),
                                      );

                                  // get random song
                                  final randomSong =
                                      songs[Random().nextInt(songs.length)];

                                  // play random song
                                  context.read<PlayerBloc>().add(
                                        PlayerLoadSongs(
                                          songs,
                                          sl<JustAudioPlayer>()
                                              .getMediaItemFromSong(randomSong),
                                        ),
                                      );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(32),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.play_arrow),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Play',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // disable shuffle
                                  context.read<PlayerBloc>().add(
                                        PlayerSetShuffleModeEnabled(false),
                                      );

                                  // play first song
                                  context.read<PlayerBloc>().add(
                                        PlayerLoadSongs(
                                          songs,
                                          sl<JustAudioPlayer>()
                                              .getMediaItemFromSong(songs[0]),
                                        ),
                                      );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimationLimiter(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                        childCount: songs.length,
                      ),
                    ),
                  ),
                  // bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
    );
  }
}

class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({super.key});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  int currentSortType = Hive.box(HiveBox.boxName).get(
    HiveBox.songSortTypeKey,
    defaultValue: SongSortType.TITLE.index,
  );
  int currentOrderType = Hive.box(HiveBox.boxName).get(
    HiveBox.songOrderTypeKey,
    defaultValue: OrderType.ASC_OR_SMALLER.index,
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Sort by',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          for (final songSortType in SongSortType.values)
            RadioListTile<int>(
              visualDensity: const VisualDensity(
                horizontal: 0,
                vertical: -4,
              ),
              value: songSortType.index,
              groupValue: currentSortType,
              title: Text(
                songSortType.name.capitalize().replaceAll('_', ' '),
              ),
              onChanged: (value) {
                setState(() {
                  currentSortType = value!;
                });
              },
            ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Order by',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          for (final orderType in OrderType.values)
            RadioListTile<int>(
              visualDensity: const VisualDensity(
                horizontal: 0,
                vertical: -4,
              ),
              value: orderType.index,
              groupValue: currentOrderType,
              title: Text(
                orderType.name.capitalize().replaceAll('_', ' '),
              ),
              onChanged: (value) {
                setState(() {
                  currentOrderType = value!;
                });
              },
            ),
          const SizedBox(height: 16),
          // cancel, apply button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.read<HomeBloc>().add(
                            SortSongsEvent(
                              currentSortType,
                              currentOrderType,
                            ),
                          );
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
