import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../services/produto_service.dart';
import 'alterar_estoque_screen.dart';
import 'barcode_scanner_screen.dart'; // Importe a tela do scanner

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

  // Novo método para abrir o scanner e buscar o produto
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
                style: const TextStyle(color: Color.fromARGB(255, 99, 99, 99)),
                cursorColor: const Color.fromARGB(255, 99, 99, 99),
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
                    trailing: Text(
                      'Estoque: ${produto.quantidade}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlterarEstoqueScreen(produto: produto),
                        ),
                      );
                      if (resultado == true) {
                        setState(() {
                          _futureProdutos = _produtoService.listarProdutos(searchTerm: _searchTerm);
                        });
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