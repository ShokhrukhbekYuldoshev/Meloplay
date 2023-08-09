import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloplay/bloc/theme/theme_bloc.dart';
import 'package:meloplay/data/repositories/song_repository.dart';
import 'package:meloplay/presentation/components/home_card.dart';
import 'package:meloplay/presentation/components/home_drawer.dart';
import 'package:meloplay/presentation/components/player_bottom_app_bar.dart';
import 'package:meloplay/presentation/pages/home/views/albums_view.dart';
import 'package:meloplay/presentation/pages/home/views/artists_view.dart';
import 'package:meloplay/presentation/pages/home/views/genres_view.dart';
import 'package:meloplay/presentation/pages/home/views/songs_view.dart';
import 'package:meloplay/presentation/utils/app_router.dart';
import 'package:meloplay/presentation/utils/theme/themes.dart';
import 'package:on_audio_query/on_audio_query.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  bool _hasPermission = false;

  late final SongRepository songRepository;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    checkAndRequestPermissions();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  Future checkAndRequestPermissions({bool retry = false}) async {
    // The param 'retryRequest' is false, by default.
    _hasPermission = await _audioQuery.checkAndRequest(
      retryRequest: retry,
    );

    // Only call update the UI if application has all required permissions.
    _hasPermission ? setState(() {}) : checkAndRequestPermissions(retry: true);
  }

  final tabs = [
    'Songs',
    'Artists',
    'Albums',
    'Genres',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          drawer: const HomeDrawer(),
          // current song, play/pause button, song progress bar, song queue button
          bottomNavigationBar: const PlayerBottomAppBar(),
          body: Ink(
            padding: EdgeInsets.fromLTRB(
              0,
              MediaQuery.of(context).padding.top + 16,
              0,
              0,
            ),
            decoration: BoxDecoration(
              gradient: Themes.getTheme().linearGradient,
            ),
            child: _hasPermission
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            // menu button
                            Builder(
                              builder: (context) => IconButton(
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                icon: const Icon(
                                  Icons.menu,
                                ),
                              ),
                            ),
                            const Text(
                              'Meloplay',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // cards (favorites, playlists, recents)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            HomeCard(
                              title: 'Favorites',
                              icon: Icons.favorite_rounded,
                              color: const Color(0xFF5D2285),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRouter.favoritesRoute,
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            HomeCard(
                              title: 'Playlists',
                              icon: Icons.playlist_play,
                              color: const Color(0xFF136327),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRouter.playlistsRoute,
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            HomeCard(
                              title: 'Recents',
                              icon: Icons.history,
                              color: const Color(0xFFD4850D),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRouter.recentsRoute,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // tabs (songs, artists, albums, playlists, favorites)
                      TabBar(
                        controller: _tabController,
                        tabs: tabs.map((e) => Tab(text: e)).toList(),
                      ),
                      // body
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: const [
                            SongsView(),
                            ArtistsView(),
                            AlbumsView(),
                            GenresView(),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text('No permission to access library'),
                  ),
          ),
        );
      },
    );
  }
}
