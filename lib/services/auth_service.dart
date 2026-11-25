import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/usuario.dart';
import 'api_config.dart';
import 'api_exception.dart';

typedef Tokens = ({String access, String? refresh});

class AuthService {
  AuthService(this._client);

  final http.Client _client;

  static const Map<String, String> _cabecalhos = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  Map<String, String> _comToken(String token) => {
        ..._cabecalhos,
        'Authorization': 'Bearer $token',
      };

  Future<Tokens> entrar(String identificacao, String senha) async {
    final response = await enviarRequisicao(
      () => _client.post(
        ApiConfig.uri('/token/'),
        headers: _cabecalhos,
        body: jsonEncode({'username': identificacao, 'password': senha}),
      ),
    );

    if (response.statusCode == 401) {
      throw const ApiException(
        'Usuário, e-mail ou senha incorretos.',
        statusCode: 401,
      );
    }
    if (response.statusCode != 200) {
      throw ApiException.fromResponse(
        response,
        mensagemPadrao: 'Não foi possível entrar. Tente novamente.',
      );
    }

    final dados = decodificarJson(response) as Map<String, dynamic>;
    return (
      access: dados['access'].toString(),
      refresh: dados['refresh']?.toString(),
    );
  }

  Future<Tokens> renovar(String refresh) async {
    final response = await enviarRequisicao(
      () => _client.post(
        ApiConfig.uri('/token/refresh/'),
        headers: _cabecalhos,
        body: jsonEncode({'refresh': refresh}),
      ),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(
        response,
        mensagemPadrao: 'Sessão expirada. Faça login novamente.',
      );
    }

    final dados = decodificarJson(response) as Map<String, dynamic>;
    return (
      access: dados['access'].toString(),
      refresh: dados['refresh']?.toString() ?? refresh,
    );
  }

  Future<Usuario> buscarUsuarioLogado(String token) async {
    final response = await enviarRequisicao(
      () => _client.get(ApiConfig.uri('/me/'), headers: _comToken(token)),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(
        response,
        mensagemPadrao: 'Não foi possível carregar os dados do usuário.',
      );
    }

    return Usuario.fromMap(decodificarJson(response) as Map<String, dynamic>);
  }

  Future<void> cadastrar({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final response = await enviarRequisicao(
      () => _client.post(
        ApiConfig.uri('/usuarios/'),
        headers: _cabecalhos,
        body: jsonEncode({
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
        }),
      ),
    );

    if (response.statusCode != 201) {
      throw ApiException.fromResponse(
        response,
        mensagemPadrao: 'Não foi possível criar a conta. Revise os dados.',
      );
    }
  }

  Future<void> sair({required String access, required String refresh}) async {
    await enviarRequisicao(
      () => _client.post(
        ApiConfig.uri('/logout/'),
        headers: _comToken(access),
        body: jsonEncode({'refresh': refresh}),
      ),
    );
  }
}
