import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../services/produto_service.dart';
import 'barcode_scanner_screen.dart';

class CadastroProdutoScreen extends StatefulWidget {
  const CadastroProdutoScreen({super.key});

  @override
  State<CadastroProdutoScreen> createState() => _CadastroProdutoScreenState();
}

class _CadastroProdutoScreenState extends State<CadastroProdutoScreen> {
  // 1. Controladores para os campos de texto do formulário.
  final _codigoBarrasController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // 2. Instância do nosso serviço para fazer a requisição à API.
  final ProdutoService _produtoService = ProdutoService();

  // 3. Método para lidar com o cadastro do produto.
  void _cadastrarProduto() async {
    // Valida o formulário.
    if (_formKey.currentState!.validate()) {
      final novoProduto = Produto(
        id: 0, // O ID é gerado pelo banco de dados, então passamos 0.
        codigoBarras: _codigoBarrasController.text,
        descricao: _descricaoController.text,
        quantidade: int.parse(_quantidadeController.text),
      );

      // Chama o método do serviço para adicionar o produto.
      bool sucesso = await _produtoService.adicionarProduto(novoProduto);

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto cadastrado com sucesso!')),
        );
        // Limpa os campos após o sucesso.
        _codigoBarrasController.clear();
        _descricaoController.clear();
        _quantidadeController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao cadastrar produto. Verifique o código de barras.')),
        );
      }
    }
  }

  void _abrirScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (result != null) {
      _codigoBarrasController.text = result;
    }
  }

  @override
  void dispose() {
    // 4. Limpeza dos controladores para evitar vazamento de memória.
    _codigoBarrasController.dispose();
    _descricaoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Campo para o código de barras
              TextFormField(
                controller: _codigoBarrasController,
                decoration: InputDecoration(
                  labelText: 'Código de Barras',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _abrirScanner, // Adiciona o botão de scanner
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o código de barras';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo para a descrição do produto
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição do Produto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo para a quantidade inicial
              TextFormField(
                controller: _quantidadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade Inicial',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a quantidade inicial';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _cadastrarProduto,
                child: const Text('Cadastrar Produto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}