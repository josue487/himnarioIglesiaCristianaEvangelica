import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../models/himno.dart';
import '../../services/database_service.dart';

part 'search_event.dart';
part 'search_state.dart';

EventTransformer<T> _debounceSwitch<T>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final DatabaseService _db;

  SearchBloc(this._db) : super(const SearchInitial()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: _debounceSwitch(const Duration(milliseconds: 300)),
    );
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }
    emit(const SearchLoading());
    try {
      final results = await _db.buscarPorTexto(event.query.trim());
      emit(SearchLoaded(results: results, query: event.query.trim()));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(const SearchInitial());
  }
}
