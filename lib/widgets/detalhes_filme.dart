import 'package:flutter/material.dart';

import '../models/filme.dart';
import '../theme/app_colors.dart';
import 'botao_favorito.dart';
import 'filme_card.dart';
import 'poster_filme.dart';

Future<void> mostrarDetalhesFilme(
  BuildContext context, {
  required Filme filme,
  required Future<bool> Function(Filme filme) onFavoritar,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _DetalhesFilme(filme: filme, onFavoritar: onFavoritar),
  );
}

class _DetalhesFilme extends StatefulWidget {
  const _DetalhesFilme({required this.filme, required this.onFavoritar});

  final Filme filme;
  final Future<bool> Function(Filme filme) onFavoritar;

  @override
  State<_DetalhesFilme> createState() => _DetalhesFilmeState();
}

class _DetalhesFilmeState extends State<_DetalhesFilme> {
  late Filme _filme = widget.filme;

  Future<void> _favoritar() async {
    final favorito = await widget.onFavoritar(_filme);
    if (mounted) setState(() => _filme = _filme.copyWith(isFavorite: favorito));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, rolagem) => ListView(
        controller: rolagem,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 120,
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: PosterFilme(url: _filme.imagem),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _filme.nome,
                      style: const TextStyle(
                        color: AppColors.titulo,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_filme.anoLancamento} · ${_filme.duracaoFormatada}',
                      style: const TextStyle(color: AppColors.textoSecundario),
                    ),
                    const SizedBox(height: 8),
                    EtiquetaGenero(genero: _filme.genero),
                    const SizedBox(height: 10),
                    SeloNota(nota: _filme.notaFormatada),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        BotaoFavorito(
                          favorito: _filme.isFavorite,
                          onPressed: _favoritar,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            _filme.isFavorite
                                ? 'Nos seus favoritos'
                                : 'Adicionar aos favoritos',
                            style: const TextStyle(
                              color: AppColors.texto,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Sinopse',
            style: TextStyle(
              color: AppColors.titulo,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filme.sinopse.isEmpty ? 'Sinopse não informada.' : _filme.sinopse,
            style: const TextStyle(
              color: AppColors.texto,
              fontSize: 15,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
