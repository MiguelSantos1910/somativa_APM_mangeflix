import 'package:flutter_test/flutter_test.dart';
import 'package:mangeflix/models/filme.dart';
import 'package:mangeflix/models/usuario.dart';

void main() {
  group('Filme', () {
    test('converte a resposta da API', () {
      final filme = Filme.fromMap({
        'id': 'abc',
        'nome': 'Parasita',
        'genero': 'Suspense',
        'sinopse': 'Sinopse',
        'imagem': 'http://localhost:8000/media/filmes/parasita.jpg',
        'nota': '8.5',
        'duracao': 132,
        'ano_lancamento': 2019,
        'is_favorite': true,
      });

      expect(filme.nota, 8.5);
      expect(filme.duracao, 132);
      expect(filme.anoLancamento, 2019);
      expect(filme.isFavorite, isTrue);
      expect(filme.notaFormatada, '8,5');
      expect(filme.duracaoFormatada, '2h 12min');
    });

    test('trata imagem vazia como sem pôster', () {
      final filme = Filme.fromMap({'id': 1, 'imagem': ''});

      expect(filme.imagem, isNull);
      expect(filme.isFavorite, isFalse);
    });

    test('copyWith altera apenas o favorito', () {
      final filme = Filme.fromMap({'id': 1, 'nome': 'A', 'duracao': 60});
      final favorito = filme.copyWith(isFavorite: true);

      expect(favorito.isFavorite, isTrue);
      expect(favorito.nome, 'A');
      expect(favorito.duracaoFormatada, '1h');
    });
  });

  group('Usuario', () {
    test('identifica administrador e monta o nome', () {
      final usuario = Usuario.fromMap({
        'id': 3,
        'username': 'admin',
        'first_name': 'Maria',
        'last_name': 'Silva',
        'email': 'maria@teste.com',
        'papel': 'ADMIN',
      });

      expect(usuario.ehAdmin, isTrue);
      expect(usuario.nomeCompleto, 'Maria Silva');
    });
  });
}
