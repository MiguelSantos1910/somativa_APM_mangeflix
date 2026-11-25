import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/filme.dart';
import '../providers/sessao_provider.dart';
import '../services/api_exception.dart';
import '../services/filmes_service.dart';
import '../theme/app_colors.dart';
import '../widgets/detalhes_filme.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/filme_card.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key, this.apenasFavoritos = false});

  final bool apenasFavoritos;

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final _busca = TextEditingController();
  Timer? _atraso;

  List<Filme> _filmes = const [];
  List<String> _generos = const [];
  String? _genero;
  bool _carregando = true;
  String? _erro;

  bool get _temFiltro => _busca.text.trim().isNotEmpty || _genero != null;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _atraso?.cancel();
    _busca.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    final sessao = context.read<SessaoProvider>();
    final servico = context.read<FilmesService>();

    try {
      final filmes = await sessao.comToken(
        (token) => servico.listar(
          token,
          busca: _busca.text,
          genero: _genero,
          apenasFavoritos: widget.apenasFavoritos,
        ),
      );
      if (!mounted) return;
      setState(() {
        _filmes = filmes;
        if (!_temFiltro) {
          _generos = {for (final filme in filmes) filme.genero}.toList()
            ..sort();
        }
      });
    } on ApiException catch (erro) {
      if (mounted) setState(() => _erro = erro.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _aoBuscar(String _) {
    _atraso?.cancel();
    _atraso = Timer(const Duration(milliseconds: 350), _carregar);
  }

  void _selecionarGenero(String? genero) {
    if (genero == _genero) return;
    setState(() => _genero = genero);
    _carregar();
  }

  void _avisar(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: erro ? AppColors.erro : null,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _substituir(Filme filme) {
    setState(() {
      _filmes = [
        for (final item in _filmes) item.id == filme.id ? filme : item,
      ];
    });
  }

  Future<bool> _alternarFavorito(Filme filme) async {
    final favoritar = !filme.isFavorite;
    final sessao = context.read<SessaoProvider>();
    final servico = context.read<FilmesService>();

    _substituir(filme.copyWith(isFavorite: favoritar));

    try {
      final favorito = await sessao.comToken(
        (token) => servico.alterarFavorito(
          token,
          filme.id,
          favoritar: favoritar,
        ),
      );
      if (!mounted) return favorito;

      if (widget.apenasFavoritos && !favorito) {
        setState(() => _filmes = _filmes.where((f) => f.id != filme.id).toList());
      } else {
        _substituir(filme.copyWith(isFavorite: favorito));
      }
      _avisar(
        favorito
            ? '"${filme.nome}" adicionado aos favoritos.'
            : '"${filme.nome}" removido dos favoritos.',
      );
      return favorito;
    } on ApiException catch (erro) {
      if (mounted) {
        _substituir(filme);
        _avisar(erro.mensagem, erro: true);
      }
      return filme.isFavorite;
    }
  }

  void _abrirDetalhes(Filme filme) {
    mostrarDetalhesFilme(
      context,
      filme: filme,
      onFavoritar: (atual) => _alternarFavorito(
        _filmes.firstWhere((f) => f.id == atual.id, orElse: () => atual),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.apenasFavoritos ? 'Meus favoritos' : 'Catálogo',
                style: const TextStyle(
                  color: AppColors.titulo,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.apenasFavoritos
                    ? 'Os filmes que você marcou com o coração.'
                    : 'Explore os filmes disponíveis.',
                style: const TextStyle(color: AppColors.textoSecundario),
              ),
            ],
          ),
        ),
        if (!widget.apenasFavoritos) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _busca,
              onChanged: _aoBuscar,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: AppColors.texto),
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou gênero',
                hintStyle: const TextStyle(color: AppColors.textoSecundario),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textoSecundario,
                ),
                filled: true,
                fillColor: AppColors.vidro,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borda),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaria),
                ),
              ),
            ),
          ),
          if (_generos.isNotEmpty)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                children: [
                  _ChipGenero(
                    rotulo: 'Todos',
                    selecionado: _genero == null,
                    onTap: () => _selecionarGenero(null),
                  ),
                  for (final genero in _generos)
                    _ChipGenero(
                      rotulo: genero,
                      selecionado: _genero == genero,
                      onTap: () => _selecionarGenero(genero),
                    ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _carregar,
            child: _conteudo(),
          ),
        ),
      ],
    );
  }

  Widget _conteudo() {
    if (_carregando && _filmes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return _Rolavel(
        child: EstadoVazio(
          icone: Icons.cloud_off_outlined,
          mensagem: _erro!,
          textoAcao: 'Tentar novamente',
          onAcao: _carregar,
        ),
      );
    }

    if (_filmes.isEmpty) {
      return _Rolavel(
        child: EstadoVazio(
          icone: widget.apenasFavoritos
              ? Icons.favorite_border
              : Icons.movie_outlined,
          mensagem: _temFiltro
              ? 'Nenhum filme encontrado com esses filtros.'
              : widget.apenasFavoritos
                  ? 'Você ainda não favoritou nenhum filme.\nToque no coração de um filme para salvá-lo aqui.'
                  : 'Nenhum filme cadastrado ainda.',
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, restricoes) {
        const espaco = 12.0;
        const margem = 16.0;
        final colunas = ((restricoes.maxWidth - margem * 2) / 190)
            .floor()
            .clamp(2, 6);
        final largura =
            (restricoes.maxWidth - margem * 2 - espaco * (colunas - 1)) /
                colunas;

        return AnimatedOpacity(
          opacity: _carregando ? 0.6 : 1,
          duration: const Duration(milliseconds: 200),
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(margem, 0, margem, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: colunas,
              crossAxisSpacing: espaco,
              mainAxisSpacing: espaco,
              mainAxisExtent: largura * 1.5 + FilmeCard.alturaInformacoes,
            ),
            itemCount: _filmes.length,
            itemBuilder: (context, indice) {
              final filme = _filmes[indice];
              return FilmeCard(
                key: ValueKey(filme.id),
                filme: filme,
                onFavoritar: () => _alternarFavorito(filme),
                onAbrir: () => _abrirDetalhes(filme),
              );
            },
          ),
        );
      },
    );
  }
}

class _Rolavel extends StatelessWidget {
  const _Rolavel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricoes) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: restricoes.maxHeight),
          child: child,
        ),
      ),
    );
  }
}

class _ChipGenero extends StatelessWidget {
  const _ChipGenero({
    required this.rotulo,
    required this.selecionado,
    required this.onTap,
  });

  final String rotulo;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        selected: selecionado,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: selecionado ? AppColors.gradiente : null,
                color: selecionado ? null : AppColors.vidro,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selecionado ? Colors.transparent : AppColors.borda,
                ),
              ),
              child: Center(
                child: Text(
                  rotulo,
                  style: TextStyle(
                    color: selecionado
                        ? Colors.white
                        : AppColors.textoSecundario,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
