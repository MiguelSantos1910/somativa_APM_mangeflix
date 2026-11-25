import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppTheme {
  static final ThemeData tema = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.fundo,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaria,
      onPrimary: Colors.white,
      secondary: AppColors.secundaria,
      onSecondary: Colors.white,
      surface: AppColors.fundoElevado,
      onSurface: AppColors.texto,
      error: AppColors.erro,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.fundo,
      foregroundColor: AppColors.titulo,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.fundoElevado,
      indicatorColor: AppColors.primaria.withValues(alpha: 0.22),
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (estados) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: estados.contains(WidgetState.selected)
              ? AppColors.titulo
              : AppColors.textoSecundario,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (estados) => IconThemeData(
          color: estados.contains(WidgetState.selected)
              ? AppColors.titulo
              : AppColors.textoSecundario,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.fundoElevado,
      contentTextStyle: const TextStyle(color: AppColors.texto),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borda),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaria,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primaria),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.fundoElevado,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
