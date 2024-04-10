import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

import 'package:meloplay/src/data/services/hive_box.dart';

part 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit() : super(ScanInitial());

  Future<void> setDuration(int durationValue) async {
    emit(ScanInitial());
    await Hive.box(HiveBox.boxName).put(
      HiveBox.minSongDurationKey,
      durationValue,
    );
    emit(ScanSettingsUpdated());
  }

  Future<void> setSize(int sizeValue) async {
    emit(ScanInitial());
    await Hive.box(HiveBox.boxName).put(
      HiveBox.minSongSizeKey,
      sizeValue,
    );
    emit(ScanSettingsUpdated());
  }
}
