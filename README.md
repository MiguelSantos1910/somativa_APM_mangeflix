# MangeFlix: App mobile

Aplicativo Flutter do **MangeFlix**. Ele usa a mesma API REST do backend em Django REST Framework, com login, cadastro, catálogo de filmes e lista de favoritos de cada usuário.

## Funcionalidades

- **Login** com usuário ou e-mail, com validação dos campos e mensagem de erro para credenciais inválidas
- **Cadastro** com nome, e-mail, senha e confirmação. Os erros da API aparecem embaixo de cada campo, e depois do cadastro o app volta ao login com mensagem de sucesso
- **Catálogo** em cartões com pôster, título, ano, duração, nota, gênero e sinopse. Tem busca e filtro por gênero
- **Detalhes do filme** com a sinopse completa (toque no cartão)
- **Favoritos**: adicionar e remover com um toque. O coração vermelho marca os favoritados, e aparece uma mensagem quando a lista está vazia
- **Menu** inferior com Catálogo e Favoritos, e botão **Sair** que volta para o login
- Renovação automática do token JWT e grade que se adapta à largura da tela

## Como executar

Pré-requisitos: Flutter 3.47+ e o backend rodando na porta 8000.

```bash
flutter pub get
flutter run
```

O endereço da API é escolhido automaticamente:

| Onde o app roda | Endereço usado |
|---|---|
| Emulador Android | `http://10.0.2.2:8000/api` (é o `localhost` do computador) |
| Chrome, desktop ou iOS Simulator | `http://localhost:8000/api` |

Para usar outro endereço (por exemplo, um celular físico na mesma rede Wi-Fi):

```bash
flutter run --dart-define=API_URL=http://192.168.0.10:8000/api
```

### Configuração do backend

No `.env` do backend:

- `ALLOWED_HOSTS` precisa incluir `10.0.2.2`, para o emulador Android, ou o IP do computador, para um celular físico. Nesse caso, suba o servidor com `python manage.py runserver 0.0.0.0:8000`.
- Para rodar no Chrome, use uma porta fixa (`flutter run -d chrome --web-port 5174`) e inclua `http://localhost:5174` em `CORS_ALLOWED_ORIGINS`.

O app usa `http://` em desenvolvimento, por isso o `AndroidManifest.xml` libera esse tipo de conexão (`usesCleartextTraffic`).

## Testes

```bash
flutter test
```

São 14 testes, todos com uma API simulada (`test/api_falsa.dart`), então não precisam do backend:

- **Modelos**: conversão do JSON da API, formatação de nota e duração
- **Login**: campos obrigatórios, credenciais inválidas, login por e-mail
- **Cadastro**: confirmação de senha, erro da API no campo, retorno ao login com sucesso
- **Catálogo**: dados do cartão, filtro por gênero, detalhes com a sinopse
- **Favoritos**: favoritar, listar e remover; mensagem quando vazia
- **Logout**: volta para o login

## Estrutura

```
lib/
  main.dart                 app, providers e rotas
  models/                   Filme e Usuario
  services/                 AuthService, FilmesService, configuração e erros da API
  providers/                SessaoProvider (login, token, logout)
  routes/                   rotas do app
  theme/                    cores e tema escuro
  pages/                    login, cadastro, início (menu) e catálogo/favoritos
  widgets/                  cartão do filme, detalhes, campos, botões, estados vazios
test/                       testes de modelos e de widgets
```
