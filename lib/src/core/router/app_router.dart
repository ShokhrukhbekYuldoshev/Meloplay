import 'package:flutter/material.dart';
import 'package:meloplay/src/presentation/pages/config/scan_page.dart';
import 'package:meloplay/src/presentation/pages/config/settings_page.dart';
import 'package:meloplay/src/presentation/pages/playlists/playlist_details_page.dart';
import 'package:meloplay/src/presentation/pages/player/queue_page.dart';
import 'package:meloplay/src/presentation/pages/home/search_page.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/presentation/pages/details/album_page.dart';
import 'package:meloplay/src/presentation/pages/details/artist_page.dart';
import 'package:meloplay/src/presentation/pages/playlists/favorites_page.dart';
import 'package:meloplay/src/presentation/pages/details/genre_page.dart';
import 'package:meloplay/src/presentation/pages/home/home_page.dart';
import 'package:meloplay/src/presentation/pages/player/player_page.dart';
import 'package:meloplay/src/presentation/pages/playlists/recents_page.dart';
import 'package:meloplay/src/presentation/pages/config/themes_page.dart';
import 'package:meloplay/src/presentation/pages/splash_page.dart';

class AppRouter {
  static const String splashRoute = '/';
  static const String homeRoute = '/home';
  static const String favoritesRoute = '/favorites';
  static const String recentsRoute = '/recents';
  static const String playerRoute = '/player';
  static const String artistRoute = '/artist';
  static const String albumRoute = '/album';
  static const String genreRoute = '/genre';
  static const String themesRoute = '/themes';
  static const String settingsRoute = '/settings';
  static const String playlistDetailsRoute = '/playlist';
  static const String queueRoute = '/queue';
  static const String searchRoute = '/search';
  static const String scanRoute = '/scan';
  static const String addSongToPlaylistRoute = '/addSongToPlaylist';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<dynamic>(
          builder: (_) => const SplashPage(),
        );
      case homeRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const HomePage(),
        );
      case favoritesRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const FavoritesPage(),
        );

      case recentsRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const RecentsPage(),
        );
      case playerRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const PlayerPage(),
        );
      case artistRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => ArtistPage(
            artist: settings.arguments as ArtistModel,
          ),
        );
      case albumRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => AlbumPage(
            album: settings.arguments as AlbumModel,
          ),
        );
      case genreRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => GenrePage(
            genre: settings.arguments as GenreModel,
          ),
        );
      case themesRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const ThemesPage(),
        );
      case settingsRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const SettingsPage(),
        );
      case scanRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const ScanPage(),
        );
      case playlistDetailsRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => PlaylistDetailsPage(
            playlist: settings.arguments as PlaylistModel,
          ),
        );
      case queueRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const QueuePage(),
        );
      case searchRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const SearchPage(),
        );
      case addSongToPlaylistRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => AddSongToPlaylist(
            songs: (settings.arguments as Map)['songs'] as List<SongModel>,
            playlist: (settings.arguments as Map)['playlist'] as PlaylistModel,
          ),
        );
      default:
        return MaterialPageRoute<dynamic>(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
