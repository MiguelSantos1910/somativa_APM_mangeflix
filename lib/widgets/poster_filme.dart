import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PosterFilme extends StatelessWidget {
  const PosterFilme({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null) return const _SemImagem();

    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progresso) =>
          progresso == null ? child : const _SemImagem(),
      errorBuilder: (context, erro, pilha) => const _SemImagem(),
    );
  }
}

class _SemImagem extends StatelessWidget {
  const _SemImagem();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaria.withValues(alpha: 0.18),
            AppColors.secundaria.withValues(alpha: 0.06),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          size: 40,
          color: AppColors.textoSecundario,
        ),
      ),
    );
  }
}
