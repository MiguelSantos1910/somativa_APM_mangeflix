import 'package:flutter/material.dart';

import '../models/filme.dart';
import '../theme/app_colors.dart';
import 'botao_favorito.dart';
import 'poster_filme.dart';

class FilmeCard extends StatelessWidget {
  const FilmeCard({
    super.key,
    required this.filme,
    required this.onFavoritar,
    required this.onAbrir,
  });

  static const double alturaInformacoes = 150;

  final Filme filme;
  final VoidCallback onFavoritar;
  final VoidCallback onAbrir;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.vidro,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borda),
      ),
      child: InkWell(
        onTap: onAbrir,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PosterFilme(url: filme.imagem),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BotaoFavorito(
                      favorito: filme.isFavorite,
                      onPressed: onFavoritar,
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: SeloNota(nota: filme.notaFormatada),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filme.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.titulo,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${filme.anoLancamento} · ${filme.duracaoFormatada}',
                      style: const TextStyle(
                        color: AppColors.textoSecundario,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    EtiquetaGenero(genero: filme.genero),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        filme.sinopse,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textoSecundario,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeloNota extends StatelessWidget {
  const SeloNota({super.key, required this.nota});

  final String nota;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.fundo.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 15, color: AppColors.estrela),
          const SizedBox(width: 3),
          Text(
            nota,
            style: const TextStyle(
              color: AppColors.estrela,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class EtiquetaGenero extends StatelessWidget {
  const EtiquetaGenero({super.key, required this.genero});

  final String genero;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaria.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        genero,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 11),
      ),
    );
  }
}
