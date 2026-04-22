import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloplay/src/features/player/bloc/player/player_bloc.dart';

class SleepTimerDialog extends StatefulWidget {
  const SleepTimerDialog({super.key});

  @override
  State<SleepTimerDialog> createState() => _SleepTimerDialogState();
}

class _SleepTimerDialogState extends State<SleepTimerDialog> {
  Duration _selectedDuration = const Duration(minutes: 30);
  bool _isCustom = false;

  // Custom duration values
  int _customHours = 0;
  int _customMinutes = 5;
  int _customSeconds = 0;

  final List<Map<String, dynamic>> _presets = [
    {
      'label': 'Off',
      'duration': Duration.zero,
      'icon': Icons.power_settings_new,
    },
    {'label': '5 min', 'duration': Duration(minutes: 5), 'icon': Icons.timer},
    {'label': '10 min', 'duration': Duration(minutes: 10), 'icon': Icons.timer},
    {'label': '15 min', 'duration': Duration(minutes: 15), 'icon': Icons.timer},
    {'label': '30 min', 'duration': Duration(minutes: 30), 'icon': Icons.timer},
    {'label': '45 min', 'duration': Duration(minutes: 45), 'icon': Icons.timer},
    {'label': '1 hour', 'duration': Duration(hours: 1), 'icon': Icons.timer},
    {
      'label': '1.5 hours',
      'duration': Duration(minutes: 90),
      'icon': Icons.timer,
    },
    {'label': '2 hours', 'duration': Duration(hours: 2), 'icon': Icons.timer},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.bedtime,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sleep Timer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Preset chips
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ..._presets.map((preset) => _buildPresetChip(preset)),
                  _buildCustomChip(),
                ],
              ),

              // Custom duration picker
              if (_isCustom) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Custom Duration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Time picker row
                      Row(
                        children: [
                          // Hours
                          Expanded(
                            child: _buildTimeColumn(
                              label: 'Hours',
                              value: _customHours,
                              onChanged: (value) {
                                setState(() {
                                  _customHours = value;
                                  _updateCustomDuration();
                                });
                              },
                              maxValue: 23,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Minutes
                          Expanded(
                            child: _buildTimeColumn(
                              label: 'Minutes',
                              value: _customMinutes,
                              onChanged: (value) {
                                setState(() {
                                  _customMinutes = value;
                                  _updateCustomDuration();
                                });
                              },
                              maxValue: 59,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Seconds
                          Expanded(
                            child: _buildTimeColumn(
                              label: 'Seconds',
                              value: _customSeconds,
                              onChanged: (value) {
                                setState(() {
                                  _customSeconds = value;
                                  _updateCustomDuration();
                                });
                              },
                              maxValue: 59,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Quick add buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildQuickAddButton(
                            '+5 min',
                            () => _addTime(minutes: 5),
                          ),
                          _buildQuickAddButton(
                            '+15 min',
                            () => _addTime(minutes: 15),
                          ),
                          _buildQuickAddButton(
                            '+30 min',
                            () => _addTime(minutes: 30),
                          ),
                          _buildQuickAddButton(
                            '+1 hour',
                            () => _addTime(hours: 1),
                          ),
                          _buildQuickAddButton(
                            'Reset',
                            () => _resetCustomTime(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedDuration > Duration.zero) {
                          context.read<PlayerBloc>().add(
                            StartSleepTimer(_selectedDuration),
                          );
                        } else {
                          context.read<PlayerBloc>().add(CancelSleepTimer());
                        }
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _selectedDuration == Duration.zero
                            ? 'Turn Off'
                            : 'Start',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(Map<String, dynamic> preset) {
    final isSelected = !_isCustom && preset['duration'] == _selectedDuration;
    final duration = preset['duration'] as Duration;

    return FilterChip(
      label: Text(preset['label']),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _isCustom = false;
          if (selected) {
            _selectedDuration = duration;
          }
        });
      },
      avatar: Icon(preset['icon'], size: 18),
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildCustomChip() {
    final isSelected = _isCustom;

    return FilterChip(
      label: const Text('Custom'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _isCustom = selected;
          if (selected) {
            _updateCustomDuration();
          }
        });
      },
      avatar: const Icon(Icons.edit, size: 18),
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.2),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildTimeColumn({
    required String label,
    required int value,
    required Function(int) onChanged,
    required int maxValue,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_drop_up, size: 32),
                onPressed: () {
                  if (value < maxValue) {
                    onChanged(value + 1);
                  }
                },
              ),
              Text(
                value.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_drop_down, size: 32),
                onPressed: () {
                  if (value > 0) {
                    onChanged(value - 1);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  void _updateCustomDuration() {
    _selectedDuration = Duration(
      hours: _customHours,
      minutes: _customMinutes,
      seconds: _customSeconds,
    );
  }

  void _addTime({int hours = 0, int minutes = 0, int seconds = 0}) {
    setState(() {
      int totalSeconds = _customSeconds + seconds;
      int totalMinutes = _customMinutes + minutes + (totalSeconds ~/ 60);
      int totalHours = _customHours + hours + (totalMinutes ~/ 60);

      _customSeconds = totalSeconds % 60;
      _customMinutes = totalMinutes % 60;
      _customHours = totalHours % 24;

      _updateCustomDuration();
    });
  }

  void _resetCustomTime() {
    setState(() {
      _customHours = 0;
      _customMinutes = 0;
      _customSeconds = 0;
      _updateCustomDuration();
    });
  }
}
