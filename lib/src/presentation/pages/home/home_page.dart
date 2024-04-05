import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:meloplay/src/bloc/theme/theme_bloc.dart';
import 'package:meloplay/src/presentation/pages/home/views/albums_view.dart';
import 'package:meloplay/src/presentation/pages/home/views/artists_view.dart';
import 'package:meloplay/src/presentation/pages/home/views/genres_view.dart';
import 'package:meloplay/src/presentation/pages/home/views/songs_view.dart';
import 'package:meloplay/src/core/router/app_router.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/presentation/widgets/home_card.dart';
import 'package:meloplay/src/presentation/widgets/home_drawer.dart';
import 'package:meloplay/src/presentation/widgets/player_bottom_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final OnAudioQuery _audioQuery = sl<OnAudioQuery>();
  late TabController _tabController;
  bool _hasPermission = false;

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
          // current song, play/pause button, song progress bar, song queue button
          bottomNavigationBar: const PlayerBottomAppBar(),
          extendBody: true,
          drawer: const HomeDrawer(),
          appBar: AppBar(
            backgroundColor: Themes.getTheme().primaryColor,
            title: const Text('Meloplay'),
            // search button
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: implement search
                },
                icon: const Icon(Icons.search_outlined),
              )
            ],
          ),

          body: Ink(
            decoration: BoxDecoration(
              gradient: Themes.getTheme().linearGradient,
            ),
            child: _hasPermission
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            HomeCard(
                              title: 'Favorites',
                              icon: Icons.favorite_outlined,
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
                              icon: Icons.playlist_play_outlined,
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
                              icon: Icons.history_outlined,
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
                      TabBar(
                        controller: _tabController,
                        tabs: tabs.map((e) => Tab(text: e)).toList(),
                      ),
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
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                        child: Text('No permission to access library'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () async {
                          // permission request
                          await Permission.storage.request();
                        },
                        child: const Text('Retry'),
                      )
                    ],
                  ),
          ),
        );
      },
    );
  }
}
