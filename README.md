# Meloplay

Meloplay is a local music player app that plays music from your device built with Flutter.

## Platforms

- Android only

## Features

- [x] Play music from your device
- [x] Background audio
- [x] Notification controls
- [x] Lock screen controls
- [x] Play, pause, skip, previous, seek
- [x] Shuffle and repeat
- [x] Search for music, artists, albums, genres
- [x] Sort by (title, artist, album, duration, date, size, etc)
- [x] Order by (ascending, descending)
- [ ] Playlists (Read, create, rename, delete, add songs, remove songs)
- [ ] Queue (List, add songs, remove songs, change order)
- [x] Favorites (Add songs, remove songs)
- [x] Recently played
- [ ] Most played
- [x] Artists
- [x] Albums
- [x] Genres
- [ ] Lyrics
- [ ] Equalizer
- [ ] Sleep timer
- [x] Share music
- [x] Settings
- [x] Themes (multiple themes)
- [ ] Localization

## Screenshots

<!-- Variables -->

[splash]: screenshots/splash.jpg "Splash"
[songs]: screenshots/songs.jpg "Songs"
[player]: screenshots/player.jpg "Player"
[playlists]: screenshots/playlists.jpg "Playlists"
[artists]: screenshots/artists.jpg "Artists"
[albums]: screenshots/albums.jpg "Albums"
[genres]: screenshots/genres.jpg "Genres"
[drawer]: screenshots/drawer.jpg "Drawer"
[themes]: screenshots/themes.jpg "Themes"
[artist]: screenshots/artist.jpg "Artist"
[album]: screenshots/album.jpg "Album"
[genre]: screenshots/genre.jpg "Genre"
[search]: screenshots/search.jpg "Search"
[settings]: screenshots/settings.jpg "Settings"
[scan]: screenshots/scan.jpg "Scan"

<!-- Table -->

|      Splash       |      Songs      |      Player       |
| :---------------: | :-------------: | :---------------: |
| ![Splash][splash] | ![Songs][songs] | ![Player][player] |

|        Playlists        |       Artists       |      Albums       |
| :---------------------: | :-----------------: | :---------------: |
| ![Playlists][playlists] | ![Artists][artists] | ![Albums][albums] |

|      Genres       |      Drawer       |      Themes       |
| :---------------: | :---------------: | :---------------: |
| ![Genres][genres] | ![Drawer][drawer] | ![Themes][themes] |

|      Artist       |      Album      |      Genre      |
| :---------------: | :-------------: | :-------------: |
| ![Artist][artist] | ![Album][album] | ![Genre][genre] |

|      Search       |       Settings        |     Scan      |
| :---------------: | :-------------------: | :-----------: |
| ![Search][search] | ![Settings][settings] | ![Scan][scan] |

## Dependencies

| Name                                                                                  | Description                                                                        |
| ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| [auto_size_text](https://pub.dev/packages/auto_size_text)                             | Flutter widget that automatically resizes text to fit perfectly within its bounds. |
| [bloc](https://pub.dev/packages/bloc)                                                 | A predictable state management library.                                            |
| [flutter_bloc](https://pub.dev/packages/flutter_bloc)                                 | Flutter widgets that make it easy to implement BLoC design patterns.               |
| [flutter_cache_manager](https://pub.dev/packages/flutter_cache_manager)               | A Flutter plugin for caching images and other resources.                           |
| [flutter_staggered_animations](https://pub.dev/packages/flutter_staggered_animations) | A plugin for adding staggered animations to your Flutter apps.                     |
| [flutter_svg](https://pub.dev/packages/flutter_svg)                                   | Flutter plugin for displaying SVG images.                                          |
| [fluttertoast](https://pub.dev/packages/fluttertoast)                                 | Flutter plugin for displaying toast messages.                                      |
| [get_it](https://pub.dev/packages/get_it)                                             | Simple Service Locator for dependency injection.                                   |
| [hive](https://pub.dev/packages/hive)                                                 | A lightweight and blazing fast key-value database.                                 |
| [hive_flutter](https://pub.dev/packages/hive_flutter)                                 | Hive database implementation for Flutter.                                          |
| [just_audio](https://pub.dev/packages/just_audio)                                     | A feature-rich audio player for Flutter.                                           |
| [just_audio_background](https://pub.dev/packages/just_audio_background)               | Plugin for playing audio in the background on Android and iOS.                     |
| [lottie](https://pub.dev/packages/lottie)                                             | Library for rendering JSON-based Lottie animations natively.                       |
| [marquee](https://pub.dev/packages/marquee)                                           | A Flutter widget that scrolls text infinitely.                                     |
| [on_audio_query](https://pub.dev/packages/on_audio_query)                             | A Flutter plugin to query songs on Android and iOS.                                |
| [package_info_plus](https://pub.dev/packages/package_info_plus)                       | Plugin for querying information about the application package.                     |
| [permission_handler](https://pub.dev/packages/permission_handler)                     | Cross-platform permission handling plugin.                                         |
| [share_plus](https://pub.dev/packages/share_plus)                                     | Plugin for sharing content via the platform share UI.                              |
| [url_launcher](https://pub.dev/packages/url_launcher)                                 | Plugin for launching URLs on mobile platforms.                                     |

## 📦 Installation

### Prerequisites

- Flutter
- Android Studio / Xcode

### Setup

1. Clone the repo

   ```sh
   git clone
   ```

2. Install dependencies

   ```sh
   dart pub get
   ```

3. Run the app

   ```sh
   flutter run
   ```

## ❗ Permissions

Inside `AndroidManifest.xml` we have the following permissions:

```xml
<!-- ADD xmlns:tools="http://schemas.android.com/tools" to the "manifest" element -->
<manifest xmlns:tools="http://schemas.android.com/tools" ...>
    <!-- url_launcher -->
    <queries>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
    </queries>

    <!-- Android 12 and below -->
    <uses-permission
        android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />

    <!-- Android 13+ -->
    <uses-permission
        android:name="android.permission.READ_MEDIA_AUDIO" />

    <!-- ADD THESE TWO PERMISSIONS -->
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <!-- ALSO ADD THIS PERMISSION IF TARGETING SDK 34 -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>

    <application ...>

    ...

    <!-- EDIT THE android:name ATTRIBUTE IN YOUR EXISTING "ACTIVITY" ELEMENT -->
    <activity android:name="com.ryanheise.audioservice.AudioServiceActivity" ...>
      ...
    </activity>

    <!-- ADD THIS "SERVICE" element -->
    <service android:name="com.ryanheise.audioservice.AudioService"
        android:foregroundServiceType="mediaPlayback"
        android:exported="true" tools:ignore="Instantiatable">
      <intent-filter>
        <action android:name="android.media.browse.MediaBrowserService" />
      </intent-filter>
    </service>

    <!-- ADD THIS "RECEIVER" element -->
    <receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver"
        android:exported="true" tools:ignore="Instantiatable">
      <intent-filter>
        <action android:name="android.intent.action.MEDIA_BUTTON" />
      </intent-filter>
    </receiver>
  </application>
</manifest>
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

Distributed under the Attribution-NonCommercial-ShareAlike 4.0 International License. See [LICENSE](LICENSE) for more information.

## Contact

- [Email](mailto:shokh.xyz@gmail.com)
- [GitHub](https://github.com/ShokhrukhbekYuldoshev)

## Show your support

Give a star if you like this project!
