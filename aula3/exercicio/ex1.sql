--1) Criar uma tabela de auditoria simples.

CREATE TABLE auditoria_precos (
    id INTEGER PRIMARY KEY,
    produto_id INTEGER NOT NULL,
    preco_antigo REAL NOT NULL,
    preco_novo REAL NOT NULL,
    data_alteracao TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

CREATE TRIGGER tr_auditoria_preco
AFTER UPDATE OF preco ON produtos
FOR EACH ROW
WHEN OLD.preco != NEW.preco
BEGIN
	
	UPDATE produtos SET atualizado_em = CURRENT_TIMESTAMP WHERE id = OLD.id;

	INSERT INTO auditoria_precos (
		produto_id,
		preco_antigo,
		preco_novo,
		data_alteracao
	)
	VALUES (
		OLD.id,
		OLD.preco,
		NEW.preco,
		CURRENT_TIMESTAMP
	);
END;

-- testar nova tabela

UPDATE produtos SET preco = 39.99 WHERE nome = 'SSD 1TB';