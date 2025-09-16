import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../services/produto_service.dart';

class AlterarEstoqueScreen extends StatefulWidget {
  // O produto é passado para a tela no momento da navegação.
  final Produto produto;

  const AlterarEstoqueScreen({super.key, required this.produto});

  @override
  State<AlterarEstoqueScreen> createState() => _AlterarEstoqueScreenState();
}

class _AlterarEstoqueScreenState extends State<AlterarEstoqueScreen> {
  final _quantidadeController = TextEditingController();
  String _tipoMovimento = 'ADICAO';
  final ProdutoService _produtoService = ProdutoService();

  void _alterarEstoque() async {
    if (_quantidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira uma quantidade.')),
      );
      return;
    }

    final quantidadeAlterada = int.tryParse(_quantidadeController.text);
    if (quantidadeAlterada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantidade inválida.')),
      );
      return;
    }

    bool sucesso = await _produtoService.alterarEstoque(
      produtoId: widget.produto.id,
      tipoMovimento: _tipoMovimento,
      quantidadeAlterada: quantidadeAlterada,
    );

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estoque atualizado com sucesso!')),
      );
      // Volta para a tela anterior (a lista de produtos).
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar o estoque.')),
      );
    }
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar Estoque'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.produto.descricao,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Código de Barras: ${widget.produto.codigoBarras}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Quantidade Atual: ${widget.produto.quantidade}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              // Seletor para o tipo de movimento
              const Text(
                'Tipo de Movimento:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Adição'),
                      value: 'ADICAO',
                      groupValue: _tipoMovimento,
                      onChanged: (value) {
                        setState(() {
                          _tipoMovimento = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Remoção'),
                      value: 'REMOCAO',
                      groupValue: _tipoMovimento,
                      onChanged: (value) {
                        setState(() {
                          _tipoMovimento = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              RadioListTile<String>(
                title: const Text('Ajuste'),
                value: 'AJUSTE',
                groupValue: _tipoMovimento,
                onChanged: (value) {
                  setState(() {
                    _tipoMovimento = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Campo para a quantidade
              TextField(
                controller: _quantidadeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _tipoMovimento == 'AJUSTE'
                      ? 'Nova Quantidade'
                      : 'Quantidade a ser alterada',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _alterarEstoque,
                  child: const Text('Confirmar Alteração'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}