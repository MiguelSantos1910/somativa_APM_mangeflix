import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color fundo = Color(0xFF070B16);
  static const Color fundoElevado = Color(0xFF0E1526);
  static const Color vidro = Color(0x0FFFFFFF);
  static const Color vidroForte = Color(0x1AFFFFFF);
  static const Color borda = Color(0x24FFFFFF);

  static const Color texto = Color(0xFFE6EBF5);
  static const Color textoSecundario = Color(0xFF94A0B8);
  static const Color titulo = Colors.white;

  static const Color primaria = Color(0xFF3B82F6);
  static const Color secundaria = Color(0xFF6366F1);
  static const Color erro = Color(0xFFEF4444);
  static const Color sucesso = Color(0xFF22C55E);
  static const Color estrela = Color(0xFFFACC15);
  static const Color coracao = Color(0xFFF43F5E);

  static const LinearGradient gradiente = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaria, secundaria],
  );
}
