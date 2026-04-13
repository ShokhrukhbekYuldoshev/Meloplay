import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/core/router/app_router.dart';
import 'package:on_audio_query/on_audio_query.dart';

class ArtistsView extends StatefulWidget {
  const ArtistsView({super.key});

  @override
  State<ArtistsView> createState() => _ArtistsViewState();
}

class _ArtistsViewState extends State<ArtistsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    final bloc = context.read<HomeBloc>();

    // Only load once
    if (bloc.state.artists.isEmpty) {
      bloc.add(GetArtistsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        /// FIRST TIME LOADING
        if (state.isLoading && state.artists.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading artists...'),
              ],
            ),
          );
        }

        /// EMPTY STATE
        if (state.artists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No artists found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add music to your device to see artists',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                ),
              ],
            ),
          );
        }

        /// GRID VIEW - Responsive
        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive crossAxisCount based on screen width
            int crossAxisCount;
            double childAspectRatio;

            if (constraints.maxWidth < 400) {
              // Small phones
              crossAxisCount = 2;
              childAspectRatio = 0.85;
            } else if (constraints.maxWidth < 600) {
              // Medium phones
              crossAxisCount = 2;
              childAspectRatio = 0.9;
            } else if (constraints.maxWidth < 900) {
              // Tablets
              crossAxisCount = 3;
              childAspectRatio = 0.85;
            } else {
              // Large tablets and desktops
              crossAxisCount = 4;
              childAspectRatio = 0.85;
            }

            return AnimationLimiter(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: state.artists.length,
                itemBuilder: (context, index) {
                  final artist = state.artists[index];

                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    columnCount: crossAxisCount,
                    child: ScaleAnimation(
                      child: FadeInAnimation(child: _buildArtistCard(artist)),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildArtistCard(ArtistModel artist) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(AppRouter.artistRoute, arguments: artist);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Artist Image
            Hero(
              tag: 'artist_${artist.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: QueryArtworkWidget(
                  keepOldArtwork: true,
                  id: artist.id,
                  type: ArtworkType.ARTIST,
                  artworkHeight: 120,
                  artworkWidth: 120,
                  size: 500,
                  artworkBorder: BorderRadius.circular(25),
                  nullArtworkWidget: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                          Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 50,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Artist Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                artist.artist,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Song count
            Text(
              '${artist.numberOfTracks} ${artist.numberOfTracks == 1 ? 'song' : 'songs'}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
