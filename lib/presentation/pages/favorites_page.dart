import 'package:flutter/material.dart';
import 'package:meloplay/presentation/utils/theme/themes.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        padding: EdgeInsets.fromLTRB(
          32,
          MediaQuery.of(context).padding.top + 16,
          32,
          16,
        ),
        decoration: BoxDecoration(
          gradient: Themes.getTheme().linearGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // back button
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Favorites',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
