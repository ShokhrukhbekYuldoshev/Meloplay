part of 'recents_bloc.dart';

@immutable
sealed class RecentsEvent {}

class FetchRecents extends RecentsEvent {}
