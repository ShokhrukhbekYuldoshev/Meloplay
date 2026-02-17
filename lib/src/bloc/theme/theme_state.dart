part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final String theme;

  const ThemeState({required this.theme});

  ThemeState copyWith({String? theme}) {
    return ThemeState(theme: theme ?? this.theme);
  }

  @override
  List<Object> get props => [theme];
}
