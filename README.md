# 🎵 Meloplay

Meloplay is a local music player app that plays music from your device built with Flutter.

## 📱 Platforms

- Android
- iOS (not tested)

## ✨ Features

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

## 📸 Screenshots

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

## 📚 Dependencies

| Name                                                                                  | Version       | Description                                                                                                                                                              |
| ------------------------------------------------------------------------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [bloc](https://pub.dev/packages/bloc)                                                 | 8.1.4         | A predictable state management library                                                                                                                                   |
| [flutter_bloc](https://pub.dev/packages/flutter_bloc)                                 | 8.1.6         | Flutter Widgets that make it easy to implement BLoC design patterns                                                                                                      |
| [flutter_staggered_animations](https://pub.dev/packages/flutter_staggered_animations) | 1.1.1         | A plugin for adding staggered animations to your Flutter apps                                                                                                            |
| [fluttertoast](https://pub.dev/packages/fluttertoast)                                 | 8.2.8         | Flutter plugin for displaying toast messages.                                                                                                                            |
| [flutter_cache_manager](https://pub.dev/packages/flutter_cache_manager)               | 3.4.1         | A Flutter plugin for caching images and other resources.                                                                                                                 |
| [get_it](https://pub.dev/packages/get_it)                                             | 7.7.0         | Simple direct Service Locator that allows to decouple the interface from a concrete implementation and to access the concrete implementation from everywhere in your App |
| [hive](https://pub.dev/packages/hive)                                                 | 2.2.3         | A lightweight and blazing fast key-value database                                                                                                                        |
| [hive_flutter](https://pub.dev/packages/hive_flutter)                                 | 1.1.0         | Hive database implementation for Flutter                                                                                                                                 |
| [just_audio](https://pub.dev/packages/just_audio)                                     | 0.9.40        | A feature-rich audio player for Flutter                                                                                                                                  |
| [just_audio_background](https://pub.dev/packages/just_audio_background)               | 0.0.1-beta.11 | A plugin for playing audio in the background on Android and iOS.                                                                                                         |
| [lottie](https://pub.dev/packages/lottie)                                             | 3.1.2         | Lottie is a mobile library for Android and iOS that parses Lottie and JSON-based animations and renders them natively on mobile.                                         |
| [marquee](https://pub.dev/packages/marquee)                                           | 2.2.3         | A Flutter widget that scrolls text infinitely.                                                                                                                           |
| [on_audio_query](https://pub.dev/packages/on_audio_query)                             | 2.9.0         | A Flutter plugin to query songs on Android and iOS                                                                                                                       |
| [package_info_plus](https://pub.dev/packages/package_info_plus)                       | 8.0.2         | Flutter plugin for querying information about the application package, such as CFBundleVersion on iOS or versionCode on Android.                                         |
| [permission_handler](https://pub.dev/packages/permission_handler)                     | 11.3.1        | A Flutter plugin for permission handling. This plugin provides a cross-platform (iOS, Android) API to request and check permissions.                                     |
| [rxdart](https://pub.dev/packages/rxdart)                                             | 0.28.0        | RxDart is an implementation of the popular reactiveX api for asynchronous programming, leveraging the native Dart Streams API.                                           |
| [share_plus](https://pub.dev/packages/share_plus)                                     | 10.0.2        | Flutter plugin for sharing content via the platform share UI, using the ACTION_SEND intent on Android and UIActivityViewController on iOS.                               |
| [url_launcher](https://pub.dev/packages/url_launcher)                                 | 6.3.0         | A Flutter plugin for launching a URL in the mobile platform.                                                                                                             |

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

### Android

```xml

<!-- url_launcher -->
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
</queries>

<!-- !DANGER! Delete, update songs/playlists -->
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />

<!-- Android 12 or below  -->
<uses-permission
    android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="29"
/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<!-- Android 13 or greater  -->
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

<!-- Audio service -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

### iOS

```xml
<!-- url_launcher -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>https</string>
</array>
<key>NSAppleMusicUsageDescription</key>
<string>$(PROJECT_NAME) requires access to media library</string>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>

```

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## 📝 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

## 📧 Contact

- [Email](mailto:shokhrukhbekdev@gmail.com)
- [GitHub](https://github.com/ShokhrukhbekYuldoshev)

## 🌟 Show your support

Give a ⭐️ if you like this project!
