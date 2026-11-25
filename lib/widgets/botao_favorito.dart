import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BotaoFavorito extends StatelessWidget {
  const BotaoFavorito({
    super.key,
    required this.favorito,
    required this.onPressed,
    this.tamanho = 40,
  });

  final bool favorito;
  final VoidCallback onPressed;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final rotulo = favorito ? 'Remover dos favoritos' : 'Adicionar aos favoritos';

    return Semantics(
      button: true,
      toggled: favorito,
      label: rotulo,
      excludeSemantics: true,
      child: Tooltip(
        message: rotulo,
        child: Material(
          color: AppColors.fundo.withValues(alpha: 0.65),
          shape: const CircleBorder(side: BorderSide(color: AppColors.borda)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: tamanho,
              height: tamanho,
              child: Icon(
                favorito ? Icons.favorite : Icons.favorite_border,
                size: tamanho * 0.5,
                color: favorito ? AppColors.coracao : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
