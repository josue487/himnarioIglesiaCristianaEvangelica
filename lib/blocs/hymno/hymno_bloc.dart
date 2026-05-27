import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/himno.dart';
import '../../services/database_service.dart';

part 'hymno_event.dart';
part 'hymno_state.dart';

class HymnoBloc extends Bloc<HymnoEvent, HymnoState> {
  final DatabaseService _db;
  int _currentId = 0;

  HymnoBloc(this._db) : super(const HymnoInitial()) {
    on<HymnoCargar>(_onCargar);
    on<HymnoIrAnterior>(_onAnterior);
    on<HymnoIrSiguiente>(_onSiguiente);
    on<HymnoToggleFavorito>(_onToggleFavorito);
  }

  int get currentId => _currentId;

  Future<void> _onCargar(HymnoCargar event, Emitter<HymnoState> emit) async {
    await _cargarDesdeId(event.id, emit);
  }

  Future<void> _onAnterior(
    HymnoIrAnterior event,
    Emitter<HymnoState> emit,
  ) async {
    if (_currentId > 1) await _cargarDesdeId(_currentId - 1, emit);
  }

  Future<void> _onSiguiente(
    HymnoIrSiguiente event,
    Emitter<HymnoState> emit,
  ) async {
    if (_currentId < 517) await _cargarDesdeId(_currentId + 1, emit);
  }

  Future<void> _onToggleFavorito(
    HymnoToggleFavorito event,
    Emitter<HymnoState> emit,
  ) async {
    if (state is! HymnoData) return;
    final himno = (state as HymnoData).himno;
    final nuevoEstado = await _db.cambiarEstadoFavorito(himno.id);
    emit(HymnoData(himno.copyWith(favorito: nuevoEstado)));
  }

  Future<void> _cargarDesdeId(int id, Emitter<HymnoState> emit) async {
    emit(const HymnoLoading());
    try {
      final himno = await _db.buscarHimno(id);
      if (himno.cancion.isEmpty) {
        emit(const HymnoError('No existe el himno buscado'));
        return;
      }
      _currentId = id;
      emit(HymnoData(himno));
    } catch (e) {
      emit(HymnoError(e.toString()));
    }
  }
}
