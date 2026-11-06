import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/himno.dart';
import '../../services/database_service.dart';

part 'hymno_event.dart';
part 'hymno_state.dart';

class HymnoBloc extends Bloc<HymnoEvent, HymnoState> {
  final DatabaseService _db;
  int _currentId = 0;

  static const int firstHymn = 1;
  static const int lastHymn = 517;
  static const int firstChorus = 601;
  static const int lastChorus = 649;
  static int get chorusCount => lastChorus - firstChorus + 1;

  static bool isHymn(int id) => id >= firstHymn && id <= lastHymn;
  static bool isChorus(int id) => id >= firstChorus && id <= lastChorus;

  // Returns 1-based relative index for chorus display (601 → 1, 649 → 49).
  static int chorusIndex(int id) => id - firstChorus + 1;
  static String chorusLabel(int id) => chorusIndex(id).toString().padLeft(2, '0');

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
    final int prev;
    if (_currentId <= firstHymn) {
      prev = lastChorus; // himno 1 → coro 649 (circular)
    } else if (_currentId == firstChorus) {
      prev = lastHymn; // coro 601 → himno 517
    } else {
      prev = _currentId - 1;
    }
    await _cargarDesdeId(prev, emit);
  }

  Future<void> _onSiguiente(
    HymnoIrSiguiente event,
    Emitter<HymnoState> emit,
  ) async {
    final int next;
    if (_currentId == lastHymn) {
      next = firstChorus;
    } else if (_currentId == lastChorus) {
      next = firstHymn;
    } else {
      next = _currentId + 1;
    }
    await _cargarDesdeId(next, emit);
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
