part of 'favoritos_bloc.dart';

abstract class FavoritosEvent extends Equatable {
  const FavoritosEvent();

  @override
  List<Object?> get props => [];
}

class FavoritosCargar extends FavoritosEvent {
  const FavoritosCargar();
}
