import 'package:flutter/material.dart';

import '../pages/cadastro_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';

abstract class AppRoutes {
  static const String login = '/';
  static const String cadastro = '/cadastro';
  static const String inicio = '/inicio';

  static Route<dynamic> gerarRota(RouteSettings configuracao) {
    final Widget pagina = switch (configuracao.name) {
      cadastro => const CadastroPage(),
      inicio => const HomePage(),
      _ => const LoginPage(),
    };
    return MaterialPageRoute(builder: (_) => pagina, settings: configuracao);
  }
}
