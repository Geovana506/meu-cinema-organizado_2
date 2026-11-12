class Filme {
  const Filme({
    required this.id,
    required this.titulo,
    required this.diretor,
    required this.ano,
    required this.genero,
    required this.duracaoMinutos,
    required this.assistido,
  });

  final int id;
  final String titulo;
  final String diretor;
  final int ano;
  final String genero;
  final int duracaoMinutos;
  final bool assistido;

  factory Filme.fromJson(Map<String, dynamic> json) {
    return Filme(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      diretor: json['diretor'] as String,
      ano: json['ano'] as int,
      genero: json['genero'] as String,
      duracaoMinutos: json['duracao_minutos'] as int,
      assistido: json['assistido'] as bool,
    );
  }
}
