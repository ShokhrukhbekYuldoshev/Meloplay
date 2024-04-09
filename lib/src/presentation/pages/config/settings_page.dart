import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloplay/src/bloc/theme/theme_bloc.dart';
import 'package:meloplay/src/core/router/app_router.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    _getPackageInfo();
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _getPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();

    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Themes.getTheme().secondaryColor,
          appBar: AppBar(
            backgroundColor: Themes.getTheme().primaryColor,
            elevation: 0,
            title: const Text(
              'Settings',
            ),
          ),
          body: Ink(
            padding: const EdgeInsets.fromLTRB(
              0,
              16,
              0,
              16,
            ),
            decoration: BoxDecoration(
              gradient: Themes.getTheme().linearGradient,
            ),
            child: ListView(
              children: [
                // scan music (ignores songs which don't satisfy the requirements)
                ListTile(
                  leading: const Icon(Icons.wifi_tethering_outlined),
                  title: const Text('Scan music'),
                  subtitle: const Text(
                    'Ignore songs which don\'t satisfy the requirements',
                  ),
                  onTap: () async {
                    Navigator.of(context).pushNamed(AppRouter.scanRoute);
                  },
                ),
                // language
                // TODO: add language selection
                // ListTile(
                //   leading: const Icon(Icons.language_outlined),
                //   title: const Text('Language'),
                //   onTap: () async {},
                // ),
                // theme
                ListTile(
                  leading: const Icon(Icons.color_lens_outlined),
                  title: const Text('Themes'),
                  onTap: () async {
                    Navigator.of(context).pushNamed(AppRouter.themesRoute);
                  },
                ),
                // package info
                _buildPackageInfoTile(context),
              ],
            ),
          ),
        );
      },
    );
  }

  ListTile _buildPackageInfoTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('Version'),
      subtitle: Text(
        _packageInfo.version,
      ),
      onTap: () async {
        // show package info
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Package info'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: ${_packageInfo.appName}',
                ),
                Text(
                  'Package: ${_packageInfo.packageName}',
                ),
                Text(
                  'Version: ${_packageInfo.version}',
                ),
                Text(
                  'Build number: ${_packageInfo.buildNumber}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
