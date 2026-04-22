part of 'scan_cubit.dart';

@immutable
sealed class ScanState {}

final class ScanInitial extends ScanState {}

final class ScanLoading extends ScanState {}

final class ScanSettingsUpdated extends ScanState {}
