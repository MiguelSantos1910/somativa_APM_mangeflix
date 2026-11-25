class Filme {
  const Filme({
    required this.id,
    required this.nome,
    required this.genero,
    required this.sinopse,
    required this.nota,
    required this.duracao,
    required this.anoLancamento,
    required this.isFavorite,
    this.imagem,
  });

  final String id;
  final String nome;
  final String genero;
  final String sinopse;
  final String? imagem;
  final double nota;
  final int duracao;
  final int anoLancamento;
  final bool isFavorite;

  factory Filme.fromMap(Map<String, dynamic> map) {
    final imagem = map['imagem']?.toString();
    return Filme(
      id: map['id'].toString(),
      nome: map['nome']?.toString() ?? '',
      genero: map['genero']?.toString() ?? '',
      sinopse: map['sinopse']?.toString() ?? '',
      imagem: imagem == null || imagem.isEmpty ? null : imagem,
      nota: double.tryParse(map['nota']?.toString() ?? '') ?? 0,
      duracao: int.tryParse(map['duracao']?.toString() ?? '') ?? 0,
      anoLancamento: int.tryParse(map['ano_lancamento']?.toString() ?? '') ?? 0,
      isFavorite: map['is_favorite'] == true,
    );
  }

  Filme copyWith({bool? isFavorite}) {
    return Filme(
      id: id,
      nome: nome,
      genero: genero,
      sinopse: sinopse,
      imagem: imagem,
      nota: nota,
      duracao: duracao,
      anoLancamento: anoLancamento,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get notaFormatada => nota.toStringAsFixed(1).replaceAll('.', ',');

  String get duracaoFormatada {
    final horas = duracao ~/ 60;
    final minutos = duracao % 60;
    if (horas == 0) return '${minutos}min';
    if (minutos == 0) return '${horas}h';
    return '${horas}h ${minutos}min';
  }
}
