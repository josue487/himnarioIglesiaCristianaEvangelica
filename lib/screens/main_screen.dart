import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../blocs/search/search_bloc.dart';
import '../config.dart';
import '../models/himno.dart';
import '../services/database_service.dart';
import 'busqueda_screen.dart';
import 'favoritos_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(DatabaseService()),
      child: const _MainView(),
    );
  }
}

class _MainView extends StatefulWidget {
  const _MainView();

  @override
  State<_MainView> createState() => _MainViewState();
}

class _MainViewState extends State<_MainView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    context.read<SearchBloc>().add(SearchQueryChanged(value));
  }

  void _onClear() {
    _controller.clear();
    context.read<SearchBloc>().add(const SearchCleared());
    _focusNode.requestFocus();
  }

  void _openHimno(int id) {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BusquedaScreen(initialId: id)),
    );
  }

  void _openFavoritos() {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritosScreen()),
    );
  }

  void _openSettings() {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final w = MediaQuery.of(context).size.width;
    final hPad = (w * 0.05).clamp(16.0, 32.0);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(topPad, hPad),
          _buildSearchBar(hPad),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) => switch (state) {
                SearchInitial() => _buildWelcome(context, hPad),
                SearchLoading() => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                SearchLoaded(:final results) when results.isEmpty =>
                  _buildEmpty(),
                SearchLoaded(:final results) => _buildResults(results, hPad),
                SearchError(:final message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                _ => const SizedBox(),
              },
            ),
          ),
          SafeArea(
            top: false,
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPad, double hPad) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade900, Colors.indigo.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(hPad, topPad + 16, hPad - 4, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.music_note, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Himnario ICE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'Iglesia Cristiana Evangélica',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.tune, color: Colors.white70, size: 22),
            tooltip: 'Configuración',
          ),
          IconButton(
            onPressed: _openFavoritos,
            icon: const Icon(Icons.star, color: Colors.amber, size: 28),
            tooltip: 'Favoritos',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double hPad) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade500],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 16),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onQueryChanged,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Busca por número o título...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: ValueListenableBuilder(
            valueListenable: _controller,
            builder: (_, value, __) => value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: _onClear,
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildWelcome(BuildContext context, double hPad) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded, size: 72, color: Colors.indigo.shade200),
                const SizedBox(height: 20),
                Text(
                  'Busca un himno',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Por número (ej. 42) o parte del título',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Text(
                  '517 himnos disponibles',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ),
        _buildDonationCard(context, hPad),
      ],
    );
  }

  void _thankYou(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Gracias por tu colaboracion. Dios te bendiga!'),
        backgroundColor: Colors.indigo.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildDonationCard(BuildContext context, double hPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.indigo.shade100),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite_outline, size: 15, color: Colors.indigo.shade400),
                const SizedBox(width: 6),
                Text(
                  'COLABORAR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade500,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Esta app es gratuita. Si te resulta util, podes colaborar voluntariamente.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 12),
            // Fila Argentina
            Row(
              children: [
                Icon(Icons.account_balance_outlined, size: 18, color: Colors.indigo.shade400),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Argentina',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                      Text(
                        kDonationAlias,
                        style: TextStyle(fontSize: 12, color: Colors.indigo.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: kDonationAlias));
                    _thankYou(context);
                  },
                  icon: const Icon(Icons.copy_outlined, size: 15),
                  label: const Text('Copiar', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.indigo.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Fila Internacional
            Row(
              children: [
                Icon(Icons.public_outlined, size: 18, color: Colors.indigo.shade400),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Internacional',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                      Text(
                        'PayPal  @josue487pp',
                        style: TextStyle(fontSize: 12, color: Colors.indigo.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await launchUrl(
                      Uri.parse(kDonationPaypalUrl),
                      mode: LaunchMode.externalApplication,
                    );
                    if (context.mounted) _thankYou(context);
                  },
                  icon: const Icon(Icons.open_in_new, size: 15),
                  label: const Text('Abrir', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.indigo.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No se encontraron himnos',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(List<Himno> results, double hPad) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
      itemCount: results.length,
      itemBuilder: (_, index) => _HimnoCard(
        himno: results[index],
        onTap: () => _openHimno(results[index].id),
      ),
    );
  }
}

class _HimnoCard extends StatelessWidget {
  final Himno himno;
  final VoidCallback onTap;

  const _HimnoCard({required this.himno, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${himno.id}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      himno.titulo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (himno.versiculo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        himno.versiculo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (himno.favorito)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(Icons.star, color: Colors.amber.shade600, size: 18),
                ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
