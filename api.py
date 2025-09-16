import sqlite3
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
# Permite que o app Flutter (de outra "origem") acesse esta API
CORS(app)

DATABASE = 'estoque.db'

def get_db_connection():
    """Cria uma conexão com o banco de dados."""
    conn = sqlite3.connect(DATABASE)
    # Retorna as linhas como dicionários, o que facilita a conversão para JSON
    conn.row_factory = sqlite3.Row
    return conn

# --- ENDPOINTS DA API ---

@app.route('/', methods=['GET'])
def documentacao_api():
    """
    Endpoint de documentação para apresentar os endpoints da API.
    Retorna: Um JSON com a descrição dos endpoints.
    """
    endpoints = {
        "/": {
            "metodo": "GET",
            "descricao": "Apresenta esta documentação breve da API."
        },
        "/produtos": {
            "metodo": "POST",
            "descricao": "Cadastra um novo produto no estoque."
        },
        "/produtos": {
            "metodo": "GET",
            "descricao": "Lista todos os produtos cadastrados no estoque."
        },
        "/produtos/<int:produto_id>/estoque": {
            "metodo": "PUT",
            "descricao": "Altera a quantidade de um produto específico (Adição, Remoção, Ajuste)."
        },
        "/movimentos": {
            "metodo": "GET",
            "descricao": "Lista todo o histórico de movimentações de estoque."
        }
    }
    return jsonify(endpoints)

@app.route('/produtos', methods=['POST'])
def adicionar_produto():
    """
    Endpoint para cadastrar um novo produto.
    Recebe: JSON com codigo_barras, descricao, quantidade.
    Retorna: O produto cadastrado ou uma mensagem de erro.
    """
    dados = request.get_json()
    codigo_barras = dados.get('codigo_barras')
    descricao = dados.get('descricao')
    quantidade = dados.get('quantidade')

    if not all([codigo_barras, descricao, quantidade is not None]):
        return jsonify({'erro': 'Dados incompletos'}), 400

    conn = get_db_connection()
    try:
        # Inicia uma transação para garantir a consistência dos dados
        conn.execute('BEGIN')

        # Insere o produto
        cursor = conn.execute(
            'INSERT INTO produtos (codigo_barras, descricao, quantidade) VALUES (?, ?, ?)',
            (codigo_barras, descricao, int(quantidade))
        )
        produto_id = cursor.lastrowid

        # Cria o primeiro registro de movimento (estoque inicial)
        conn.execute(
            'INSERT INTO movimentos (produto_id, tipo_movimento, quantidade_alterada) VALUES (?, ?, ?)',
            (produto_id, 'INICIAL', int(quantidade))
        )

        conn.commit()
        produto_criado = conn.execute('SELECT * FROM produtos WHERE id = ?', (produto_id,)).fetchone()
        
    except sqlite3.IntegrityError:
        conn.rollback()
        return jsonify({'erro': f'Produto com código de barras "{codigo_barras}" já existe.'}), 409
    except Exception as e:
        conn.rollback()
        return jsonify({'erro': str(e)}), 500
    finally:
        conn.close()

    return jsonify(dict(produto_criado)), 201

@app.route('/produtos', methods=['GET'])
def listar_produtos():
    """
    Endpoint para listar todos os produtos cadastrados.
    Pode receber um parâmetro 'query' para filtrar a busca por descrição ou código de barras.
    Retorna: Uma lista de produtos em JSON.
    """
    conn = get_db_connection()
    # Pega o termo de busca da URL, se existir (ex: /produtos?query=arroz)
    query_term = request.args.get('query', '')
    
    produtos = []
    if query_term:
        # Se houver um termo de busca, filtra os resultados.
        # O '%' é um coringa do SQL para buscar por partes.
        search_pattern = f'%{query_term}%'
        produtos = conn.execute(
            'SELECT * FROM produtos WHERE descricao LIKE ? OR codigo_barras LIKE ? ORDER BY descricao',
            (search_pattern, search_pattern)
        ).fetchall()
    else:
        # Se não houver termo, lista todos os produtos.
        produtos = conn.execute('SELECT * FROM produtos ORDER BY descricao').fetchall()
    
    conn.close()
    return jsonify([dict(p) for p in produtos])

@app.route('/produtos/<int:produto_id>/estoque', methods=['PUT'])
def alterar_estoque(produto_id):
    """
    Endpoint para alterar o estoque de um produto (adicionar, remover, ajustar).
    Recebe: JSON com tipo_movimento ('ADICAO', 'REMOCAO', 'AJUSTE') e quantidade_alterada.
    Retorna: Mensagem de sucesso ou erro.
    """
    dados = request.get_json()
    tipo_movimento = dados.get('tipo_movimento')
    quantidade_alterada = dados.get('quantidade_alterada')

    if not tipo_movimento or quantidade_alterada is None:
        return jsonify({'erro': 'Dados incompletos'}), 400

    if tipo_movimento not in ['ADICAO', 'REMOCAO', 'AJUSTE']:
        return jsonify({'erro': 'Tipo de movimento inválido'}), 400
    
    quantidade_alterada = int(quantidade_alterada)

    conn = get_db_connection()
    try:
        produto = conn.execute('SELECT * FROM produtos WHERE id = ?', (produto_id,)).fetchone()
        if not produto:
            return jsonify({'erro': 'Produto não encontrado'}), 404

        quantidade_atual = produto['quantidade']
        nova_quantidade = 0

        if tipo_movimento == 'ADICAO':
            nova_quantidade = quantidade_atual + quantidade_alterada
        elif tipo_movimento == 'REMOCAO':
            nova_quantidade = quantidade_atual - quantidade_alterada
            if nova_quantidade < 0:
                return jsonify({'erro': 'Estoque não pode ficar negativo'}), 400
        elif tipo_movimento == 'AJUSTE':
            nova_quantidade = quantidade_alterada

        # Inicia a transação
        conn.execute('BEGIN')
        conn.execute('UPDATE produtos SET quantidade = ? WHERE id = ?', (nova_quantidade, produto_id))
        conn.execute(
            'INSERT INTO movimentos (produto_id, tipo_movimento, quantidade_alterada) VALUES (?, ?, ?)',
            (produto_id, tipo_movimento, quantidade_alterada)
        )
        conn.commit()

    except Exception as e:
        conn.rollback()
        return jsonify({'erro': str(e)}), 500
    finally:
        conn.close()

    return jsonify({'mensagem': 'Estoque atualizado com sucesso'}), 200

@app.route('/movimentos', methods=['GET'])
def listar_movimentos():
    """
    Endpoint para listar o histórico de movimentações.
    Retorna: Uma lista de movimentos com detalhes do produto associado.
    """
    conn = get_db_connection()
    # Faz um JOIN para buscar a descrição do produto em cada movimento
    query = """
        SELECT 
            m.id, 
            m.produto_id,
            p.descricao,
            p.codigo_barras,
            m.tipo_movimento, 
            m.quantidade_alterada, 
            m.data_movimento
        FROM movimentos m
        JOIN produtos p ON m.produto_id = p.id
        ORDER BY m.data_movimento DESC
    """
    movimentos = conn.execute(query).fetchall()
    conn.close()
    return jsonify([dict(m) for m in movimentos])

@app.route('/produtos/<int:produto_id>', methods=['DELETE'])
def excluir_produto(produto_id):
    """
    Endpoint para excluir um produto pelo ID.
    Retorna: Mensagem de sucesso ou erro.
    """
    conn = get_db_connection()
    try:
        # Verifica se o produto existe
        produto = conn.execute('SELECT id FROM produtos WHERE id = ?', (produto_id,)).fetchone()
        if not produto:
            return jsonify({'erro': 'Produto não encontrado'}), 404

        # Inicia uma transação
        conn.execute('BEGIN')
        # A exclusão em 'produtos' vai automaticamente apagar os registros
        # em 'movimentos' graças ao FOREIGN KEY com ON DELETE CASCADE
        conn.execute('DELETE FROM produtos WHERE id = ?', (produto_id,))
        conn.commit()

    except Exception as e:
        conn.rollback()
        return jsonify({'erro': str(e)}), 500
    finally:
        conn.close()

    return jsonify({'mensagem': 'Produto excluído com sucesso'}), 200

if __name__ == '__main__':
    # Roda o servidor. '0.0.0.0' torna o servidor acessível na sua rede local,
    # o que é essencial para o emulador/celular Flutter se conectar.
    app.run(host='0.0.0.0', port=5000, debug=True)
