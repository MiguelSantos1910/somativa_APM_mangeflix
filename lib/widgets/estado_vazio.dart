import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.mensagem,
    this.textoAcao,
    this.onAcao,
  });

  final IconData icone;
  final String mensagem;
  final String? textoAcao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: AppColors.textoSecundario),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textoSecundario,
                fontSize: 15,
              ),
            ),
            if (textoAcao != null && onAcao != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onAcao, child: Text(textoAcao!)),
            ],
          ],
        ),
      ),
    );
  }
}
