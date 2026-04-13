import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meloplay/src/bloc/theme/theme_bloc.dart';
import 'package:meloplay/src/core/router/app_router.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
  }

  Future<void> _getPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Could not open link',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _shareApp() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text:
              'Check out Meloplay Music Player!\n\n'
              'Download it from GitHub: https://github.com/ShokhrukhbekYuldoshev/Meloplay/releases\n\n',
          subject: 'Meloplay Music Player',
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Could not share app',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
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
            title: const Text('Settings'),
            centerTitle: false,
          ),
          body: Ink(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
            decoration: BoxDecoration(gradient: Themes.getTheme().gradient),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // Playback Section
                _buildSectionHeader('Playback'),

                // Equalizer
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.equalizer, size: 20),
                  ),
                  title: const Text('Equalizer'),
                  subtitle: const Text('Adjust sound settings'),
                  onTap: () {
                    // TODO: Navigate to equalizer
                    Fluttertoast.showToast(msg: 'Coming soon');
                  },
                ),

                // Sleep Timer
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.timer_outlined, size: 20),
                  ),
                  title: const Text('Sleep Timer'),
                  subtitle: const Text('Stop playback after time'),
                  onTap: () {
                    // TODO: Show sleep timer dialog
                    Fluttertoast.showToast(msg: 'Coming soon');
                  },
                ),

                const Divider(height: 32, color: Colors.white24),

                // Library Section
                _buildSectionHeader('Library'),

                // Scan music
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.wifi_tethering_outlined, size: 20),
                  ),
                  title: const Text('Scan Music'),
                  subtitle: const Text(
                    'Ignore songs that don\'t meet requirements',
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.scanRoute);
                  },
                ),

                // Appearance Section
                _buildSectionHeader('Appearance'),

                // Theme
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.color_lens_outlined, size: 20),
                  ),
                  title: const Text('Theme'),
                  subtitle: const Text('Select a theme for the app'),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.themesRoute);
                  },
                ),

                const Divider(height: 32, color: Colors.white24),

                // About Section
                _buildSectionHeader('About'),

                // GitHub
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.code_outlined, size: 20),
                  ),
                  title: const Text('GitHub Repository'),
                  subtitle: const Text('View source code on GitHub'),
                  onTap: () {
                    _launchUrl(
                      'https://github.com/ShokhrukhbekYuldoshev/Meloplay',
                    );
                  },
                ),

                // Share App
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.share_outlined, size: 20),
                  ),
                  title: const Text('Share App'),
                  subtitle: const Text('Share Meloplay with friends'),
                  onTap: _shareApp,
                ),

                // Rate App
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.star_outline, size: 20),
                  ),
                  title: const Text('Rate App'),
                  subtitle: const Text('Rate Meloplay on GitHub'),
                  onTap: () {
                    _launchUrl(
                      'https://github.com/ShokhrukhbekYuldoshev/Meloplay',
                    );
                  },
                ),

                // Version Info
                _buildPackageInfoTile(context),

                const SizedBox(height: 32),

                // Footer
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Made with ❤️',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Open source music player',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  ListTile _buildPackageInfoTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withValues(alpha: 0.1),
        ),
        child: const Icon(Icons.info_outline, size: 20),
      ),
      title: const Text('Version'),
      subtitle: Text(_packageInfo.version),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.info_outline,
          size: 18,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
      onTap: () {
        _showVersionDialog();
      },
    );
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('About Meloplay'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.apps, size: 20),
              title: const Text('App Name'),
              subtitle: Text(_packageInfo.appName),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.code, size: 20),
              title: const Text('Version'),
              subtitle: Text(
                '${_packageInfo.version} (${_packageInfo.buildNumber})',
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.build, size: 20),
              title: const Text('Package'),
              subtitle: Text(_packageInfo.packageName),
            ),
            const Divider(),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.copyright, size: 20),
              title: Text('License'),
              subtitle: Text(
                'Attribution-NonCommercial-ShareAlike 4.0 International',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _launchUrl('https://github.com/ShokhrukhbekYuldoshev/Meloplay');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('View on GitHub'),
          ),
        ],
      ),
    );
  }
}
