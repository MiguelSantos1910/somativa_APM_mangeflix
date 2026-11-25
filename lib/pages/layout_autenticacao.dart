import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LayoutAutenticacao extends StatelessWidget {
  const LayoutAutenticacao({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.child,
    this.cabecalho,
    this.rodape,
  });

  final String titulo;
  final String subtitulo;
  final Widget child;
  final Widget? cabecalho;
  final Widget? rodape;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navigator.of(context).canPop() ? AppBar() : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                decoration: BoxDecoration(
                  color: AppColors.vidro,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borda),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cabecalho != null) ...[
                      cabecalho!,
                      const SizedBox(height: 28),
                    ],
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: AppColors.titulo,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: const TextStyle(color: AppColors.textoSecundario),
                    ),
                    const SizedBox(height: 24),
                    child,
                    if (rodape != null) ...[
                      const SizedBox(height: 12),
                      rodape!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Alerta extends StatelessWidget {
  const Alerta({super.key, required this.mensagem, this.sucesso = false});

  final String mensagem;
  final bool sucesso;

  @override
  Widget build(BuildContext context) {
    final cor = sucesso ? AppColors.sucesso : AppColors.erro;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cor.withValues(alpha: 0.45)),
        ),
        child: Text(
          mensagem,
          style: TextStyle(
            color: sucesso ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
