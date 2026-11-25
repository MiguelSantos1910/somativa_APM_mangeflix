import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const senhaValida = 'SenhaForte#2026';

class ApiFalsa {
  final List<Map<String, dynamic>> usuarios = [
    {
      'id': 1,
      'username': 'ana',
      'first_name': 'Ana',
      'last_name': 'Souza',
      'email': 'ana@teste.com',
      'password': senhaValida,
      'papel': 'ESPECTADOR',
    },
  ];

  final List<Map<String, dynamic>> filmes = [
    {
      'id': 'f1',
      'nome': 'Parasita',
      'genero': 'Suspense',
      'sinopse': 'Uma família pobre se infiltra na casa de uma família rica.',
      'imagem': null,
      'nota': '8.5',
      'duracao': 132,
      'ano_lancamento': 2019,
    },
    {
      'id': 'f2',
      'nome': 'Interestelar',
      'genero': 'Ficção científica',
      'sinopse': 'Exploradores atravessam um buraco de minhoca.',
      'imagem': null,
      'nota': '8.7',
      'duracao': 169,
      'ano_lancamento': 2014,
    },
    {
      'id': 'f3',
      'nome': 'Cidade de Deus',
      'genero': 'Crime',
      'sinopse': 'Buscapé acompanha o crescimento do crime na favela.',
      'imagem': null,
      'nota': '8.6',
      'duracao': 130,
      'ano_lancamento': 2002,
    },
  ];

  final Map<int, Set<String>> favoritos = {};
  final List<String> chamadas = [];

  late final http.Client client = MockClient(_tratar);

  http.Response _json(int status, Object corpo) {
    return http.Response.bytes(
      utf8.encode(jsonEncode(corpo)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  Map<String, dynamic>? _usuarioDoToken(http.Request request) {
    final cabecalho = request.headers['Authorization'] ?? '';
    for (final usuario in usuarios) {
      if (cabecalho == 'Bearer token-${usuario['id']}') return usuario;
    }
    return null;
  }

  Map<String, dynamic> _semSenha(Map<String, dynamic> usuario) {
    return Map.of(usuario)..remove('password');
  }

  Future<http.Response> _tratar(http.Request request) async {
    final caminho = request.url.path.replaceFirst('/api', '');
    chamadas.add('${request.method} $caminho');
    final corpo = request.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(request.body) as Map<String, dynamic>;

    if (caminho == '/token/' && request.method == 'POST') {
      final identificacao = corpo['username'].toString().toLowerCase();
      final usuario = usuarios.where(
        (u) => u['username'] == identificacao || u['email'] == identificacao,
      );
      if (usuario.isEmpty || usuario.first['password'] != corpo['password']) {
        return _json(401, {'detail': 'Credenciais inválidas'});
      }
      final id = usuario.first['id'];
      return _json(200, {'access': 'token-$id', 'refresh': 'refresh-$id'});
    }

    if (caminho == '/usuarios/' && request.method == 'POST') {
      if (usuarios.any((u) => u['username'] == corpo['username'])) {
        return _json(400, {
          'username': ['Um usuário com este nome de usuário já existe.'],
        });
      }
      final novo = {
        'id': usuarios.length + 1,
        'papel': 'ESPECTADOR',
        ...corpo,
      };
      usuarios.add(novo);
      return _json(201, _semSenha(novo));
    }

    final usuario = _usuarioDoToken(request);
    if (usuario == null) {
      return _json(401, {'detail': 'Não autenticado.'});
    }
    final id = usuario['id'] as int;

    if (caminho == '/me/') return _json(200, _semSenha(usuario));
    if (caminho == '/logout/') return _json(200, {'detail': 'ok'});

    if (caminho == '/filmes/') {
      final busca = (request.url.queryParameters['search'] ?? '').toLowerCase();
      final genero = request.url.queryParameters['genero'];
      final apenasFavoritos = request.url.queryParameters['favoritos'] == 'true';
      final doUsuario = favoritos[id] ?? <String>{};
      final lista = filmes
          .map((f) => {...f, 'is_favorite': doUsuario.contains(f['id'])})
          .where((f) => busca.isEmpty || f['nome'].toString().toLowerCase().contains(busca))
          .where((f) => genero == null || f['genero'] == genero)
          .where((f) => !apenasFavoritos || f['is_favorite'] == true)
          .toList();
      return _json(200, lista);
    }

    final favoritar = RegExp(r'^/filmes/([^/]+)/favoritar/$').firstMatch(caminho);
    if (favoritar != null) {
      final doUsuario = favoritos.putIfAbsent(id, () => <String>{});
      if (request.method == 'POST') {
        doUsuario.add(favoritar.group(1)!);
      } else {
        doUsuario.remove(favoritar.group(1));
      }
      return _json(200, {'is_favorite': request.method == 'POST'});
    }

    return _json(404, {'detail': 'Não encontrado.'});
  }
}
