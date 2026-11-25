import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mangeflix/main.dart';
import 'package:mangeflix/widgets/botao_app.dart';
import 'package:mangeflix/widgets/filme_card.dart';

import 'api_falsa.dart';

Finder campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);

Finder botao(String texto) => find.widgetWithText(BotaoApp, texto);

Finder cartao(String nome) => find.widgetWithText(FilmeCard, nome);

Future<ApiFalsa> abrirApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final api = ApiFalsa();
  await tester.pumpWidget(MangeFlixApp(client: api.client));
  await tester.pumpAndSettle();
  return api;
}

Future<void> entrar(
  WidgetTester tester, {
  String usuario = 'ana',
  String senha = senhaValida,
}) async {
  await tester.enterText(campo('Usuário ou e-mail'), usuario);
  await tester.enterText(campo('Senha'), senha);
  await tester.tap(botao('Entrar'));
  await tester.pumpAndSettle();
}

void main() {
  group('Login', () {
    testWidgets('valida os campos obrigatórios', (tester) async {
      await abrirApp(tester);

      await tester.tap(botao('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu usuário ou e-mail.'), findsOneWidget);
      expect(find.text('Informe sua senha.'), findsOneWidget);
    });

    testWidgets('mostra erro com credenciais inválidas', (tester) async {
      await abrirApp(tester);

      await entrar(tester, senha: 'errada');

      expect(find.text('Usuário, e-mail ou senha incorretos.'), findsOneWidget);
      expect(find.text('Catálogo'), findsNothing);
    });

    testWidgets('entra com o e-mail e abre o catálogo', (tester) async {
      await abrirApp(tester);

      await entrar(tester, usuario: 'ana@teste.com');

      expect(find.text('Explore os filmes disponíveis.'), findsOneWidget);
      expect(find.byType(FilmeCard), findsNWidgets(3));
    });
  });

  group('Cadastro', () {
    testWidgets('confere a senha e volta para o login com sucesso',
        (tester) async {
      await abrirApp(tester);
      await tester.tap(find.text('Cadastre-se'));
      await tester.pumpAndSettle();

      await tester.enterText(campo('Nome'), 'Bia');
      await tester.enterText(campo('Usuário'), 'bia');
      await tester.enterText(campo('E-mail'), 'bia@teste.com');
      await tester.enterText(campo('Senha'), senhaValida);
      await tester.enterText(campo('Confirmar senha'), 'outra-senha');
      await tester.tap(botao('Criar conta'));
      await tester.pumpAndSettle();

      expect(find.text('As senhas não conferem.'), findsOneWidget);

      await tester.enterText(campo('Confirmar senha'), senhaValida);
      await tester.tap(botao('Criar conta'));
      await tester.pumpAndSettle();

      expect(
        find.text('Conta criada com sucesso! Entre com seus dados.'),
        findsOneWidget,
      );
      expect(find.text('bia'), findsOneWidget);
    });

    testWidgets('mostra o erro da API embaixo do campo', (tester) async {
      await abrirApp(tester);
      await tester.tap(find.text('Cadastre-se'));
      await tester.pumpAndSettle();

      await tester.enterText(campo('Nome'), 'Outra');
      await tester.enterText(campo('Usuário'), 'ana');
      await tester.enterText(campo('E-mail'), 'outra@teste.com');
      await tester.enterText(campo('Senha'), senhaValida);
      await tester.enterText(campo('Confirmar senha'), senhaValida);
      await tester.tap(botao('Criar conta'));
      await tester.pumpAndSettle();

      expect(
        find.text('Um usuário com este nome de usuário já existe.'),
        findsOneWidget,
      );
    });
  });

  group('Catálogo e favoritos', () {
    testWidgets('mostra título, ano, gênero e sinopse no cartão',
        (tester) async {
      await abrirApp(tester);
      await entrar(tester);

      final parasita = cartao('Parasita');
      expect(
        find.descendant(of: parasita, matching: find.text('Suspense')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: parasita, matching: find.textContaining('2019')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: parasita,
          matching: find.textContaining('Uma família pobre'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('filtra por gênero', (tester) async {
      await abrirApp(tester);
      await entrar(tester);

      await tester.tap(find.text('Crime').first);
      await tester.pumpAndSettle();

      expect(find.byType(FilmeCard), findsOneWidget);
      expect(cartao('Cidade de Deus'), findsOneWidget);
    });

    testWidgets('favorita, lista nos favoritos e remove', (tester) async {
      final api = await abrirApp(tester);
      await entrar(tester);

      await tester.tap(
        find.descendant(
          of: cartao('Parasita'),
          matching: find.byTooltip('Adicionar aos favoritos'),
        ),
      );
      await tester.pumpAndSettle();

      expect(api.chamadas, contains('POST /filmes/f1/favoritar/'));
      expect(
        find.descendant(
          of: cartao('Parasita'),
          matching: find.byIcon(Icons.favorite),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Favoritos'));
      await tester.pumpAndSettle();

      expect(find.text('Meus favoritos'), findsOneWidget);
      expect(find.byType(FilmeCard), findsOneWidget);

      await tester.tap(find.byTooltip('Remover dos favoritos'));
      await tester.pumpAndSettle();

      expect(find.byType(FilmeCard), findsNothing);
      expect(
        find.textContaining('Você ainda não favoritou nenhum filme.'),
        findsOneWidget,
      );
    });

    testWidgets('abre os detalhes com a sinopse completa', (tester) async {
      await abrirApp(tester);
      await entrar(tester);

      await tester.tap(find.text('Interestelar'));
      await tester.pumpAndSettle();

      expect(find.text('Sinopse'), findsOneWidget);
      expect(find.text('Exploradores atravessam um buraco de minhoca.'),
          findsNWidgets(2));
    });

    testWidgets('logout volta para o login', (tester) async {
      final api = await abrirApp(tester);
      await entrar(tester);

      await tester.tap(find.byTooltip('Sair'));
      await tester.pumpAndSettle();

      expect(api.chamadas, contains('POST /logout/'));
      expect(campo('Usuário ou e-mail'), findsOneWidget);
    });
  });
}
