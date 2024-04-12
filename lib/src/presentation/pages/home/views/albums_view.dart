import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/core/router/app_router.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AlbumsView extends StatefulWidget {
  const AlbumsView({super.key});

  @override
  State<AlbumsView> createState() => _AlbumsViewState();
}

class _AlbumsViewState extends State<AlbumsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final audioQuery = sl<OnAudioQuery>();
  final albums = <AlbumModel>[];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(GetAlbumsEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is AlbumsLoaded) {
          setState(() {
            albums.clear();
            albums.addAll(state.albums);
            isLoading = false;
          });
        }
      },
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : AnimationLimiter(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];

                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    columnCount: 2,
                    child: FlipAnimation(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.albumRoute,
                            arguments: album,
                          );
                        },
                        child: Column(
                          children: [
                            QueryArtworkWidget(
                              id: album.id,
                              type: ArtworkType.ALBUM,
                              artworkHeight: 96,
                              artworkWidth: 96,
                              size: 10000,
                              artworkBorder: BorderRadius.circular(100),
                              nullArtworkWidget: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                                child: const Icon(
                                  Icons.music_note_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              album.album,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              album.artist ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(),
                            ),
                          ],
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
