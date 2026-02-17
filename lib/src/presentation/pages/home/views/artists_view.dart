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
          return const Center(child: CircularProgressIndicator());
        }

        /// EMPTY STATE
        if (state.artists.isEmpty) {
          return const Center(child: Text('No artists found'));
        }

        /// GRID VIEW
        return AnimationLimiter(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: state.artists.length,
            itemBuilder: (context, index) {
              final artist = state.artists[index];

              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 500),
                columnCount: 2,
                child: FlipAnimation(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(AppRouter.artistRoute, arguments: artist);
                    },
                    child: Column(
                      children: [
                        QueryArtworkWidget(
                          keepOldArtwork: true,
                          id: artist.id,
                          type: ArtworkType.ARTIST,
                          artworkHeight: 96,
                          artworkWidth: 96,
                          size: 10000,
                          artworkBorder: BorderRadius.circular(25),
                          nullArtworkWidget: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.grey.withValues(alpha: 0.1),
                            ),
                            child: const Icon(Icons.person_outlined),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          artist.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
