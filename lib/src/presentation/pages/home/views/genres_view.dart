import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/core/router/app_router.dart';
import 'package:on_audio_query/on_audio_query.dart';

class GenresView extends StatefulWidget {
  const GenresView({super.key});

  @override
  State<GenresView> createState() => _GenresViewState();
}

class _GenresViewState extends State<GenresView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    final bloc = context.read<HomeBloc>();

    // Only load once
    if (bloc.state.genres.isEmpty) {
      bloc.add(GetGenresEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        /// FIRST TIME LOADING
        if (state.isLoading && state.genres.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading genres...'),
              ],
            ),
          );
        }

        /// EMPTY STATE
        if (state.genres.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No genres found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add music to your device to see genres',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                ),
              ],
            ),
          );
        }

        /// LIST VIEW
        return AnimationLimiter(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: state.genres.length,
            itemBuilder: (context, index) {
              final genre = state.genres[index];

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50,
                  child: FadeInAnimation(child: _buildGenreTile(genre)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGenreTile(GenreModel genre) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(AppRouter.genreRoute, arguments: genre);
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: QueryArtworkWidget(
              keepOldArtwork: true,
              id: genre.id,
              type: ArtworkType.GENRE,
              artworkBorder: BorderRadius.circular(10),
              size: 500,
              nullArtworkWidget: Icon(
                Icons.category_outlined,
                size: 30,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        title: Text(
          genre.genre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          '${genre.numOfSongs} ${genre.numOfSongs == 1 ? 'song' : 'songs'}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
