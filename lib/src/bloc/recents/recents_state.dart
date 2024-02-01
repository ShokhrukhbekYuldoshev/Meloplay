part of 'recents_bloc.dart';

@immutable
sealed class RecentsState {}

final class RecentsInitial extends RecentsState {}

final class RecentsLoading extends RecentsState {}

final class RecentsLoaded extends RecentsState {
  final List<SongModel> songs;

  RecentsLoaded(this.songs);
}

final class RecentsError extends RecentsState {
  final String message;

  RecentsError(this.message);
}
