import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:meloplay/src/core/extensions/song_model_extensions.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/bloc/player/player_bloc.dart';
import 'package:meloplay/src/core/constants/assets.dart';
import 'package:meloplay/src/core/extensions/string_extensions.dart';
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

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final bloc = context.read<HomeBloc>();

    // Only load once
    if (bloc.state.songs.isEmpty) {
      bloc.add(GetSongsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        /// FIRST TIME LOADING
        if (state.isLoading && state.songs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        /// EMPTY STATE
        if (state.songs.isEmpty) {
          return const Center(child: Text('No songs found'));
        }

        /// MAIN CONTENT
        return RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(GetSongsEvent());
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              /// HEADER
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.songs.length} Songs',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_vert),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const SortBottomSheet(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              /// PLAY / SHUFFLE ROW
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildShuffleButton(context, state.songs),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildPlayButton(context, state.songs)),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              /// SONG LIST
              AnimationLimiter(
                child: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final song = state.songs[index];

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 400),
                      child: SlideAnimation(
                        verticalOffset: 50,
                        child: FadeInAnimation(
                          child: SongListTile(song: song, songs: state.songs),
                        ),
                      ),
                    );
                  }, childCount: state.songs.length),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  // ===========================
  // SHUFFLE BUTTON
  // ===========================

  Widget _buildShuffleButton(BuildContext context, List<SongModel> songs) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(32),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () {
          final randomIndex = Random().nextInt(songs.length);

          context.read<PlayerBloc>().add(PlayerSetShuffle(true));

          context.read<PlayerBloc>().add(
            PlayerLoadPlaylist(
              mediaItem: songs[randomIndex].toMediaItem(),
              playlist: songs,
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Assets.shuffleSvg,
              width: 20,
              colorFilter: ColorFilter.mode(
                Theme.of(context).textTheme.bodyMedium!.color!,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text('Shuffle', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  // ===========================
  // PLAY BUTTON
  // ===========================

  Widget _buildPlayButton(BuildContext context, List<SongModel> songs) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(32),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () {
          context.read<PlayerBloc>().add(PlayerSetShuffle(false));

          context.read<PlayerBloc>().add(
            PlayerLoadPlaylist(
              mediaItem: songs.first.toMediaItem(),
              playlist: songs,
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Assets.playSvg,
              width: 20,
              colorFilter: ColorFilter.mode(
                Theme.of(context).textTheme.bodyMedium!.color!,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text('Play', style: Theme.of(context).textTheme.titleMedium),
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
  int currentSortType = Hive.box(
    HiveBox.boxName,
  ).get(HiveBox.songSortTypeKey, defaultValue: SongSortType.TITLE.index);
  int currentOrderType = Hive.box(
    HiveBox.boxName,
  ).get(HiveBox.songOrderTypeKey, defaultValue: OrderType.ASC_OR_SMALLER.index);
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          for (final songSortType in SongSortType.values)
            RadioListTile<int>(
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              value: songSortType.index,
              groupValue: currentSortType,
              title: Text(songSortType.name.capitalize().replaceAll('_', ' ')),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          for (final orderType in OrderType.values)
            RadioListTile<int>(
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              value: orderType.index,
              groupValue: currentOrderType,
              title: Text(orderType.name.capitalize().replaceAll('_', ' ')),
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
                        SortSongsEvent(currentSortType, currentOrderType),
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
