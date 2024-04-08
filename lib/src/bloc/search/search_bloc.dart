import 'package:bloc/bloc.dart';
import 'package:meloplay/src/data/models/search_result.dart';
import 'package:meloplay/src/data/repositories/search_repository.dart';
import 'package:meta/meta.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required SearchRepository repository}) : super(SearchInitial()) {
    on<SearchQueryChanged>((event, emit) async {
      emit(SearchLoading());
      final result = await repository.search(event.query);
      emit(SearchLoaded(searchResult: result));
    });
  }
}
