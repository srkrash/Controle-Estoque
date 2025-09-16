class Movimento {
  // Atributos que correspondem às colunas da tabela 'movimentos' e aos dados do JOIN
  final int id;
  final int produtoId;
  final String tipoMovimento;
  final int quantidadeAlterada;
  final String dataMovimento;

  // Atributos adicionais do produto, vindos do JOIN na API
  final String? descricaoProduto;
  final String? codigoBarrasProduto;

  // Construtor padrão da classe Movimento
  Movimento({
    required this.id,
    required this.produtoId,
    required this.tipoMovimento,
    required this.quantidadeAlterada,
    required this.dataMovimento,
    this.descricaoProduto,
    this.codigoBarrasProduto,
  });

  // Construtor de fábrica para criar uma instância de Movimento a partir de um JSON (Map)
  factory Movimento.fromJson(Map<String, dynamic> json) {
    return Movimento(
      id: json['id'] as int,
      produtoId: json['produto_id'] as int,
      tipoMovimento: json['tipo_movimento'] as String,
      quantidadeAlterada: json['quantidade_alterada'] as int,
      dataMovimento: json['data_movimento'] as String,
      // Os campos abaixo são opcionais e vêm do JOIN na API
      descricaoProduto: json['descricao'] as String?,
      codigoBarrasProduto: json['codigo_barras'] as String?,
    );
  }
}