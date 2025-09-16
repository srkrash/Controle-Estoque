import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../services/produto_service.dart';
import 'alterar_estoque_screen.dart';
import 'barcode_scanner_screen.dart';

class ListaProdutosScreen extends StatefulWidget {
  const ListaProdutosScreen({super.key});

  @override
  State<ListaProdutosScreen> createState() => _ListaProdutosScreenState();
}

class _ListaProdutosScreenState extends State<ListaProdutosScreen> {
  final ProdutoService _produtoService = ProdutoService();
  final _searchController = TextEditingController();
  String _searchTerm = '';

  late Future<List<Produto>> _futureProdutos;

  @override
  void initState() {
    super.initState();
    _futureProdutos = _produtoService.listarProdutos();
  }

  void _runSearch(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm;
      _futureProdutos = _produtoService.listarProdutos(searchTerm: _searchTerm);
    });
  }

  void _abrirScannerParaBusca() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (result != null) {
      _searchController.text = result;
      _runSearch(result);
    }
  }

  // Novo método para confirmar e excluir o produto
  Future<void> _confirmarExclusao(Produto produto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o produto "${produto.descricao}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      bool sucesso = await _produtoService.excluirProduto(produto.id);
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto excluído com sucesso!')),
        );
        // Recarrega a lista após a exclusão
        _runSearch(_searchTerm);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir produto.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _runSearch,
                decoration: const InputDecoration(
                  hintText: 'Buscar por nome ou código...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Color.fromARGB(255, 105, 105, 105)),
                cursorColor: const Color.fromARGB(255, 105, 105, 105),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _abrirScannerParaBusca,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchTerm = '';
                _futureProdutos = _produtoService.listarProdutos();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Produto>>(
        future: _futureProdutos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            final mensagem = _searchTerm.isEmpty
                ? 'Nenhum produto cadastrado.'
                : 'Nenhum produto encontrado.';
            return Center(child: Text(mensagem));
          } else {
            final produtos = snapshot.data!;
            return ListView.builder(
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      produto.descricao,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Código: ${produto.codigoBarras}\nID: ${produto.id}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Estoque: ${produto.quantidade}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Color.fromARGB(255, 197, 79, 70)),
                          onPressed: () => _confirmarExclusao(produto),
                        ),
                      ],
                    ),
                    onTap: () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlterarEstoqueScreen(produto: produto),
                        ),
                      );
                      if (resultado == true) {
                        _runSearch(_searchTerm);
                      }
                    },
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