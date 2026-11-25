import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BotaoApp extends StatelessWidget {
  const BotaoApp({
    super.key,
    required this.texto,
    required this.onPressed,
    this.carregando = false,
  });

  final String texto;
  final VoidCallback? onPressed;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    final habilitado = onPressed != null && !carregando;

    return Opacity(
      opacity: habilitado ? 1 : 0.6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.gradiente,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaria.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: habilitado ? onPressed : null,
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: Center(
                child: carregando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        texto,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
