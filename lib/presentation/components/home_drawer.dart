import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloplay/bloc/theme/theme_bloc.dart';
import 'package:meloplay/presentation/utils/app_router.dart';
import 'package:meloplay/presentation/utils/assets.dart';
import 'package:meloplay/presentation/utils/theme/themes.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return DrawerHeader(
                decoration: BoxDecoration(
                  color: Themes.getTheme().primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Image.asset(
                        Assets.logo,
                        height: 64,
                        width: 64,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      'Meloplay',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.aboutRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.settingsRoute);
            },
          ),
        ],
      ),
    );
  }
}
