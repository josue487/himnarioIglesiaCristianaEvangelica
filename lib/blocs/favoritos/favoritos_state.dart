part of 'favoritos_bloc.dart';

abstract class FavoritosState extends Equatable {
  const FavoritosState();

  @override
  List<Object?> get props => [];
}

class FavoritosInitial extends FavoritosState {
  const FavoritosInitial();
}

class FavoritosLoading extends FavoritosState {
  const FavoritosLoading();
}

class FavoritosData extends FavoritosState {
  final List<Himno> favoritos;

  const FavoritosData(this.favoritos);

  @override
  List<Object?> get props => [favoritos];
}

class FavoritosError extends FavoritosState {
  final String message;

  const FavoritosError(this.message);

  @override
  List<Object?> get props => [message];
}
