import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:meloplay/src/core/theme/themes.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(theme: Themes.getThemeName())) {
    on<ChangeTheme>((event, emit) async {
      await Themes.setTheme(event.theme);
      emit(state.copyWith(theme: event.theme));
    });
  }
}
