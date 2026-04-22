import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/features/playlists/data/models/playlist_model.dart';
import 'package:meloplay/src/features/config/presentation/scan_page.dart';
import 'package:meloplay/src/features/config/presentation/settings_page.dart';
import 'package:meloplay/src/features/config/presentation/themes_page.dart';
import 'package:meloplay/src/features/home/presentation/album_page.dart';
import 'package:meloplay/src/features/home/presentation/artist_page.dart';
import 'package:meloplay/src/features/home/presentation/genre_page.dart';
import 'package:meloplay/src/features/home/presentation/home_page.dart';
import 'package:meloplay/src/features/home/presentation/search_page.dart';
import 'package:meloplay/src/features/player/presentation/queue_page.dart';
import 'package:meloplay/src/features/playlists/presentation/manage_playlist.dart';
import 'package:meloplay/src/features/playlists/presentation/favorites_page.dart';
import 'package:meloplay/src/features/playlists/presentation/playlist_details_page.dart';
import 'package:meloplay/src/features/playlists/presentation/recents_page.dart';

class AppRouter {
  static const String homeRoute = '/';
  static const String favoritesRoute = '/favorites';
  static const String recentsRoute = '/recents';
  static const String artistRoute = '/artist';
  static const String albumRoute = '/album';
  static const String genreRoute = '/genre';
  static const String themesRoute = '/themes';
  static const String settingsRoute = '/settings';
  static const String playlistDetailsRoute = '/playlist';
  static const String queueRoute = '/queue';
  static const String searchRoute = '/search';
  static const String scanRoute = '/scan';
  static const String managePlaylistRoute = '/managePlaylist';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute<dynamic>(builder: (_) => const HomePage());
      case favoritesRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const FavoritesPage(),
        );
      case recentsRoute:
        return MaterialPageRoute<dynamic>(builder: (_) => const RecentsPage());

      case artistRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => ArtistPage(artist: settings.arguments as ArtistModel),
        );
      case albumRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => AlbumPage(album: settings.arguments as AlbumModel),
        );
      case genreRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => GenrePage(genre: settings.arguments as GenreModel),
        );
      case themesRoute:
        return MaterialPageRoute<dynamic>(builder: (_) => const ThemesPage());
      case settingsRoute:
        return MaterialPageRoute<dynamic>(builder: (_) => const SettingsPage());
      case scanRoute:
        return MaterialPageRoute<dynamic>(builder: (_) => const ScanPage());
      case playlistDetailsRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) =>
              PlaylistDetailsPage(playlist: settings.arguments as Playlist),
        );
      case queueRoute:
        return MaterialPageRoute<dynamic>(builder: (_) => const QueuePage());
      case searchRoute:
        return MaterialPageRoute<dynamic>(builder: (_) => const SearchPage());
      case managePlaylistRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => ManagePlaylist(
            playlist: (settings.arguments as Map)['playlist'] as Playlist,
          ),
        );
      default:
        return MaterialPageRoute<dynamic>(builder: (_) => const HomePage());
    }
  }
}
