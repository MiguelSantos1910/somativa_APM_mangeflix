import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'providers/sessao_provider.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/filmes_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MangeFlixApp());
}

class MangeFlixApp extends StatefulWidget {
  const MangeFlixApp({super.key, this.client});

  final http.Client? client;

  @override
  State<MangeFlixApp> createState() => _MangeFlixAppState();
}

class _MangeFlixAppState extends State<MangeFlixApp> {
  late final http.Client _client = widget.client ?? http.Client();

  @override
  void dispose() {
    if (widget.client == null) _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SessaoProvider(AuthService(_client)),
        ),
        Provider(create: (_) => FilmesService(_client)),
      ],
      child: MaterialApp(
        title: 'MangeFlix',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.tema,
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRoutes.gerarRota,
      ),
    );
  }
}
