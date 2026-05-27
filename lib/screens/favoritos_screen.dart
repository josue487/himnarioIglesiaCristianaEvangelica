import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/favoritos/favoritos_bloc.dart';
import '../models/himno.dart';
import '../services/database_service.dart';
import 'busqueda_screen.dart';

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          FavoritosBloc(DatabaseService())..add(const FavoritosCargar()),
      child: const _FavoritosView(),
    );
  }
}

class _FavoritosView extends StatelessWidget {
  const _FavoritosView();

  Future<void> _openHimno(BuildContext context, int id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BusquedaScreen(initialId: id)),
    );
    if (context.mounted) {
      context.read<FavoritosBloc>().add(const FavoritosCargar());
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final w = MediaQuery.of(context).size.width;
    final hPad = (w * 0.05).clamp(16.0, 32.0);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(topPad, hPad, context),
          Expanded(
            child: BlocBuilder<FavoritosBloc, FavoritosState>(
              builder: (context, state) => switch (state) {
                FavoritosLoading() || FavoritosInitial() =>
                  const Center(child: CircularProgressIndicator()),
                FavoritosData(:final favoritos) when favoritos.isEmpty =>
                  _buildEmpty(),
                FavoritosData(:final favoritos) =>
                  _buildList(context, favoritos, hPad),
                FavoritosError(:final message) => Center(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                _ => const SizedBox(),
              },
            ),
          ),
          SafeArea(top: false, child: const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPad, double hPad, BuildContext context) {
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
          const Icon(Icons.star, color: Colors.amber, size: 22),
          const SizedBox(width: 10),
          const Text(
            'Mis Favoritos',
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes favoritos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca la estrella en cualquier himno\npara agregarlo aquí',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Himno> favoritos, double hPad) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
      itemCount: favoritos.length,
      itemBuilder: (_, index) {
        final himno = favoritos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1.5,
          shadowColor: Colors.black12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => _openHimno(context, himno.id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.star,
                      color: Colors.amber.shade600,
                      size: 22,
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
                        const SizedBox(height: 2),
                        Text(
                          'Himno ${himno.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: Colors.grey.shade400, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
