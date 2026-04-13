import 'package:flutter/material.dart';
import 'package:meloplay/src/presentation/pages/player/player_page.dart';

void showPlayerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,

    isDismissible: true, // Keep dismissible on tap outside or back button
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 1,
      minChildSize: 1,
      builder: (context, scrollController) {
        return PlayerPage(scrollController: scrollController);
      },
    ),
  );
}
