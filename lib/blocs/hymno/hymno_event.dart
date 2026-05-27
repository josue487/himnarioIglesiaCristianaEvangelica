part of 'hymno_bloc.dart';

abstract class HymnoEvent extends Equatable {
  const HymnoEvent();

  @override
  List<Object?> get props => [];
}

class HymnoCargar extends HymnoEvent {
  final int id;

  const HymnoCargar(this.id);

  @override
  List<Object?> get props => [id];
}

class HymnoIrAnterior extends HymnoEvent {
  const HymnoIrAnterior();
}

class HymnoIrSiguiente extends HymnoEvent {
  const HymnoIrSiguiente();
}

class HymnoToggleFavorito extends HymnoEvent {
  const HymnoToggleFavorito();
}
