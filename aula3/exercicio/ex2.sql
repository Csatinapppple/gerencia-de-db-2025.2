
--2) Adicionar coluna `sku` única em `produtos`.
--ALTER TABLE produtos ADD COLUMN sku VARCHAR(30) UNIQUE AFTER nome;
/*
	sku parece ser algum codigo de manter recorde do estoque entao vamos criar um id especifico pra sku

	O SQLite nao consegue adicionar colunas depois de uma coluna especifica
	somente consegue adicionar no final, também tem o problema de ser especificada como
	UNIQUE, ja que o valor default vai ser NULL para todas as linhas de entrada então ao
	adicionar para uma tabela com multiplas entradas já vai se encontrar um erro logico ja
	que automaticamente vai se popular todas com NULL
 */
-- resposta que funciona com sqlite requer criar uma tabela nova e popular ela com os dados antigos

BEGIN TRANSACTION;

ALTER TABLE produtos
ADD COLUMN sku TEXT;
	
UPDATE produtos
SET sku = 'SKU-' || id WHERE sku IS NULL;



CREATE TABLE produtos_temp (
    id INTEGER PRIMARY KEY,
    nome TEXT NOT NULL,
    sku TEXT UNIQUE,
    preco REAL NOT NULL CHECK (preco >= 0),
    estoque INTEGER NOT NULL DEFAULT 0 CHECK (estoque >= 0),
    categoria_id INTEGER,
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TEXT NULL,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

INSERT INTO produtos_temp
(id, nome, sku, preco, estoque, categoria_id, criado_em, atualizado_em)
SELECT 
id, nome, sku, preco, estoque, categoria_id, criado_em, atualizado_em  
FROM produtos;

PRAGMA foreign_keys = OFF;

DROP TABLE produtos;
ALTER TABLE produtos_temp RENAME TO produtos;

PRAGMA foreign_keys = ON;

COMMIT;