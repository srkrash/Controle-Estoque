-- Habilita o suporte a chaves estrangeiras no SQLite.
PRAGMA foreign_keys = ON;

-- Garante que as tabelas sejam recriadas do zero, se já existirem.
DROP TABLE IF EXISTS movimentos;
DROP TABLE IF EXISTS produtos;

-- Cria a tabela para armazenar os produtos
CREATE TABLE produtos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    codigo_barras TEXT UNIQUE NOT NULL,
    descricao TEXT NOT NULL,
    quantidade INTEGER NOT NULL DEFAULT 0
);

-- Cria a tabela para registrar o histórico de movimentações de estoque
CREATE TABLE movimentos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    produto_id INTEGER NOT NULL,
    tipo_movimento TEXT NOT NULL CHECK(tipo_movimento IN ('INICIAL', 'ADICAO', 'REMOCAO', 'AJUSTE')),
    quantidade_alterada INTEGER NOT NULL,
    data_movimento TEXT NOT NULL DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now', 'localtime')),
    FOREIGN KEY (produto_id) REFERENCES produtos (id) ON DELETE CASCADE
);
