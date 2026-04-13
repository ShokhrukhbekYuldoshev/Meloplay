import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/bloc/player/player_bloc.dart';
import 'package:meloplay/src/core/constants/assets.dart';
import 'package:meloplay/src/core/extensions/song_model_extensions.dart';
import 'package:meloplay/src/presentation/pages/home/widgets/sort_bottom_sheet.dart';
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
    if (bloc.state.songs.isEmpty && !bloc.state.isLoading) {
      bloc.add(GetSongsEvent());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        /// FIRST TIME LOADING
        if (state.isLoading && state.songs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading your music...'),
              ],
            ),
          );
        }

        /// EMPTY STATE
        if (state.songs.isEmpty && !state.isLoading) {
          return _buildEmptyState(context);
        }

        /// MAIN CONTENT
        return RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(GetSongsEvent());
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Top spacing
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              /// HEADER WITH STATS AND SORT
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatsText(state),
                      _buildSortButton(context),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              /// QUICK ACTION BUTTONS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildShuffleButton(context, state.songs),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _buildPlayButton(context, state.songs)),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              /// SONG LIST
              AnimationLimiter(
                child: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final song = state.songs[index];

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 50),
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

              /// BOTTOM SPACING
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  // ===========================
  // EMPTY STATE
  // ===========================

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Songs Found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add music to your device to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<HomeBloc>().add(GetSongsEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================
  // STATS TEXT
  // ===========================

  Widget _buildStatsText(HomeState state) {
    final duration = state.songs.fold<Duration>(
      Duration.zero,
      (sum, song) => sum + Duration(milliseconds: song.duration ?? 0),
    );

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    String durationText = '';
    if (hours > 0) {
      durationText = '$hours hr $minutes min';
    } else {
      durationText = '$minutes min';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_formatNumber(state.songs.length)} Songs',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          durationText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // ===========================
  // SORT BUTTON
  // ===========================

  Widget _buildSortButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        icon: const Icon(Icons.sort),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const SortBottomSheet(),
          );
        },
        tooltip: 'Sort songs',
      ),
    );
  }

  // ===========================
  // SHUFFLE BUTTON
  // ===========================

  Widget _buildShuffleButton(BuildContext context, List<SongModel> songs) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
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
              Text(
                'Shuffle',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================
  // PLAY BUTTON
  // ===========================

  Widget _buildPlayButton(BuildContext context, List<SongModel> songs) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
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
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Play All',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
