import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pacote para formatar a data
import '../models/movimento.dart';
import '../services/produto_service.dart';

class MovimentosScreen extends StatefulWidget {
  const MovimentosScreen({super.key});

  @override
  State<MovimentosScreen> createState() => _MovimentosScreenState();
}

class _MovimentosScreenState extends State<MovimentosScreen> {
  // Instância do nosso serviço para fazer a requisição à API.
  final ProdutoService _produtoService = ProdutoService();

  // Future para armazenar o resultado da requisição de movimentos.
  late Future<List<Movimento>> _futureMovimentos;

  @override
  void initState() {
    super.initState();
    // Inicia a requisição para carregar os movimentos assim que a tela é criada.
    _futureMovimentos = _produtoService.listarMovimentos();
  }

  // Função para formatar o tipo de movimento para exibição
  String _formatarTipoMovimento(String tipo) {
    switch (tipo) {
      case 'INICIAL':
        return 'Estoque Inicial';
      case 'ADICAO':
        return 'Adição';
      case 'REMOCAO':
        return 'Remoção';
      case 'AJUSTE':
        return 'Ajuste';
      default:
        return 'Desconhecido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Movimentos'),
        actions: [
          // Botão para atualizar a lista de movimentos
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _futureMovimentos = _produtoService.listarMovimentos();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Movimento>>(
        future: _futureMovimentos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum movimento registrado.'));
          } else {
            final movimentos = snapshot.data!;
            return ListView.builder(
              itemCount: movimentos.length,
              itemBuilder: (context, index) {
                final movimento = movimentos[index];

                // Formata a data para um formato mais legível
                final dataHora = DateTime.parse(movimento.dataMovimento);
                final dataFormatada =
                    DateFormat('dd/MM/yyyy HH:mm').format(dataHora);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      movimento.descricaoProduto!, // O JOIN garante que essa informação não seja nula
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipo: ${_formatarTipoMovimento(movimento.tipoMovimento)}'),
                        Text('Quantidade: ${movimento.quantidadeAlterada}'),
                        Text('Data: $dataFormatada'),
                      ],
                    ),
                    trailing: const Icon(Icons.history),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}