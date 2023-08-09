import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meloplay/data/repositories/theme_repository.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial()) {
    final repository = ThemeRepository();
    on<ChangeTheme>((event, emit) async {
      emit(ThemeInitial());
      await repository.updateTheme(event.theme);
      emit(ThemeChanged(event.theme));
    });
  }
}
