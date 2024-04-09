import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:meloplay/src/bloc/scan/scan_cubit.dart';
import 'package:meloplay/src/core/constants/assets.dart';
import 'package:meloplay/src/core/extensions/string_extensions.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/data/services/hive_box.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // in seconds
  int durationValue = Hive.box(HiveBox.boxName).get(
    HiveBox.minSongDurationKey,
    defaultValue: 0,
  );
  List<int> durationGroupValue = [0, 15, 30, 60];

  // in KB
  int sizeValue = Hive.box(HiveBox.boxName).get(
    HiveBox.minSongSizeKey,
    defaultValue: 0,
  );
  List<int> sizeGroupValue = [0, 50, 100, 200, 500];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.getTheme().secondaryColor,
      appBar: AppBar(
        backgroundColor: Themes.getTheme().primaryColor,
        elevation: 0,
        title: const Text(
          'Scan',
        ),
      ),
      body: Ink(
        decoration: BoxDecoration(
          gradient: Themes.getTheme().linearGradient,
        ),
        child: ListView(
          children: [
            // scanning animation
            Lottie.asset(
              Assets.scanningAnimation,
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            // ignore duration less than value
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Ignore duration less than:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (int i = 0; i < durationGroupValue.length; i++)
              RadioListTile(
                title: Text(
                  '${durationGroupValue[i]} ${'second'.pluralize(durationGroupValue[i])}',
                ),
                value: durationGroupValue[i],
                groupValue: durationValue,
                onChanged: (value) {
                  setState(() {
                    durationValue = value as int;
                    context.read<ScanCubit>().setDuration(durationValue);
                  });
                },
              ),
            const SizedBox(height: 16),
            // ignore size less than value
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Ignore size less than:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (int i = 0; i < sizeGroupValue.length; i++)
              RadioListTile(
                title: Text(
                  '${sizeGroupValue[i]} ${'KB'.pluralize(sizeGroupValue[i])}',
                ),
                value: sizeGroupValue[i],
                groupValue: sizeValue,
                onChanged: (value) {
                  setState(() {
                    sizeValue = value as int;
                    context.read<ScanCubit>().setSize(sizeValue);
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
