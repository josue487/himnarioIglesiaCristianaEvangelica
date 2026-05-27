import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../blocs/hymno/hymno_bloc.dart';
import '../blocs/settings/settings_bloc.dart';
import '../models/himno.dart';
import '../services/bible_service.dart';
import '../services/database_service.dart';

// Splits a raw versiculo string into individual "Book chapter:verse" refs.
// Supports: "Hechos 10.38 Isaías 12.5 Salmos 126.3"
//       and "Isaías 4.6, 32.2 Marcos 4.37, 6.51"
// The lazy *? on the word-repetition group prevents "Isaías Salmos" being
// consumed as a single book name when the next token is a chapter.verse.
List<String> _parseVerseRefs(String raw) {
  final pattern = RegExp(
    r'([1-3]?\s*[A-Za-záéíóúüñÁÉÍÓÚÜÑ][a-záéíóúüñA-ZÁÉÍÓÚÜÑ]*'
    r'(?:\s+[A-Za-záéíóúüñÁÉÍÓÚÜÑ][a-záéíóúüñA-ZÁÉÍÓÚÜÑ]*)*?)'
    r'\s+(\d+[.:]\d+(?:\s*,\s*\d+[.:]\d+)*)',
  );
  final refs = <String>[];
  for (final m in pattern.allMatches(raw)) {
    final book = m.group(1)!.trim();
    for (final part in m.group(2)!.split(RegExp(r'\s*,\s*'))) {
      refs.add('$book ${part.replaceAll('.', ':')}');
    }
  }
  return refs.isEmpty ? [raw] : refs;
}

class BusquedaScreen extends StatelessWidget {
  final int initialId;

  const BusquedaScreen({super.key, required this.initialId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HymnoBloc(DatabaseService())..add(HymnoCargar(initialId)),
      child: const _BusquedaView(),
    );
  }
}

class _BusquedaView extends StatelessWidget {
  const _BusquedaView();

  // /  → salto de línea
  // *  → insertar coro
  // +  → coro opcional (se omite, igual que en Android)
  // (negrita)/(finNegrita) → primer par renderizado en negrita+cursiva
  TextSpan _buildFormattedText(Himno himno) {
    final coroFinal = himno.coro.replaceAll('/', '\n');
    var cancion = himno.cancion.replaceAll('/', '\n');
    cancion = cancion.replaceAll('*', coroFinal);
    cancion = cancion.replaceAll('+', '');

    final inicio = cancion.indexOf('(negrita)');
    cancion = cancion.replaceAll('(negrita)', '');
    final fin = cancion.indexOf('(finNegrita)');
    cancion = cancion.replaceAll('(finNegrita)', '');

    if (inicio < 0 || fin < 0 || inicio >= fin) {
      return TextSpan(text: cancion);
    }
    return TextSpan(
      children: [
        TextSpan(text: cancion.substring(0, inicio)),
        TextSpan(
          text: cancion.substring(inicio, fin),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        TextSpan(text: cancion.substring(fin)),
      ],
    );
  }

  void _shareHimno(Himno himno) {
    final coro = himno.coro.replaceAll('/', '\n');
    var text = himno.cancion
        .replaceAll('/', '\n')
        .replaceAll('*', coro)
        .replaceAll('+', '')
        .replaceAll('(negrita)', '')
        .replaceAll('(finNegrita)', '');
    Share.share('Himno ${himno.id} — ${himno.titulo}\n\n${text.trim()}');
  }

  void _showVerseDialog(BuildContext context, String reference) {
    showDialog(
      context: context,
      builder: (_) => _VerseDialog(reference: reference),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final w = MediaQuery.of(context).size.width;
    final hPad = (w * 0.05).clamp(16.0, 32.0);

    return BlocConsumer<HymnoBloc, HymnoState>(
      listener: (context, state) {
        if (state is HymnoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final himno = state is HymnoData ? state.himno : null;
        final isLoading = state is HymnoLoading || state is HymnoInitial;
        final currentId = himno?.id ?? context.read<HymnoBloc>().currentId;

        return Scaffold(
          body: Column(
            children: [
              _buildAppBar(context, topPad, hPad, himno),
              if (himno != null && himno.versiculo.isNotEmpty)
                _buildVersiculoCard(context, hPad, himno.versiculo),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : himno == null
                        ? const SizedBox()
                        : BlocBuilder<SettingsBloc, SettingsState>(
                            builder: (context, settings) => SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 24),
                              child: SizedBox(
                                width: double.infinity,
                                child: Text.rich(
                                  _buildFormattedText(himno),
                                  style: TextStyle(
                                    fontSize: settings.fontSize,
                                    height: 1.8,
                                    color: settings.textColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
              ),
              _buildNavBar(context, currentId, himno != null && !isLoading),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    double topPad,
    double hPad,
    Himno? himno,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade900, Colors.indigo.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(4, topPad + 4, 4, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: himno == null
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Himno ${himno.id}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        himno.titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
          if (himno != null) ...[
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white70),
              onPressed: () => _shareHimno(himno),
            ),
            IconButton(
              icon: Icon(
                himno.favorito ? Icons.star : Icons.star_border,
                color: himno.favorito ? Colors.amber : Colors.white70,
                size: 28,
              ),
              onPressed: () =>
                  context.read<HymnoBloc>().add(const HymnoToggleFavorito()),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVersiculoCard(BuildContext context, double hPad, String versiculo) {
    return GestureDetector(
      onTap: () => _showVerseDialog(context, versiculo),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(hPad, 14, hPad, 0),
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.indigo.shade100),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                versiculo,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: Colors.indigo.shade700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.menu_book_outlined, size: 16, color: Colors.indigo.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, int currentId, bool enabled) {
    final bloc = context.read<HymnoBloc>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: enabled && currentId > 1
                      ? () => bloc.add(const HymnoIrAnterior())
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Anterior'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.indigo.shade700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  enabled ? '$currentId / 517' : '— / 517',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: enabled && currentId < 517
                          ? () => bloc.add(const HymnoIrSiguiente())
                          : null,
                      label: const Text('Siguiente'),
                      icon: const Icon(Icons.chevron_right),
                      iconAlignment: IconAlignment.end,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.indigo.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerseDialog extends StatefulWidget {
  final String reference;

  const _VerseDialog({required this.reference});

  @override
  State<_VerseDialog> createState() => _VerseDialogState();
}

class _VerseDialogState extends State<_VerseDialog> {
  List<(String, List<(int, String)>)>? _groups;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadVerses();
  }

  Future<void> _loadVerses() async {
    try {
      final refs = _parseVerseRefs(widget.reference);
      final service = BibleService();
      final groups = <(String, List<(int, String)>)>[];
      for (final ref in refs) {
        groups.add((ref, await service.lookupReference(ref)));
      }
      if (mounted) setState(() => _groups = groups);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade900, Colors.indigo.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: Colors.white70, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.reference,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _buildBody(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Reina-Valera 1960',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_error) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('No se pudo cargar el versículo.'),
      );
    }
    if (_groups == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    final showHeaders = _groups!.length > 1;
    final children = <Widget>[];
    for (final (ref, verses) in _groups!) {
      if (showHeaders) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            ref,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade500,
            ),
          ),
        ));
      }
      if (verses.isEmpty) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'No encontrado.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ));
      } else {
        for (final (num, text) in verses) {
          children.add(Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: Colors.grey.shade800,
                ),
                children: [
                  TextSpan(
                    text: '$num ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade400,
                      fontFeatures: const [FontFeature.superscripts()],
                    ),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ));
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
