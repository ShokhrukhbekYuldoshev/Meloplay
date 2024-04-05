# 🎵 Meloplay

Meloplay is a local music player app that plays music from your device built with Flutter.

## 📱 Platforms

-   Android
-   iOS

## ✨ Features

-   [x] Play music from your device
-   [x] Background audio
-   [x] Notification controls
-   [x] Lock screen controls
-   [x] Play, pause, skip, previous, seek
-   [x] Shuffle and repeat
-   [ ] Search for music, playlists, artists, albums, genres
-   [ ] Playlists (Read, create, rename, delete, add songs, remove songs)
-   [x] Favorites (Add songs, remove songs)
-   [x] Recently played
-   [ ] Most played
-   [x] Artists
-   [x] Albums
-   [x] Genres
-   [ ] Lyrics
-   [ ] Equalizer
-   [ ] Sleep timer
-   [x] Share music
-   [x] Settings
-   [x] Themes (multiple themes)

## 📸 Screenshots

<!-- Variables -->

[splash]: screenshots/splash.jpg 'Splash'
[songs]: screenshots/songs.jpg 'Songs'
[song_sheet]: screenshots/song_sheet.jpg 'Song sheet'
[player-1]: screenshots/player-1.jpg 'Player 1'
[player-2]: screenshots/player-2.jpg 'Player 2'
[artists]: screenshots/artists.jpg 'Artists'
[albums]: screenshots/albums.jpg 'Albums'
[genres]: screenshots/genres.jpg 'Genres'
[artist]: screenshots/artist.jpg 'Artist'
[album]: screenshots/album.jpg 'Album'
[genre]: screenshots/genre.jpg 'Genre'
[drawer]: screenshots/drawer.jpg 'Drawer'
[about]: screenshots/about.jpg 'About'
[settings]: screenshots/settings.jpg 'Settings'
[settings_orange]: screenshots/settings_orange.jpg 'Settings orange'
[songs_orange]: screenshots/songs_orange.jpg 'Songs orange'

<!-- Table -->

|      Splash       |      Songs      |        Song sheet         |
| :---------------: | :-------------: | :-----------------------: |
| ![Splash][splash] | ![Songs][songs] | ![Song sheet][song_sheet] |

|       Player 1        |       Player 2        |       Artists       |
| :-------------------: | :-------------------: | :-----------------: |
| ![Player 1][player-1] | ![Player 2][player-2] | ![Artists][artists] |

|      Albums       |      Genres       |      Artist       |
| :---------------: | :---------------: | :---------------: |
| ![Albums][albums] | ![Genres][genres] | ![Artist][artist] |

|      Album      |      Genre      |      Drawer       |
| :-------------: | :-------------: | :---------------: |
| ![Album][album] | ![Genre][genre] | ![Drawer][drawer] |

|      About      |       Settings        |           Settings orange           |
| :-------------: | :-------------------: | :---------------------------------: |
| ![About][about] | ![Settings][settings] | ![Settings orange][settings_orange] |

|         Songs orange          |
| :---------------------------: |
| ![Songs orange][songs_orange] |

## 📚 Dependencies

| Name                                                                                  | Version       | Description                                                                                                                                                              |
| ------------------------------------------------------------------------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [bloc](https://pub.dev/packages/bloc)                                                 | 8.1.4         | A predictable state management library                                                                                                                                   |
| [flutter_bloc](https://pub.dev/packages/flutter_bloc)                                 | 8.1.5         | Flutter Widgets that make it easy to implement BLoC design patterns                                                                                                      |
| [flutter_staggered_animations](https://pub.dev/packages/flutter_staggered_animations) | 1.1.1         | A plugin for adding staggered animations to your Flutter apps                                                                                                            |
| [get_it](https://pub.dev/packages/get_it)                                             | 7.6.8         | Simple direct Service Locator that allows to decouple the interface from a concrete implementation and to access the concrete implementation from everywhere in your App |
| [hive](https://pub.dev/packages/hive)                                                 | 2.2.3         | A lightweight and blazing fast key-value database                                                                                                                        |
| [hive_flutter](https://pub.dev/packages/hive_flutter)                                 | 1.1.0         | Hive database implementation for Flutter                                                                                                                                 |
| [just_audio](https://pub.dev/packages/just_audio)                                     | 0.9.37        | A feature-rich audio player for Flutter                                                                                                                                  |
| [just_audio_background](https://pub.dev/packages/just_audio_background)               | 0.0.1-beta.11 | A plugin for playing audio in the background on Android and iOS.                                                                                                         |
| [on_audio_query](https://pub.dev/packages/on_audio_query)                             | 2.9.0         | A Flutter plugin to query songs on Android and iOS                                                                                                                       |
| [package_info_plus](https://pub.dev/packages/package_info_plus)                       | 6.0.0         | Flutter plugin for querying information about the application package, such as CFBundleVersion on iOS or versionCode on Android.                                         |
| [permission_handler](https://pub.dev/packages/permission_handler)                     | 11.3.1        | A Flutter plugin for permission handling. This plugin provides a cross-platform (iOS, Android) API to request and check permissions.                                     |
| [rxdart](https://pub.dev/packages/rxdart)                                             | 0.27.7        | RxDart is an implementation of the popular reactiveX api for asynchronous programming, leveraging the native Dart Streams API.                                           |
| [share_plus](https://pub.dev/packages/share_plus)                                     | 8.0.2         | Flutter plugin for sharing content via the platform share UI, using the ACTION_SEND intent on Android and UIActivityViewController on iOS.                               |
| [url_launcher](https://pub.dev/packages/url_launcher)                                 | 6.2.5         | A Flutter plugin for launching a URL in the mobile platform.                                                                                                             |
| [lottie](https://pub.dev/packages/lottie)                                             | 3.1.0         | Lottie is a mobile library for Android and iOS that parses Lottie and JSON-based animations and renders them natively on mobile.                                         |

## 📦 Installation

### Prerequisites

-   Flutter
-   Android Studio / Xcode

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

-   [Email](mailto:shokhrukhbekdev@gmail.com)
-   [GitHub](https://github.com/ShokhrukhbekYuldoshev)

## 🌟 Show your support

Give a ⭐️ if you like this project!
