import 'package:flutter/material.dart';
import 'package:meloplay/presentation/utils/theme/themes.dart';
import 'package:meloplay/presentation/utils/assets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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
    return Scaffold(
      backgroundColor: Themes.getTheme().secondaryColor,
      appBar: AppBar(
        backgroundColor: Themes.getTheme().primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
          ),
        ),
        title: const Text(
          'About',
        ),
      ),
      // package info
      bottomNavigationBar: Container(
        color: Themes.getTheme().secondaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _packageInfo.appName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version ${_packageInfo.version}+${_packageInfo.buildNumber}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Ink(
        padding: const EdgeInsets.fromLTRB(
          32,
          16,
          32,
          16,
        ),
        decoration: BoxDecoration(
          gradient: Themes.getTheme().linearGradient,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // logo
              Center(
                child: Hero(
                  tag: 'logo',
                  child: Image.asset(
                    Assets.logo,
                    width: 128,
                    height: 128,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Meloplay',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Meloplay is an open source music player app that is built with Flutter. It is a simple music player app that can play music from your local storage.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              // github
              const Text(
                'Source Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  launchUrlString(Links.sourceCode);
                },
                child: const Text("Github"),
              ),
              const SizedBox(height: 32),
              const Text(
                'Contact',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  launchUrlString('mailto:shokhrukhbekdev@gmail.com');
                },
                child: const Text("Email"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
