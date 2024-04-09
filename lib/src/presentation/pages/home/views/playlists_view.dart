import 'package:flutter/material.dart';
import 'package:meloplay/src/core/constants/assets.dart';
import 'package:meloplay/src/core/router/app_router.dart';

class PlaylistsView extends StatefulWidget {
  const PlaylistsView({super.key});

  @override
  State<PlaylistsView> createState() => _PlaylistsViewState();
}

class _PlaylistsViewState extends State<PlaylistsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final cards = [
      const SizedBox(width: 16),
      _buildCard(
        image: Assets.heart,
        label: 'Favorites',
        icon: Icons.favorite_border_outlined,
        color: Colors.red,
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.favoritesRoute,
          );
        },
      ),
      const SizedBox(width: 16),
      _buildCard(
        image: Assets.earphones,
        label: 'Recents',
        icon: Icons.history_outlined,
        color: const Color(0xFFF321D0),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.recentsRoute,
          );
        },
      ),
      const SizedBox(width: 16),
    ];

    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...cards],
        ),
      ],
    );
  }

  _buildCard({
    required String image,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.grey.withOpacity(0.2),
          child: Column(
            children: [
              Image.asset(
                image,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 4),
                  Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
