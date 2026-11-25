import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CampoFormulario extends StatefulWidget {
  const CampoFormulario({
    super.key,
    required this.rotulo,
    required this.controller,
    this.icone,
    this.senha = false,
    this.tipoTeclado = TextInputType.text,
    this.acaoTeclado,
    this.validator,
    this.erro,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  final String rotulo;
  final TextEditingController controller;
  final IconData? icone;
  final bool senha;
  final TextInputType tipoTeclado;
  final TextInputAction? acaoTeclado;
  final String? Function(String?)? validator;
  final String? erro;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<CampoFormulario> createState() => _CampoFormularioState();
}

class _CampoFormularioState extends State<CampoFormulario> {
  bool _mostrarSenha = false;

  OutlineInputBorder _borda(Color cor, [double largura = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: cor, width: largura),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.senha && !_mostrarSenha,
      keyboardType: widget.tipoTeclado,
      textInputAction: widget.acaoTeclado,
      autocorrect: !widget.senha,
      enableSuggestions: !widget.senha,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: const TextStyle(color: AppColors.texto),
      decoration: InputDecoration(
        labelText: widget.rotulo,
        errorText: widget.erro,
        errorMaxLines: 3,
        filled: true,
        fillColor: AppColors.vidro,
        labelStyle: const TextStyle(color: AppColors.textoSecundario),
        prefixIcon: widget.icone == null
            ? null
            : Icon(widget.icone, color: AppColors.textoSecundario),
        suffixIcon: widget.senha
            ? IconButton(
                tooltip: _mostrarSenha ? 'Ocultar senha' : 'Mostrar senha',
                onPressed: () => setState(() => _mostrarSenha = !_mostrarSenha),
                icon: Icon(
                  _mostrarSenha
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textoSecundario,
                ),
              )
            : null,
        enabledBorder: _borda(AppColors.borda),
        focusedBorder: _borda(AppColors.primaria, 1.5),
        errorBorder: _borda(AppColors.erro),
        focusedErrorBorder: _borda(AppColors.erro, 1.5),
      ),
    );
  }
}
