import 'package:flutter/foundation.dart';

import '../models/usuario.dart';
import '../services/api_exception.dart';
import '../services/auth_service.dart';

class SessaoProvider extends ChangeNotifier {
  SessaoProvider(this._auth);

  final AuthService _auth;

  String? _access;
  String? _refresh;
  Usuario? _usuario;

  Usuario? get usuario => _usuario;
  bool get logado => _access != null && _usuario != null;
  bool get ehAdmin => _usuario?.ehAdmin ?? false;

  String get nomeExibicao {
    final usuario = _usuario;
    if (usuario == null) return '';
    return usuario.firstName.isNotEmpty ? usuario.firstName : usuario.username;
  }

  Future<void> entrar(String identificacao, String senha) async {
    final tokens = await _auth.entrar(identificacao, senha);
    final usuario = await _auth.buscarUsuarioLogado(tokens.access);
    _access = tokens.access;
    _refresh = tokens.refresh;
    _usuario = usuario;
    notifyListeners();
  }

  Future<void> cadastrar({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) {
    return _auth.cadastrar(
      username: username,
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
  }

  Future<T> comToken<T>(Future<T> Function(String token) chamada) async {
    final token = _access;
    if (token == null) {
      throw const ApiException(
        'Sessão encerrada. Faça login novamente.',
        statusCode: 401,
      );
    }

    try {
      return await chamada(token);
    } on ApiException catch (erro) {
      if (erro.statusCode != 401) rethrow;
      if (await _renovarToken()) return chamada(_access!);
      _limpar();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> _renovarToken() async {
    final refresh = _refresh;
    if (refresh == null) return false;
    try {
      final tokens = await _auth.renovar(refresh);
      _access = tokens.access;
      _refresh = tokens.refresh;
      return true;
    } on ApiException {
      return false;
    }
  }

  Future<void> sair() async {
    final access = _access;
    final refresh = _refresh;
    try {
      if (access != null && refresh != null) {
        await _auth.sair(access: access, refresh: refresh);
      }
    } on ApiException {
      return;
    } finally {
      _limpar();
      notifyListeners();
    }
  }

  void _limpar() {
    _access = null;
    _refresh = null;
    _usuario = null;
  }
}
