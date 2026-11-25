import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(
    this.mensagem, {
    this.statusCode,
    this.errosPorCampo = const {},
  });

  final String mensagem;
  final int? statusCode;
  final Map<String, String> errosPorCampo;

  factory ApiException.fromResponse(
    http.Response response, {
    String mensagemPadrao = 'Não foi possível concluir a operação.',
  }) {
    final erros = <String, String>{};
    String? detalhe;

    try {
      final corpo = jsonDecode(utf8.decode(response.bodyBytes));
      if (corpo is Map<String, dynamic>) {
        corpo.forEach((campo, valor) {
          final texto = valor is List && valor.isNotEmpty
              ? valor.first.toString()
              : valor?.toString();
          if (texto == null || texto.isEmpty) return;
          if (campo == 'detail' || campo == 'non_field_errors') {
            detalhe ??= texto;
          } else {
            erros[campo] = texto;
          }
        });
      }
    } on FormatException {
      detalhe = null;
    }

    return ApiException(
      detalhe ?? mensagemPadrao,
      statusCode: response.statusCode,
      errosPorCampo: erros,
    );
  }

  factory ApiException.semConexao() {
    return const ApiException(
      'Sem conexão com o servidor. Verifique a internet e tente novamente.',
    );
  }

  @override
  String toString() => mensagem;
}

Future<http.Response> enviarRequisicao(
  Future<http.Response> Function() chamada,
) async {
  try {
    return await chamada();
  } on Exception {
    throw ApiException.semConexao();
  }
}

dynamic decodificarJson(http.Response response) {
  return jsonDecode(utf8.decode(response.bodyBytes));
}
