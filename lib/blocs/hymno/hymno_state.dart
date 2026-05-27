part of 'hymno_bloc.dart';

abstract class HymnoState extends Equatable {
  const HymnoState();

  @override
  List<Object?> get props => [];
}

class HymnoInitial extends HymnoState {
  const HymnoInitial();
}

class HymnoLoading extends HymnoState {
  const HymnoLoading();
}

class HymnoData extends HymnoState {
  final Himno himno;

  const HymnoData(this.himno);

  @override
  List<Object?> get props => [himno];
}

class HymnoError extends HymnoState {
  final String message;

  const HymnoError(this.message);

  @override
  List<Object?> get props => [message];
}
