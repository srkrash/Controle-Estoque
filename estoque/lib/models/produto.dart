class Produto {
  // Atributos que correspondem às colunas da tabela 'produtos' no banco de dados.
  final int id;
  final String codigoBarras;
  final String descricao;
  final int quantidade;

  // Construtor padrão da classe Produto.
  // A palavra-chave 'required' garante que esses campos nunca sejam nulos.
  Produto({
    required this.id,
    required this.codigoBarras,
    required this.descricao,
    required this.quantidade,
  });

  // Método de fábrica para criar uma instância de Produto a partir de um JSON (Map).
  // Isso é útil para converter a resposta da API (que vem em JSON) em um objeto Dart.
  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] as int,
      codigoBarras: json['codigo_barras'] as String,
      descricao: json['descricao'] as String,
      quantidade: json['quantidade'] as int,
    );
  }

  // Método para converter um objeto Produto em um Map, que pode ser enviado como JSON.
  // Este método será usado para o cadastro de novos produtos via requisição POST.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo_barras': codigoBarras,
      'descricao': descricao,
      'quantidade': quantidade,
    };
  }
}