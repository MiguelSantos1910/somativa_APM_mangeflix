import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sessao_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../widgets/marca_mangeflix.dart';
import 'catalogo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _aba = 0;
  bool _redirecionando = false;

  void _voltarParaLogin() {
    if (_redirecionando) return;
    _redirecionando = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<SessaoProvider>();
    if (!sessao.logado) {
      _voltarParaLogin();
      return const Scaffold();
    }

    final apenasFavoritos = _aba == 1;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const MarcaMangeflix(tamanho: 32),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: Text(
                sessao.nomeExibicao,
                style: const TextStyle(
                  color: AppColors.texto,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<SessaoProvider>().sair(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CatalogoPage(
        key: ValueKey(apenasFavoritos),
        apenasFavoritos: apenasFavoritos,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (indice) => setState(() => _aba = indice),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}
