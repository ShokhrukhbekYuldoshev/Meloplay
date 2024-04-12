import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/core/router/app_router.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
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

  final audioQuery = sl<OnAudioQuery>();
  final genres = <GenreModel>[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(GetGenresEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is GenresLoaded) {
          setState(() {
            genres.clear();
            genres.addAll(state.genres);
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
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  final genre = genres[index];

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: FlipAnimation(
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.genreRoute,
                            arguments: genre,
                          );
                        },
                        leading: QueryArtworkWidget(
                          id: genre.id,
                          type: ArtworkType.GENRE,
                          artworkBorder: BorderRadius.circular(10),
                          size: 10000,
                          nullArtworkWidget: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.music_note_outlined,
                            ),
                          ),
                        ),
                        title: Text(
                          genre.genre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${genre.numOfSongs} song${genre.numOfSongs == 1 ? '' : 's'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
