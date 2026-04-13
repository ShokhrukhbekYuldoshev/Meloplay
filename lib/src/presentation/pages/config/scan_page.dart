import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/bloc/scan/scan_cubit.dart';
import 'package:meloplay/src/core/constants/assets.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/data/services/hive_box.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // in seconds
  late int durationValue;
  final List<int> durationGroupValue = [0, 15, 30, 60, 120, 300];
  final Map<int, String> durationLabels = {
    0: 'None',
    15: '15 seconds',
    30: '30 seconds',
    60: '1 minute',
    120: '2 minutes',
    300: '5 minutes',
  };

  // in KB
  late int sizeValue;
  final List<int> sizeGroupValue = [0, 50, 100, 200, 500, 1024];
  final Map<int, String> sizeLabels = {
    0: 'None',
    50: '50 KB',
    100: '100 KB',
    200: '200 KB',
    500: '500 KB',
    1024: '1 MB',
  };

  @override
  void initState() {
    super.initState();
    final box = Hive.box(HiveBox.boxName);
    durationValue = box.get(HiveBox.minSongDurationKey, defaultValue: 0);
    sizeValue = box.get(HiveBox.minSongSizeKey, defaultValue: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.getTheme().secondaryColor,
      appBar: AppBar(
        backgroundColor: Themes.getTheme().primaryColor,
        elevation: 0,
        title: const Text('Scan Settings'),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                durationValue = 0;
                sizeValue = 0;
                context.read<ScanCubit>().setDuration(0);
                context.read<ScanCubit>().setSize(0);
              });
              Fluttertoast.showToast(
                msg: 'Reset to default',
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset'),
          ),
        ],
      ),
      body: Ink(
        decoration: BoxDecoration(gradient: Themes.getTheme().gradient),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // Scanning animation
            Center(
              child: Lottie.asset(
                Assets.scanningAnimation,
                width: 200,
                height: 200,
              ),
            ),

            const SizedBox(height: 8),

            // Info card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Configure minimum duration and file size to filter out short audio files, ringtones, and notification sounds.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Duration Section
            _buildSectionHeader(
              context,
              title: 'Minimum Duration',
              icon: Icons.timer_outlined,
              currentValue: _getDurationText(durationValue),
            ),

            const SizedBox(height: 8),

            // Duration options
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 0,
              color: Colors.white.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: durationGroupValue.map((value) {
                    return _buildRadioTile(
                      value: value,
                      groupValue: durationValue,
                      label: durationLabels[value]!,
                      onChanged: (newValue) {
                        setState(() {
                          durationValue = newValue;
                          context.read<ScanCubit>().setDuration(durationValue);
                          context.read<HomeBloc>().add(GetSongsEvent());
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Size Section
            _buildSectionHeader(
              context,
              title: 'Minimum File Size',
              icon: Icons.storage_outlined,
              currentValue: _getSizeText(sizeValue),
            ),

            const SizedBox(height: 8),

            // Size options
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 0,
              color: Colors.white.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: sizeGroupValue.map((value) {
                    return _buildRadioTile(
                      value: value,
                      groupValue: sizeValue,
                      label: sizeLabels[value]!,
                      onChanged: (newValue) {
                        setState(() {
                          sizeValue = newValue;
                          context.read<ScanCubit>().setSize(sizeValue);
                          context.read<HomeBloc>().add(GetSongsEvent());
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String currentValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
            ),
            child: Text(
              currentValue,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile({
    required int value,
    required int groupValue,
    required String label,
    required Function(int) onChanged,
  }) {
    return RadioListTile<int>(
      value: value,
      groupValue: groupValue,
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      title: Text(label),
      activeColor: Theme.of(context).colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  String _getDurationText(int seconds) {
    if (seconds == 0) return 'None';
    if (seconds < 60) return '$seconds sec';
    if (seconds == 60) return '1 min';
    if (seconds < 3600) return '${seconds ~/ 60} min';
    return '${seconds ~/ 3600} hr';
  }

  String _getSizeText(int kb) {
    if (kb == 0) return 'None';
    if (kb >= 1024) return '${kb ~/ 1024} MB';
    return '$kb KB';
  }
}
