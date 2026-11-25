import 'package:http/http.dart' as http;

import '../models/filme.dart';
import 'api_config.dart';
import 'api_exception.dart';

class FilmesService {
  FilmesService(this._client);

  final http.Client _client;

  Map<String, String> _cabecalhos(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<Filme>> listar(
    String token, {
    String busca = '',
    String? genero,
    bool apenasFavoritos = false,
  }) async {
    final parametros = <String, String>{
      if (busca.trim().isNotEmpty) 'search': busca.trim(),
      if (genero != null && genero.isNotEmpty) 'genero': genero,
      if (apenasFavoritos) 'favoritos': 'true',
    };

    final response = await enviarRequisicao(
      () => _client.get(
        ApiConfig.uri('/filmes/', parametros),
        headers: _cabecalhos(token),
      ),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(
        response,
        mensagemPadrao: 'Não foi possível carregar os filmes.',
      );
    }

    final dados = decodificarJson(response);
    final itens = dados is Map<String, dynamic> ? dados['results'] : dados;
    if (itens is! List) {
      throw const ApiException('Resposta inesperada do servidor.');
    }

    return itens
        .whereType<Map<String, dynamic>>()
        .map(Filme.fromMap)
        .toList();
  }

  Future<bool> alterarFavorito(
    String token,
    String filmeId, {
    required bool favoritar,
  }) async {
    final uri = ApiConfig.uri('/filmes/$filmeId/favoritar/');
    final response = await enviarRequisicao(
      () => favoritar
          ? _client.post(uri, headers: _cabecalhos(token))
          : _client.delete(uri, headers: _cabecalhos(token)),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(
        response,
        mensagemPadrao: 'Não foi possível atualizar os favoritos.',
      );
    }

    final dados = decodificarJson(response);
    return dados is Map<String, dynamic> && dados['is_favorite'] == true;
  }
}
