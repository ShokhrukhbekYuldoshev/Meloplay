import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/bloc/search/search_bloc.dart';
import 'package:meloplay/src/core/extensions/string_extensions.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/presentation/widgets/song_list_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.getTheme().secondaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Themes.getTheme().primaryColor,
        title: TextField(
          onChanged: (value) {
            context.read<SearchBloc>().add(SearchQueryChanged(value));
          },
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                searchController.clear();
              });
            },
            icon: const Icon(Icons.clear),
            tooltip: 'Clear',
          ),
        ],
      ),
      body: Ink(
        decoration: BoxDecoration(
          gradient: Themes.getTheme().linearGradient,
        ),
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (searchController.text.isEmpty) {
              return Container();
            }
            if (state is SearchError) {
              return Center(
                child: Text(state.message),
              );
            }
            if (state is SearchLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Container(
              constraints: const BoxConstraints.expand(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // search result
                    // songs
                    if (state is SearchLoaded &&
                        state.searchResult.songs.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Songs',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${state.searchResult.songs.length} ${'result'.pluralize(state.searchResult.songs.length)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          for (var song in state.searchResult.songs)
                            SongListTile(
                              song: song,
                              songs: state.searchResult.songs,
                            ),
                        ],
                      ),

                    // albums
                    if (state is SearchLoaded &&
                        state.searchResult.albums.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Albums',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${state.searchResult.albums.length} ${'result'.pluralize(state.searchResult.albums.length)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          for (var album in state.searchResult.albums)
                            ListTile(
                              leading: QueryArtworkWidget(
                                id: album.id,
                                type: ArtworkType.ALBUM,
                                nullArtworkWidget: const Icon(Icons.album),
                              ),
                              title: Text(album.album),
                              subtitle: Text(album.artist ?? 'Unknown'),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/album',
                                  arguments: album,
                                );
                              },
                            ),
                        ],
                      ),

                    // artists
                    if (state is SearchLoaded &&
                        state.searchResult.artists.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Artists',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${state.searchResult.artists.length} ${'result'.pluralize(state.searchResult.artists.length)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          for (var artist in state.searchResult.artists)
                            ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                                child: const Icon(
                                  Icons.person_outlined,
                                ),
                              ),
                              title: Text(artist.artist),
                              subtitle: Text(
                                '${artist.numberOfTracks} ${'song'.pluralize(artist.numberOfTracks ?? 0)}',
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/artist',
                                  arguments: artist,
                                );
                              },
                            ),
                        ],
                      ),

                    // genres
                    if (state is SearchLoaded &&
                        state.searchResult.genres.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Genres',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${state.searchResult.genres.length} ${'result'.pluralize(state.searchResult.genres.length)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          for (var genre in state.searchResult.genres)
                            ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                                child: const Icon(
                                  Icons.library_music_outlined,
                                ),
                              ),
                              title: Text(genre.genre),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/genre',
                                  arguments: genre,
                                );
                              },
                            ),
                        ],
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
