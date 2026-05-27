import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/himno.dart';
import '../../services/database_service.dart';

part 'favoritos_event.dart';
part 'favoritos_state.dart';

class FavoritosBloc extends Bloc<FavoritosEvent, FavoritosState> {
  final DatabaseService _db;

  FavoritosBloc(this._db) : super(const FavoritosInitial()) {
    on<FavoritosCargar>(_onCargar);
  }

  Future<void> _onCargar(
    FavoritosCargar event,
    Emitter<FavoritosState> emit,
  ) async {
    emit(const FavoritosLoading());
    try {
      final favoritos = await _db.buscarFavoritos();
      emit(FavoritosData(favoritos));
    } catch (e) {
      emit(FavoritosError(e.toString()));
    }
  }
}
