import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sessao_provider.dart';
import '../services/api_exception.dart';
import '../widgets/botao_app.dart';
import '../widgets/campo_formulario.dart';
import 'layout_autenticacao.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  static final _formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _sobrenome = TextEditingController();
  final _usuario = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();

  bool _carregando = false;
  String? _erroGeral;
  Map<String, String> _errosApi = const {};

  @override
  void dispose() {
    for (final controller in [
      _nome,
      _sobrenome,
      _usuario,
      _email,
      _senha,
      _confirmacao,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _limparErro(String campo) {
    if (!_errosApi.containsKey(campo)) return;
    setState(() => _errosApi = Map.of(_errosApi)..remove(campo));
  }

  Future<void> _cadastrar() async {
    setState(() {
      _errosApi = const {};
      _erroGeral = null;
    });
    if (_carregando || !_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    final username = _usuario.text.trim();

    try {
      await context.read<SessaoProvider>().cadastrar(
            username: username,
            firstName: _nome.text.trim(),
            lastName: _sobrenome.text.trim(),
            email: _email.text.trim(),
            password: _senha.text,
          );
      if (mounted) Navigator.of(context).pop(username);
    } on ApiException catch (erro) {
      if (!mounted) return;
      setState(() {
        _errosApi = erro.errosPorCampo;
        _erroGeral = erro.errosPorCampo.isEmpty ? erro.mensagem : null;
      });
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutAutenticacao(
      titulo: 'Criar conta',
      subtitulo: 'Cadastre-se para montar sua lista de favoritos.',
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_erroGeral != null) ...[
                Alerta(mensagem: _erroGeral!),
                const SizedBox(height: 16),
              ],
              CampoFormulario(
                rotulo: 'Nome',
                icone: Icons.badge_outlined,
                controller: _nome,
                acaoTeclado: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
                erro: _errosApi['first_name'],
                onChanged: (_) => _limparErro('first_name'),
                validator: (valor) =>
                    (valor ?? '').trim().isEmpty ? 'Informe seu nome.' : null,
              ),
              const SizedBox(height: 14),
              CampoFormulario(
                rotulo: 'Sobrenome',
                icone: Icons.badge_outlined,
                controller: _sobrenome,
                acaoTeclado: TextInputAction.next,
                autofillHints: const [AutofillHints.familyName],
                erro: _errosApi['last_name'],
                onChanged: (_) => _limparErro('last_name'),
              ),
              const SizedBox(height: 14),
              CampoFormulario(
                rotulo: 'Usuário',
                icone: Icons.person_outline,
                controller: _usuario,
                acaoTeclado: TextInputAction.next,
                autofillHints: const [AutofillHints.newUsername],
                erro: _errosApi['username'],
                onChanged: (_) => _limparErro('username'),
                validator: (valor) => (valor ?? '').trim().isEmpty
                    ? 'Escolha um nome de usuário.'
                    : null,
              ),
              const SizedBox(height: 14),
              CampoFormulario(
                rotulo: 'E-mail',
                icone: Icons.mail_outline,
                controller: _email,
                tipoTeclado: TextInputType.emailAddress,
                acaoTeclado: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                erro: _errosApi['email'],
                onChanged: (_) => _limparErro('email'),
                validator: (valor) {
                  final email = (valor ?? '').trim();
                  if (email.isEmpty) return 'Informe seu e-mail.';
                  if (!_formatoEmail.hasMatch(email)) {
                    return 'Informe um e-mail válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              CampoFormulario(
                rotulo: 'Senha',
                icone: Icons.lock_outline,
                controller: _senha,
                senha: true,
                acaoTeclado: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                erro: _errosApi['password'],
                onChanged: (_) => _limparErro('password'),
                validator: (valor) => (valor ?? '').length < 8
                    ? 'A senha precisa ter pelo menos 8 caracteres.'
                    : null,
              ),
              const SizedBox(height: 14),
              CampoFormulario(
                rotulo: 'Confirmar senha',
                icone: Icons.lock_outline,
                controller: _confirmacao,
                senha: true,
                acaoTeclado: TextInputAction.done,
                onFieldSubmitted: (_) => _cadastrar(),
                validator: (valor) =>
                    valor != _senha.text ? 'As senhas não conferem.' : null,
              ),
              const SizedBox(height: 24),
              BotaoApp(
                texto: 'Criar conta',
                carregando: _carregando,
                onPressed: _cadastrar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
