import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sessao_provider.dart';
import '../routes/app_routes.dart';
import '../services/api_exception.dart';
import '../theme/app_colors.dart';
import '../widgets/botao_app.dart';
import '../widgets/campo_formulario.dart';
import '../widgets/marca_mangeflix.dart';
import 'layout_autenticacao.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identificacao = TextEditingController();
  final _senha = TextEditingController();
  bool _carregando = false;
  String? _erro;
  String? _sucesso;

  @override
  void dispose() {
    _identificacao.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_carregando || !_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
      _sucesso = null;
    });

    try {
      await context
          .read<SessaoProvider>()
          .entrar(_identificacao.text.trim(), _senha.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.inicio);
    } on ApiException catch (erro) {
      if (mounted) setState(() => _erro = erro.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _abrirCadastro() async {
    final usuarioCriado =
        await Navigator.of(context).pushNamed(AppRoutes.cadastro);
    if (!mounted || usuarioCriado is! String) return;

    setState(() {
      _identificacao.text = usuarioCriado;
      _senha.clear();
      _erro = null;
      _sucesso = 'Conta criada com sucesso! Entre com seus dados.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutAutenticacao(
      titulo: 'Entrar',
      subtitulo: 'Acesse sua conta para ver o catálogo.',
      cabecalho: const MarcaMangeflix(),
      rodape: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Não tem conta?',
            style: TextStyle(color: AppColors.textoSecundario),
          ),
          TextButton(
            onPressed: _carregando ? null : _abrirCadastro,
            child: const Text('Cadastre-se'),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_sucesso != null) ...[
                Alerta(mensagem: _sucesso!, sucesso: true),
                const SizedBox(height: 16),
              ],
              if (_erro != null) ...[
                Alerta(mensagem: _erro!),
                const SizedBox(height: 16),
              ],
              CampoFormulario(
                rotulo: 'Usuário ou e-mail',
                icone: Icons.person_outline,
                controller: _identificacao,
                tipoTeclado: TextInputType.emailAddress,
                acaoTeclado: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                validator: (valor) => (valor ?? '').trim().isEmpty
                    ? 'Informe seu usuário ou e-mail.'
                    : null,
              ),
              const SizedBox(height: 16),
              CampoFormulario(
                rotulo: 'Senha',
                icone: Icons.lock_outline,
                controller: _senha,
                senha: true,
                acaoTeclado: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _entrar(),
                validator: (valor) =>
                    (valor ?? '').isEmpty ? 'Informe sua senha.' : null,
              ),
              const SizedBox(height: 24),
              BotaoApp(
                texto: 'Entrar',
                carregando: _carregando,
                onPressed: _entrar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
