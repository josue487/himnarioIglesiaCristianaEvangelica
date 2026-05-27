import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../blocs/settings/settings_bloc.dart';
import '../config.dart';
import '../models/himno.dart';
import '../services/database_service.dart';

// Opciones de color de texto (oscuro, legible sobre fondos claros)
const _textColorOptions = [
  (Color(0xFF212121), 'Negro'),
  (Color(0xFF424242), 'Grafito'),
  (Color(0xFF1A237E), 'Índigo'),
  (Color(0xFF4E342E), 'Caoba'),
  (Color(0xFF1B5E20), 'Bosque'),
  (Color(0xFF880E4F), 'Vino'),
];

// Opciones de color de fondo
const _bgColorOptions = [
  (Color(0xFFFFFFFF), 'Blanco'),
  (Color(0xFFF8F9FA), 'Perla'),
  (Color(0xFFFFFDE7), 'Crema'),
  (Color(0xFFE8F5E9), 'Menta'),
  (Color(0xFFE3F2FD), 'Celeste'),
  (Color(0xFFFCE4EC), 'Rosa'),
];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Himno? _himno15;

  @override
  void initState() {
    super.initState();
    DatabaseService().buscarHimno(15).then((h) {
      if (mounted) setState(() => _himno15 = h);
    });
  }

  String _previewText(Himno himno) {
    final coro = himno.coro.replaceAll('/', '\n');
    var text = himno.cancion.replaceAll('/', '\n');
    text = text.replaceAll('*', coro);
    text = text.replaceAll('+', '');
    text = text.replaceAll('(negrita)', '');
    text = text.replaceAll('(finNegrita)', '');
    return text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final w = MediaQuery.of(context).size.width;
    final hPad = (w * 0.05).clamp(16.0, 32.0);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return Scaffold(
          body: Column(
            children: [
              _buildHeader(context, topPad, hPad),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreview(settings),
                      const SizedBox(height: 20),
                      _buildFontSizeCard(context, settings),
                      const SizedBox(height: 16),
                      _buildTextColorCard(context, settings),
                      const SizedBox(height: 16),
                      _buildBgColorCard(context, settings),
                      const SizedBox(height: 24),
                      _buildResetButton(context),
                      const SizedBox(height: 12),
                      _buildShareButton(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SafeArea(top: false, child: const SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, double topPad, double hPad) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade900, Colors.indigo.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(4, topPad + 4, hPad, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Icon(Icons.tune, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Configuración',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(SettingsState settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Vista previa'),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: settings.backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade900, Colors.indigo.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: _himno15 == null
                      ? const Text(
                          'Himno 15',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : Row(
                          children: [
                            Text(
                              'Himno ${_himno15!.id}  ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _himno15!.titulo,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: _himno15 == null
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Text(
                          _previewText(_himno15!),
                          style: TextStyle(
                            fontSize: settings.fontSize,
                            color: settings.textColor,
                            height: 1.8,
                          ),
                          maxLines: 7,
                          overflow: TextOverflow.fade,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFontSizeCard(BuildContext context, SettingsState settings) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Tamaño de letra'),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'A',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.indigo.shade600,
                    inactiveTrackColor: Colors.grey.shade200,
                    thumbColor: Colors.indigo.shade600,
                    overlayColor: Colors.indigo.withOpacity(0.12),
                    valueIndicatorColor: Colors.indigo.shade700,
                    valueIndicatorTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    showValueIndicator: ShowValueIndicator.always,
                  ),
                  child: Slider(
                    value: settings.fontSize,
                    min: SettingsState.minFontSize,
                    max: SettingsState.maxFontSize,
                    divisions: 12,
                    label: '${settings.fontSize.toInt()} pt',
                    onChanged: (v) => context
                        .read<SettingsBloc>()
                        .add(SettingsFontSizeChanged(v)),
                  ),
                ),
              ),
              Text(
                'A',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${settings.fontSize.toInt()} pt',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextColorCard(BuildContext context, SettingsState settings) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Color del texto'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 18,
            runSpacing: 14,
            children: _textColorOptions.map((entry) {
              final (color, label) = entry;
              return _ColorChip(
                color: color,
                label: label,
                selected: settings.textColor == color,
                onTap: () => context
                    .read<SettingsBloc>()
                    .add(SettingsTextColorChanged(color)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBgColorCard(BuildContext context, SettingsState settings) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Color de fondo'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 18,
            runSpacing: 14,
            children: _bgColorOptions.map((entry) {
              final (color, label) = entry;
              return _ColorChip(
                color: color,
                label: label,
                selected: settings.backgroundColor == color,
                onTap: () => context
                    .read<SettingsBloc>()
                    .add(SettingsBgColorChanged(color)),
                hasBorder: true,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          const msg =
              'Te recomiendo el Himnario ICE — 517 himnos del Himnario Iglesia Cristiana Evangélica.';
          Share.share(
            kPlayStoreEnabled ? '$msg\n$kPlayStoreUrl' : msg,
          );
        },
        icon: const Icon(Icons.share_outlined),
        label: const Text('Compartir esta app'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.read<SettingsBloc>().add(const SettingsReset()),
        icon: const Icon(Icons.refresh),
        label: const Text('Restablecer valores predeterminados'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey.shade700,
          side: BorderSide(color: Colors.grey.shade300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _ColorChip extends StatelessWidget {
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool hasBorder;

  const _ColorChip({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final checkColor = color.computeLuminance() > 0.45 ? Colors.black54 : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.indigo.shade600 : Colors.grey.shade300,
                width: selected ? 3.0 : hasBorder ? 1.5 : 0.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                      ),
                    ],
            ),
            child: selected
                ? Icon(Icons.check_rounded, color: checkColor, size: 22)
                : null,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: selected ? Colors.indigo.shade700 : Colors.grey.shade600,
              fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

