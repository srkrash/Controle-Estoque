import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produto.dart';
import '../models/movimento.dart';

class ProdutoService {
  Future<String> get _baseUrl async {
    final prefs = await SharedPreferences.getInstance();
    // Usa a URL salva ou a URL padrão se nenhuma for encontrada
    return prefs.getString('server_base_url') ?? 'http://localhost:5000';
  }

  // 1. Endpoint para cadastrar um novo produto (POST /produtos)
  Future<bool> adicionarProduto(Produto produto) async {
    final url = Uri.parse('${await _baseUrl}/produtos');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(produto.toJson()),
    );

    if (response.statusCode == 201) {
      // Produto criado com sucesso
      return true;
    } else {
      // Falha ao criar o produto. Tratar o erro (ex: produto já existe).
      print('Falha ao adicionar produto: ${response.body}');
      return false;
    }
  }

  // 2. Endpoint para listar todos os produtos (GET /produtos)
  Future<List<Produto>> listarProdutos({String? searchTerm}) async {
    // Constrói a URL. Se houver um termo de busca, adiciona o parâmetro 'query'.
    final url = Uri.parse(
      '${await _baseUrl}/produtos${searchTerm != null && searchTerm.isNotEmpty ? '?query=$searchTerm' : ''}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((item) => Produto.fromJson(item)).toList();
    } else {
      print('Falha ao carregar produtos: ${response.body}');
      return [];
    }
  }

  // 3. Endpoint para alterar o estoque de um produto (PUT /produtos/<id>/estoque)
  Future<bool> alterarEstoque({
    required int produtoId,
    required String tipoMovimento,
    required int quantidadeAlterada,
  }) async {
    final url = Uri.parse('${await _baseUrl}/produtos/$produtoId/estoque');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tipo_movimento': tipoMovimento,
        'quantidade_alterada': quantidadeAlterada,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Falha ao alterar estoque: ${response.body}');
      return false;
    }
  }

  // 4. Endpoint para listar todos os movimentos (GET /movimentos)
  Future<List<Movimento>> listarMovimentos() async {
    final url = Uri.parse('${await _baseUrl}/movimentos');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((item) => Movimento.fromJson(item)).toList();
    } else {
      print('Falha ao carregar movimentos: ${response.body}');
      return [];
    }
  }
}
