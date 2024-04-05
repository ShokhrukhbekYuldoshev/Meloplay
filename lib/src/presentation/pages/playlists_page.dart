import 'package:flutter/material.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final audioQuery = sl<OnAudioQuery>();
  final playlists = <PlaylistModel>[];
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchPlaylists();
  }

  Future<void> fetchPlaylists() async {
    final playlists = await audioQuery.queryPlaylists();
    setState(() {
      this.playlists.clear();
      this.playlists.addAll(playlists);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _buildFAB(context),
      body: _buildBody(context),
    );
  }

  Ink _buildBody(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        gradient: Themes.getTheme().linearGradient,
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];

          return ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/playlist',
                arguments: playlist,
              );
            },
            leading: QueryArtworkWidget(
              id: playlist.id,
              type: ArtworkType.PLAYLIST,
              artworkBorder: BorderRadius.circular(10),
              nullArtworkWidget: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.music_note_outlined,
                ),
              ),
            ),
            title: Text(
              playlist.playlist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${playlist.numOfSongs} song${playlist.numOfSongs == 1 ? '' : 's'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'rename') {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Rename playlist'),
                        content: Form(
                          key: formKey,
                          child: TextFormField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: 'Playlist name',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a playlist name';
                              }
                              if (playlists.any(
                                (playlist) =>
                                    playlist.playlist.toLowerCase() ==
                                    value.trim().toLowerCase(),
                              )) {
                                return 'Playlist already exists';
                              }
                              return null;
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }
                              await audioQuery.renamePlaylist(
                                playlist.id,
                                controller.text.trim(),
                              );
                              controller.clear();

                              await fetchPlaylists();
                              setState(() {});
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Rename'),
                          ),
                        ],
                      );
                    },
                  );
                } else if (value == 'delete') {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete playlist'),
                        content: const Text(
                          'Are you sure you want to delete this playlist?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await audioQuery.removePlaylist(
                                playlist.id,
                              );
                              setState(() {
                                playlists.removeAt(index);
                              });
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              itemBuilder: (context) {
                return [
                  // TODO: implement rename playlist
                  // const PopupMenuItem(
                  //   value: 'rename',
                  //   child: Text('Rename'),
                  // ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ];
              },
              child: const Icon(Icons.more_vert_outlined),
            ),
          );
        },
      ),
    );
  }

  FloatingActionButton _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Create playlist'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Playlist name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a playlist name';
                    }
                    if (playlists.any(
                      (playlist) =>
                          playlist.playlist.toLowerCase() ==
                          value.trim().toLowerCase(),
                    )) {
                      return 'Playlist already exists';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    await audioQuery.createPlaylist(
                      controller.text.trim(),
                    );
                    controller.clear();

                    await fetchPlaylists();
                    setState(() {});
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
      label: const Text('Create playlist'),
      icon: const Icon(Icons.add_outlined),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Themes.getTheme().primaryColor,
      title: const Text('Playlists'),
      actions: [
        IconButton(
          onPressed: () {
            fetchPlaylists();
            setState(() {});
          },
          icon: const Icon(Icons.refresh_outlined),
        ),
      ],
    );
  }
}
