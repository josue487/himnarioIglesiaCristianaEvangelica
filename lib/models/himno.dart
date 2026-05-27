import 'package:equatable/equatable.dart';

class Himno extends Equatable {
  final int id;
  final String titulo;
  final String cancion;
  final String coro;
  final String notas;
  final String versiculo;
  final bool favorito;
  final String notasCoro;

  const Himno({
    this.id = 0,
    this.titulo = '',
    this.cancion = '',
    this.coro = '',
    this.notas = '',
    this.versiculo = '',
    this.favorito = false,
    this.notasCoro = '',
  });

  factory Himno.fromMap(Map<String, dynamic> map) {
    return Himno(
      id: map['id'] as int? ?? 0,
      cancion: map['cancion'] as String? ?? '',
      coro: map['coro'] as String? ?? '',
      titulo: map['titulo'] as String? ?? '',
      versiculo: map['versiculo'] as String? ?? '',
      notas: map['notas'] as String? ?? '',
      favorito: (map['favorito'] as int? ?? 0) == 1,
      notasCoro: map['notasCoro'] as String? ?? '',
    );
  }

  Himno copyWith({
    int? id,
    String? titulo,
    String? cancion,
    String? coro,
    String? notas,
    String? versiculo,
    bool? favorito,
    String? notasCoro,
  }) {
    return Himno(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      cancion: cancion ?? this.cancion,
      coro: coro ?? this.coro,
      notas: notas ?? this.notas,
      versiculo: versiculo ?? this.versiculo,
      favorito: favorito ?? this.favorito,
      notasCoro: notasCoro ?? this.notasCoro,
    );
  }

  @override
  List<Object?> get props =>
      [id, titulo, cancion, coro, notas, versiculo, favorito, notasCoro];
}
