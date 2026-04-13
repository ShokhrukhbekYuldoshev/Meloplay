import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/core/extensions/string_extensions.dart';
import 'package:meloplay/src/data/services/hive_box.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({super.key});
  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  int currentSortType = Hive.box(
    HiveBox.boxName,
  ).get(HiveBox.songSortTypeKey, defaultValue: SongSortType.TITLE.index);
  int currentOrderType = Hive.box(
    HiveBox.boxName,
  ).get(HiveBox.songOrderTypeKey, defaultValue: OrderType.ASC_OR_SMALLER.index);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Sort by',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          for (final songSortType in SongSortType.values)
            RadioGroup<int>(
              groupValue: currentSortType,
              onChanged: (value) {
                setState(() {
                  currentSortType = value!;
                });
              },
              child: RadioListTile<int>(
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                value: songSortType.index,
                title: Text(
                  songSortType.name.capitalize().replaceAll('_', ' '),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Order by',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          for (final orderType in OrderType.values)
            RadioGroup<int>(
              groupValue: currentOrderType,
              onChanged: (value) {
                setState(() {
                  currentOrderType = value!;
                });
              },
              child: RadioListTile<int>(
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                value: orderType.index,
                title: Text(orderType.name.capitalize().replaceAll('_', ' ')),
              ),
            ),

          const SizedBox(height: 16),
          // cancel, apply button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.read<HomeBloc>().add(
                        SortSongsEvent(currentSortType, currentOrderType),
                      );
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
