import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.getTheme().secondaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Themes.getTheme().primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            focusNode: _focusNode,
            controller: searchController,
            onChanged: (value) {
              context.read<SearchBloc>().add(SearchQueryChanged(value.trim()));
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search songs, artists, albums...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          if (searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                searchController.clear();
                context.read<SearchBloc>().add(SearchQueryChanged(''));
                _focusNode.requestFocus();
              },
              icon: const Icon(Icons.clear),
              tooltip: 'Clear',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Ink(
        decoration: BoxDecoration(gradient: Themes.getTheme().gradient),
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (searchController.text.isEmpty) {
              return _buildRecentSearches();
            }

            if (state is SearchError) {
              return _buildErrorState(state.message);
            }

            if (state is SearchLoading) {
              return _buildLoadingState();
            }

            if (state is SearchLoaded) {
              final hasResults =
                  state.searchResult.songs.isNotEmpty ||
                  state.searchResult.albums.isNotEmpty ||
                  state.searchResult.artists.isNotEmpty ||
                  state.searchResult.genres.isNotEmpty;

              if (!hasResults) {
                return _buildNoResultsState(searchController.text);
              }

              return _buildSearchResults(state);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for music',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find your favorite songs, artists, and albums',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Searching...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<SearchBloc>().add(
                SearchQueryChanged(searchController.text.trim()),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No matches for "$query"',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchLoaded state) {
    return AnimationLimiter(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Songs Section
            if (state.searchResult.songs.isNotEmpty)
              _buildSection(
                title: 'Songs',
                count: state.searchResult.songs.length,
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 500),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: state.searchResult.songs.map((song) {
                      return SongListTile(
                        song: song,
                        songs: state.searchResult.songs,
                        showAlbumArt: true,
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Albums Section
            if (state.searchResult.albums.isNotEmpty)
              _buildSection(
                title: 'Albums',
                count: state.searchResult.albums.length,
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 500),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: state.searchResult.albums.map((album) {
                      return _buildAlbumTile(album);
                    }).toList(),
                  ),
                ),
              ),

            // Artists Section
            if (state.searchResult.artists.isNotEmpty)
              _buildSection(
                title: 'Artists',
                count: state.searchResult.artists.length,
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 500),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: state.searchResult.artists.map((artist) {
                      return _buildArtistTile(artist);
                    }).toList(),
                  ),
                ),
              ),

            // Genres Section
            if (state.searchResult.genres.isNotEmpty)
              _buildSection(
                title: 'Genres',
                count: state.searchResult.genres.length,
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 500),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: state.searchResult.genres.map((genre) {
                      return _buildGenreTile(genre);
                    }).toList(),
                  ),
                ),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required int count,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count ${'result'.pluralize(count)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        child,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAlbumTile(AlbumModel album) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, '/album', arguments: album);
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: QueryArtworkWidget(
            keepOldArtwork: true,
            id: album.id,
            type: ArtworkType.ALBUM,
            size: 200,
            nullArtworkWidget: Container(
              width: 50,
              height: 50,
              color: Colors.grey.withValues(alpha: 0.2),
              child: Icon(
                Icons.album,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        title: Text(
          album.album,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          album.artist ?? 'Unknown Artist',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildArtistTile(ArtistModel artist) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, '/artist', arguments: artist);
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: QueryArtworkWidget(
            keepOldArtwork: true,
            id: artist.id,
            type: ArtworkType.ARTIST,
            size: 200,
            nullArtworkWidget: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        title: Text(
          artist.artist,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${artist.numberOfTracks} ${'song'.pluralize(artist.numberOfTracks ?? 0)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildGenreTile(GenreModel genre) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, '/genre', arguments: genre);
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Icon(
            Icons.category_outlined,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
        title: Text(
          genre.genre,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
