part of 'player_bloc.dart';

@immutable
sealed class PlayerState {}

final class PlayerInitial extends PlayerState {}

// toggle favorite
final class ToggleFavoriteInProgress extends PlayerState {}

final class ToggleFavoriteSuccess extends PlayerState {}

final class ToggleFavoriteFailure extends PlayerState {}

// add to recently played
final class AddToRecentlyPlayedInProgress extends PlayerState {}

final class AddToRecentlyPlayedSuccess extends PlayerState {}

final class AddToRecentlyPlayedError extends PlayerState {}
